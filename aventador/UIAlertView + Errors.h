//
//  UIAlertView + Errors.h
//  aventador
//
//  Created by Victor Zhang on 2014-05-12.
//  Copyright (c) 2014 Vokko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertView(Errors)

+(UIAlertView*) createErrorMessage:(int) error_number;

@end