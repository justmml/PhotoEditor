//
//  FiltersViewController.m
//  Polaroid Photo Editor
//
//  Created by Mac on 03.01.2018.
//  Copyright © 2018 justmml. All rights reserved.
//

#import "FiltersViewController.h"
#import "FiltersCollectionViewCell.h"
#import "Extension.h"

@interface FiltersViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UICollectionView *filtersCollection;
@property UIImageView *imageView;
@property NSMutableArray *filterPreviews;
@property NSOperationQueue *filteringQueue;
- (IBAction)saveBtn:(id)sender;

@end

@implementation FiltersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateScaleInScrollView:self.scrollView];
    });
    
}

-(void)makeFilterPreviews
{
    self.filterPreviews = [[NSMutableArray alloc] init];
    
    //Filling in array with empty elements for preview in collection->
    for (long i = 0; i < [UIImage filterNames].count; i++)
    {
        [self.filterPreviews addObject:[[UIImage alloc]init]];
    }
    
    float size = 90 * [UIScreen mainScreen].scale;
    
    
    CGRect cropRect = frameFill(self.image.size,CGSizeMake(size, size));
    
    UIGraphicsBeginImageContext(CGSizeMake(size, size));
    [self.image drawInRect:cropRect];
    UIImage *cropped = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CIImage *ciimg = [[CIImage alloc] initWithImage:cropped];
    //creating queue for adding filtered image preview
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    queue.maxConcurrentOperationCount = 2;
    
    for (int i = 0; i < [UIImage filterNames].count; i++)
    {
         
        [queue addOperationWithBlock:^{
            CIImage *ciFiltered = [ciimg applyFilter:i];
            UIImage *filtered = [UIImage imageWithCIImageImproved:ciFiltered];
            
            @synchronized (self.filterPreviews) {
                [self.filterPreviews replaceObjectAtIndex:i withObject:filtered];
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self.filtersCollection reloadData];
                });
            }
        }];
    }
    
    
}


- (void)loadView{
    
    [super loadView];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    _imageView = [[UIImageView alloc] init];
    [_scrollView addSubview:_imageView];
    _imageView.image = _image;
    _imageView.frame = CGRectMake(0, 0, _image.size.width, _image.size.height);
    
    _filteringQueue = [NSOperationQueue new];
    _filteringQueue.maxConcurrentOperationCount = 1;
    _filteringQueue.qualityOfService = NSQualityOfServiceUserInitiated;
    [self.filtersCollection registerNib:[UINib nibWithNibName:@"FiltersCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"filtersCollectionCell"];//Xib file registry
     // Do any additional setup after loading the view.
    [self makeFilterPreviews];
     }

#pragma mark - Collection

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.filterPreviews.count;
} 
// Returns cells size
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat sz = collectionView.frame.size.height - 6;
    return CGSizeMake(sz, sz);
} 

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    long index = [indexPath item];
    FiltersCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"filtersCollectionCell"forIndexPath:indexPath];
    
    UIImageView *ivPreview = cell.imageFilter;
    ivPreview.image = self.filterPreviews[index];
    ivPreview.clipsToBounds = YES;
    ivPreview.layer.cornerRadius = 3.;
    UILabel *labelName = cell.nameFilter;
    labelName.text = [UIImage filterNames][index];
    
    
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    [self.filteringQueue cancelAllOperations];
    
    __block UIImage *filtered = nil;
    NSBlockOperation *operation1 = [NSBlockOperation blockOperationWithBlock:^{
        filtered = [self.image applyFilter:[indexPath item]];
    }];
    NSBlockOperation *operation2 = [NSBlockOperation blockOperationWithBlock:^{
        [CATransaction begin];
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (filtered) {
                _imageView.image = filtered;
            }
        });
    }];
    [operation2 addDependency:operation1];
    [self.filteringQueue addOperation:operation1];
    [self.filteringQueue addOperation:operation2];
} 

#pragma mark - Scroll View

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGSize sz = scrollView.contentSize;
    
    float xInsets = MAX(0, scrollView.frame.size.width/2.-sz.width/2.);
    float yInsets = MAX(0, scrollView.frame.size.height/2.-sz.height/2.);
    [scrollView setContentInset:UIEdgeInsetsMake(yInsets,xInsets,yInsets,xInsets)];
} 

- (void) orientationChanged:(NSNotification *)note
{
    [self.view layoutSubviews];
    [self updateScaleInScrollView:self.scrollView];
}

-(void)updateScaleInScrollView:(UIScrollView *)scrollView
{
    UIImage *image = _image;
    float minScale = sizeFit(image.size,scrollView.frame.size).width/image.size.width;
    scrollView.maximumZoomScale = MAX(1,minScale);
    scrollView.minimumZoomScale = minScale;
    scrollView.zoomScale = minScale;
    
    if (scrollView.zoomScale> scrollView.maximumZoomScale)
        scrollView.zoomScale = scrollView.maximumZoomScale;
    else if (scrollView.zoomScale< scrollView.minimumZoomScale)
    scrollView.zoomScale = scrollView.minimumZoomScale;
    
    [self scrollViewDidZoom:scrollView];
}
#pragma mark - other

CGSize sizeFill(CGSize size, CGSize sizeToFill)
{
    CGSize newSize;
    if (size.width / sizeToFill.width< size.height / sizeToFill.height)
        newSize = CGSizeMake(sizeToFill.width, sizeToFill.width*size.height/size.width);
    else
        newSize = CGSizeMake(sizeToFill.height*size.width/size.height, sizeToFill.height);
    
    return newSize;
}

CGSize sizeFit(CGSize size, CGSize sizeToFit)
{
    float w = size.width/sizeToFit.width;
    float h = size.height/sizeToFit.height;
    return w > h ? CGSizeMake(sizeToFit.width, size.height/w) : CGSizeMake(size.width/h, sizeToFit.height);
}
CGRect frameFill(CGSize size, CGSize sizeToFill)
{
    CGSize szFill = sizeFill(size, sizeToFill);
    CGPoint pntFill = CGPointMake(sizeToFill.width/2.-szFill.width/2., sizeToFill.height/2.-szFill.height/2.);
    return CGRectMake(pntFill.x, pntFill.y, szFill.width, szFill.height);
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)saveBtn:(id)sender {
    UIImageWriteToSavedPhotosAlbum(_imageView.image, nil, nil, nil);
}
@end
