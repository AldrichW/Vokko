//
//  UIAlertView + Errors.m
//  aventador
//
//  Created by Victor Zhang on 2014-05-12.
//  Copyright (c) 2014 Vokko. All rights reserved.
//

#import "UIAlertView + Errors.h"

@implementation UIAlertView (Errors)

/*  UIAlert Views created from error messages
 *
 *  tag = error number
 */
+(UIAlertView*) createErrorMessage:(int) error_number {
    
    UIAlertView *message = [[UIAlertView alloc] init];
    message.delegate = self;
    [message addButtonWithTitle:@"OK"];
    
    switch (error_number) {
        case 1:
            NSLog(@"authentication_error");
            message.title = @"Oops!";
            message.message = @"The phone number or password you entered was not correct.";
            message.tag = 1;
            
            
            break;
        case 2:
            NSLog(@"organization_pin_incorrect");
            message.title = @"Oops!";
            message.message = @"The organization pin that you entered was not correct.";
            message.tag = 1;
            
            
            break;
        case 3:
            NSLog(@"verification_code_incorrect");
            message.title = @"Oops!";
            message.message = @"The verification code you entered was not correct.";
            message.tag = 1;
            
            break;
        case 4:
            NSLog(@"invalid_organization_email");
            message.title = @"Oops!";
            message.message = @"The organization email that you entered does not exist.";
            message.tag = 1;
            
            break;
        case 5:
            NSLog(@"user_not_verified");
            break;
        case 10:
            NSLog(@"user_not_found");
            break;
        case 11:
            NSLog(@"user_already_exists");
            message.title = @"Oops!";
            message.message = @"This phone number has already been registered.";
            message.tag = 1;
            
            break;
        case 12:
            NSLog(@"user_already_joined_organization");
            message.title = @"Oops!";
            message.message = @"You have already joined this organization";
            message.tag = 12;
            
            break;
        case 13:
            NSLog(@"user_not_joined_organization");
            message.title = @"Oops!";
            message.message = @"You have not joined any organizations yet";
            message.tag = 13;
            
            break;
        case 20:
            NSLog(@"mysql_error");
            message.title = @"Oh no!";
            message.message = @"Our servers may be in high capacity right now. Please try again.";
            message.tag = 20;
            
            break;
            
        default:
            break;
    }
    
    return message;
}

@end
