//
//  ViewController.m
//  Polaroid Photo Editor
//
//  Created by Mac on 03.01.2018.
//  Copyright © 2018 justmml. All rights reserved.
//

#import "ViewController.h"
#import "FiltersViewController.h"
#import "Extension.h"

static NSString *const kFiltersSegueId = @"toFilters";
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *btnOpenPhoto;
@property UIImage *selectedImage;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnOpen_pressed:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    [picker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [self presentViewController:picker animated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker
       didFinishPickingImage:(UIImage *)image
                 editingInfo:(NSDictionary *)editingInfo
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    self.btnOpenPhoto.enabled = NO;
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        self.selectedImage = image;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:kFiltersSegueId sender:self];
            self.btnOpenPhoto.enabled = YES;
            
        });
    });
    
}

-(void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kFiltersSegueId])
    {
        FiltersViewController *destinationController = (FiltersViewController *)segue.destinationViewController;
        destinationController.image = self.selectedImage;
    }
}

@end
