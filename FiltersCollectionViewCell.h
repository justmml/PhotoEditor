//
//  FiltersCollectionViewCell.h
//  Polaroid Photo Editor
//
//  Created by Mac on 03.01.2018.
//  Copyright © 2018 justmml. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FiltersCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameFilter;
@property (weak, nonatomic) IBOutlet UIImageView *imageFilter;

@end
