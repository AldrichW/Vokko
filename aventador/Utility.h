//
//  Utility.h
//  aventador
//
//  Created by Mark Ye on 2014-05-04.
//  Copyright (c) 2014 Vokko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utility : NSObject

/*
 * the setLoadingIndicator function
 * creates a loading indicator and returns it
 * @param view  the view the indicator belongs to
 * @param p     the centre point - can be set using self.view.center if function is called from a ViewController
 * @return      the created loading indicator
 */
+ (UIActivityIndicatorView*) setLoadingIndicator:(UIViewController*)view indicatorCentre:(CGPoint)p;

/*
 * the stopIndicatorAnimating function
 * stops a loading indicator from animating and removes it from its parent view
 * @param indicator     the indicator we want to stop animating
 */
+ (void) stopIndicatorAnimating:(UIActivityIndicatorView*)indicator;

@end
