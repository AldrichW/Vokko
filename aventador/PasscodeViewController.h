//
//  PasscodeViewController.h
//  aventador
//
//  Created by Victor Zhang on 2014-04-22.
//  Copyright (c) 2014 Vokko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface PasscodeViewController : UIViewController

@property NSString *phoneNumber;
@property NSString *i18nNumber;
@property NSString *password;

//I think this is a really bad way of doing it... how to protect?
@property NSString *verificationCode;

//Elements
@property (weak, nonatomic) IBOutlet UIButton *resendButton;
@property (weak, nonatomic) IBOutlet UITextField *verificationCodeTextField;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

//-(void) registerNewUser;
//-(BOOL) userAlreadyExists;
@end
