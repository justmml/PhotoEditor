//
//  Extension.h
//  Polaroid Photo Editor
//
//  Created by Mac on 03.01.2018.
//  Copyright © 2018 justmml. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CIImage (Extension)
-(CIImage *)applyFilter:(long)i;
@end

@interface UIImage (Extension)

@property (class, readonly) NSArray * filterNames;

+ (NSArray *)filterNames;
- (UIImage *)applyFilter:(long)i;
+ (instancetype)imageWithCIImageImproved:(CIImage *)img;

@end
