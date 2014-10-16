//
//  PasscodeViewController.m
//  aventador
//
//  Created by Victor Zhang on 2014-04-22.
//  Copyright (c) 2014 Vokko. All rights reserved.
//

#import "PasscodeViewController.h"
#import "InboxfeedTableViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "UIColor+HexColors.h"
#include <stdlib.h>

@interface PasscodeViewController ()

@end

@implementation PasscodeViewController {

}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //Make sure these numbers came over okays
    NSLog(@"self phoneNum: %@",self.phoneNumber);
    NSLog(@"i18n phoneNum: %@",self.i18nNumber);

    //Prepare Listener To Hide Keyboard
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    //Listen to the verification code Text Field
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldDidChange:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:self.verificationCodeTextField];
    
    //Make button unclickable initially
    self.nextButton.backgroundColor = [UIColor grayColor];
    [self.nextButton setEnabled:NO];

    //Show the SMS dialogue
    //[self smsPopUp];
    
    
    
}

-(void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (IBAction)unwindToVerification:(UIStoryboardSegue *)segue
{
    
}

-(void)textFieldDidChange:(NSNotification *)notification {
    
    NSString *vn = self.verificationCodeTextField.text;
    
    if (vn.length > 4) {
        NSLog(@"Length is greater than 4");
        self.verificationCodeTextField.text = [self.verificationCodeTextField.text substringToIndex:4];
    }
    else if (vn.length == 4) {
        NSLog(@"Length is 4");
        [self.nextButton setEnabled:YES];
        self.nextButton.backgroundColor = [UIColor colorWithHexString:@"16a085"];
    }
    else {
        //Set text field back to original colour
        self.nextButton.backgroundColor = [UIColor grayColor];
        [self.nextButton setEnabled:NO];
    }
    
}


- (void)alertView:(UIAlertView *)theAlert clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // Send SMS to Phone Number Alert
    if (theAlert.tag == 999) {
        if (buttonIndex == 0) {//Cancel and pop back to Reg page 1
            [self.navigationController popToRootViewControllerAnimated:TRUE];
        }
        else {
            [self sendSMS]; // They pressed OK
        }
    }
}

-(void)smsPopUp {
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:self.i18nNumber
                                                      message:@"We will send a verification code to this number via SMS. If you want to change your phone number, please select 'Cancel'"
                                                     delegate:self
                                            cancelButtonTitle:@"Cancel"
                                            otherButtonTitles:nil];
    message.tag = 999;
    [message addButtonWithTitle:@"OK"];
    [message show];
}

-(void) alertSMSResent {
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Success"
                                                      message:@"An SMS message has been resent to your phone number"
                                                     delegate:self
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    [message show];
}

-(void) sendSMS {
    // Prepare parameters
    NSString *api_endpoint = @"/users/sms/";
    NSString *url = [api_url_base stringByAppendingString:api_endpoint];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];

    NSMutableDictionary *params = [[NSMutableDictionary alloc]initWithCapacity:10];
    [params setObject:self.phoneNumber forKey:@"phone_number"];
    [manager GET:url
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"Successfully sent SMS off");
              NSLog(@"JSON: %@", responseObject);
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Failed to send SMS off");
              NSLog(@"Error: %@", error);
          }];
}


- (IBAction)submitVerificationCode:(id)sender
{
    // SETUP PARAMETERS
    NSString *api_endpoint = @"/users/";
    NSString *url = [api_url_base stringByAppendingString:api_endpoint];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc]initWithCapacity:10];
    [params setObject:self.phoneNumber forKey:@"phone_number"];
    [params setObject:self.password forKey:@"password"];
    [params setObject:self.verificationCodeTextField.text forKey:@"verification_code"];
    [manager PUT:url
      parameters:params
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSLog(@"JSON: %@", responseObject);
             
             //NSString *value = responseObject[@"type"];
             NSDictionary *dict = [responseObject objectAtIndex:0];
             NSString *type = dict[@"type"];
             
             // If Succesful, go to verification view
             if ([type isEqualToString:@"success"]) {
                 NSLog(@"Successfully verified the user");
                 NSString *user_id = [dict[@"value"] valueForKey:@"id"];
                 NSString *key = [dict[@"value"] valueForKey:@"key"];
                 
                 // Add auth_key to the database
                 if ([SSKeychain setPassword:key forService:serviceAuthKey account:account]){
                     NSLog(@"auth_key added to Keychain");
                     BOOL addedUserID = [SSKeychain setPassword:user_id forService:serviceUserID account:account];
                     
                     // Go to Inbox Feed
                     if (addedUserID){
                         [self performSegueWithIdentifier: @"inboxFromVerification" sender: self];
                     }
                 }
                 else {
                     NSLog(@"auth_key could not be added to Keychain...try again");
                     // Catch this!
                     
                 }
                 
             }
             // If Unsuccessful, alert user
             else {
                 // Check error code
                 NSNumber *code = [dict[@"response"] valueForKey:@"code"];

                 // Create an UIAlert Message and show it
                 UIAlertView * errorMsg = [UIAlertView createErrorMessage:[code integerValue]];
                 [errorMsg show];
             }
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
         }];
}

- (IBAction)resendVerificationCode:(id)sender
{
    [self sendSMS];
    //After sending, prevent people from spamming by setting button to OFF
    [self.resendButton setEnabled:NO];
    [self performSelector:@selector(reenableResendButton) withObject:self afterDelay:5.0];

}

//Re-enabling the Resend Button
-(void)reenableResendButton {
    [self.resendButton setEnabled:YES];
    
    // Show a popup that shows that it has been succesfully sent
    [self alertSMSResent];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"inboxFromVerification"]) {
        ;
    }
}


@end
