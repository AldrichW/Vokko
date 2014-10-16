//
//  UIImage+Utilities.h
//  
//
//  Created by Victor Zhang on 2014-04-27.
//
//

#import <UIKit/UIKit.h>

@interface UIImageUtilities : UIImage

+(UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
+ (UIImage *)squareImageFromImage:(UIImage *)image withSide:(CGFloat)side;

@end
