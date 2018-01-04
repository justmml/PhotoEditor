//
//  Extension.m
//  Polaroid Photo Editor
//
//  Created by Mac on 03.01.2018.
//  Copyright © 2018 justmml. All rights reserved.
//

#import "Extension.h"

@implementation CIImage (Extension)

-(CIImage *)applyFilter:(long)i
{
    CIFilter *filter;
    
    switch (i) {
        case 0:
            return [self copy];
            break;
        case 1:
            filter = [CIFilter filterWithName:@"CISepiaTone"];
            break;
        case 2:
            filter = [CIFilter filterWithName:@"CIColorMonochrome"];
            break;
        case 3:
            filter = [CIFilter filterWithName:@"CIPhotoEffectMono"];
            break;
        case 4:
            filter = [CIFilter filterWithName:@"CIPhotoEffectInstant"];
            break;
        case 5:
            filter = [CIFilter filterWithName:@"CIHueAdjust"];
            [filter setDefaults];
            [filter setValue: [NSNumber numberWithFloat: M_PI] forKey: kCIInputAngleKey];
            break;
        case 6:
            filter = [CIFilter filterWithName:@"CIHueAdjust"];
            [filter setDefaults];
            [filter setValue: [NSNumber numberWithFloat: M_PI_2] forKey: kCIInputAngleKey];
            break;
        case 7:
            filter = [CIFilter filterWithName:@"CIColorInvert"];
            break;
        case 8:
            filter = [CIFilter filterWithName:@"CIFalseColor"];
            break;
        case 9:
            filter = [CIFilter filterWithName:@"CIPhotoEffectTonal"];
            break;
        case 10:
            filter= [CIFilter filterWithName:@"CIPhotoEffectTransfer"];
            break;
        case 11:
            filter= [CIFilter filterWithName:@"CIPhotoEffectProcess"];
            break;
        case 12:
            filter= [CIFilter filterWithName:@"CIPhotoEffectChrome"];
            break;
        case 13:
            filter = [CIFilter filterWithName:@"CIGaussianBlur"];
            [filter setDefaults];
            [filter setValue: [NSNumber numberWithFloat:(self.extent.size.width + self.extent.size.height)/30.] forKey:@"inputRadius"];
        default:
            break;
    }
    
    [filter setValue:self forKey:kCIInputImageKey];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    return result;
}
@end


@implementation UIImage (Extension)


+(NSArray *)filterNames
{
    static NSArray *names;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        names = @[@"Original",@"Sepia", @"Old Photo", @"Mono", @"Instant", @"Shift", @"Hue", @"Invert", @"Falce", @"Tonal", @"Transfer", @"Process", @"Chrome"];
    });
    return names;
}
- (UIImage *)applyFilter:(long)i
{
    CIImage *ciImage = [[CIImage alloc] initWithImage: self];
    CIImage *result = [ciImage applyFilter:i];
    CGRect extent1 = [result extent];
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImage1 = [context createCGImage:result fromRect:extent1];
    UIImage *img = [UIImage imageWithCGImage:cgImage1];
    CGImageRelease(cgImage1);
    return img;
}



+ (instancetype)imageWithCIImageImproved:(CIImage *)img
{
    CGRect extent = [img extent];
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [context createCGImage:img fromRect:extent];
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    return image;
}

@end
