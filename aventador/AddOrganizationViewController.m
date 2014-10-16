//
//  AddOrganizationViewController.m
//  aventador
//
//  Created by Victor Zhang on 2014-05-01.
//  Copyright (c) 2014 Vokko. All rights reserved.
//

#import "AddOrganizationViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "Organization.h"
#import "OrganizationsTableViewController.h"

@interface AddOrganizationViewController ()

// UI OUTLETS
@property (weak, nonatomic) IBOutlet UITextField *orgEmailTextField;
@property (weak, nonatomic) IBOutlet UIButton *joinButton;


@end

@implementation AddOrganizationViewController {
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
    
    // Set the Title
    NSString *title = @"Join ";
    title = [title stringByAppendingString:self.organization_name];
    
    self.title = title;
    
    //Prepare Listener To Hide Keyboard
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];

}

// DISMISS KEYBOARD
-(void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)joinAnOrganization:(id)sender {
    //Make Button Unclickable for 2 seconds to prevent rapid firing of API calls
    UIButton *btn = (UIButton *)sender;
    btn.enabled = NO;
    
    // Get organization email from text
    NSString *orgEmail = self.orgEmailTextField.text;
    if ([self validEmail:orgEmail]) {
        [self sendEmail];
    }
    else {
        [self showInvalidEmailExpression];
        btn.enabled = YES;
    }

}

-(void) sendEmail {
    NSLog(@"sending email now...");
    // Prepare parameters
    NSString *api_endpoint = @"/organizations/";
    NSString *url = [api_url_base stringByAppendingString:api_endpoint];
    
    // Get Keychain Data
    NSString *auth_key = [SSKeychain passwordForService:serviceAuthKey account:account];
    NSString *user_id = [SSKeychain passwordForService:serviceUserID account:account];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //manager.requestSerializer = [AFJSONRequestSerializer serializer]; //THIS LINE USED FOR GET ONLY
    [manager.requestSerializer setValue:auth_key forHTTPHeaderField:@"X-API-KEY"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc]initWithCapacity:10];
    [params setObject:user_id forKey:@"user_id"];
    [params setObject:self.organization_id forKey:@"organization_id"];
    [params setObject:self.orgEmailTextField.text forKey:@"email"];
    
    [manager POST:url
      parameters:params
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSDictionary *dict = [responseObject objectAtIndex:0];
             NSString *type = dict[@"type"];
             
             // If Succesful, go to verification view
             if ([type isEqualToString:@"success"]) {
                 NSLog(@"email success!");
                 // Go Back to My Organizations View
                 NSMutableDictionary *dataDict = [[NSMutableDictionary alloc] init];
                 [dataDict setObject:self.organization_name forKey:@"organization_name"];
                 [dataDict setObject:self.organization_id forKey:@"organization_id"];

                 // Notifies first view...
                 [[NSNotificationCenter defaultCenter] postNotificationName:@"addNewUnverifiedOrganization"
                                                                     object:self
                                                                   userInfo:dataDict];
                 
                 [self.navigationController popToRootViewControllerAnimated:YES];
                 
             }
             else {
                 // Check error code
                 NSNumber *code = [dict[@"response"] valueForKey:@"code"];
                 NSString *message = [dict[@"response"] valueForKey:@"message"];
                 if ([code integerValue] == 4) {
                     NSLog(@"Error message: %@",message);
                     [self showInvalidEmailPrefixAlert];
                 }
                 else if ([code integerValue] == 12) {
                     // You're already a part of this organization... lol
                 }
                 else if ([code integerValue] == 13) {
                 }
                 else {
                     NSLog(@"another error with code: %d", [code integerValue]);
                 }

             }
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
         }];
}


-(void) showInvalidEmailExpression {
    // Create UIAlertView
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Oops"
                          message:@"Please correct your email."
                          delegate:self  // set nil if you don't want the yes button callback
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil, nil];
    
    [alert show];
}

-(void) showInvalidEmailPrefixAlert {
    // Create UIAlertView
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Oops"
                          message:@"This email is does not belong to the organization."
                          delegate:self  // set nil if you don't want the yes button callback
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil, nil];
    
    [alert show];
}

/*
 * HELPER FUNCTIONS
 */

-(BOOL) validEmail:(NSString*) emailString {
    NSString *expression = @"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$"; // Edited: added ^ and $
    NSError *error = NULL;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSTextCheckingResult *match = [regex firstMatchInString:emailString options:0 range:NSMakeRange(0, [emailString length])];
    
    if (match){
        return YES;
    }else{
        return NO;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
