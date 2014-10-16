//
//  Utility.m
//  aventador
//
//  Created by Mark Ye on 2014-05-04.
//  Copyright (c) 2014 Vokko. All rights reserved.
//

#import "Utility.h"

@implementation Utility

+ (UIActivityIndicatorView *) setLoadingIndicator:(UIViewController*)view indicatorCentre:(CGPoint)p {
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
    indicator.center = p;
    [view.view addSubview:indicator];
    [indicator bringSubviewToFront:view.view];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = true;
    
    return indicator;
    
}

+ (void) stopIndicatorAnimating:(UIActivityIndicatorView*)indicator {
    [indicator stopAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = false;
    [indicator removeFromSuperview];
}

@end
