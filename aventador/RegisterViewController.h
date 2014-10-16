//
//  RegisterViewController.h
//  aventador
//
//  Created by Victor Zhang on 2014-04-19.
//  Copyright (c) 2014 Vokko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIColor+HexColors.h"

@interface RegisterViewController : UIViewController


//Dictionary of Area Codes
@property NSMutableDictionary *areaCodes;

//Elements
@property (weak, nonatomic) IBOutlet UIButton *verifyButton;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

- (IBAction)unwindToRegister:(UIStoryboardSegue *)segue;

@end
