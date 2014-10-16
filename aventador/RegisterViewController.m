//
//  RegisterViewController.m
//  aventador
//
//  Created by Victor Zhang on 2014-04-19.
//  Copyright (c) 2014 Vokko. All rights reserved.
//

#import "RegisterViewController.h"
#import "PasscodeViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "Utility.h"
#import "RegisterViewController.h"
#import "InboxfeedTableViewController.h"
#import "PrivacyandTermsViewController.h"
#import "AppDelegate.h"

@interface RegisterViewController ()

//Tracker for Edit Text
@property int previousEditTextLength;
@property NSString *verificationCode;
@property NSString *phoneNumber;
@property NSString *password;

@end

@implementation RegisterViewController {
    UIActivityIndicatorView * indicator_spinner;
    NSString *selection;
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
    // Set Navigationbar Colour
    NSShadow* shadow = [NSShadow new];
    shadow.shadowOffset = CGSizeMake(0.0f, 1.0f);
    shadow.shadowColor = [UIColor whiteColor];
    [[UINavigationBar appearance] setTitleTextAttributes: @{
                                                            NSForegroundColorAttributeName: [UIColor colorWithHexString:@"004e83"],
                                                            NSFontAttributeName: [UIFont fontWithName:@"montserrat" size:20.0f],
                                                            NSShadowAttributeName: shadow
                                                            }];

    
    // Check if already logged in
    [self checkIfUserIsLoggedIn];
    
    //EditText is empty so make initialize to zero.
    self.previousEditTextLength = 0;
    
    //Prepare Listener To Hide Keyboard
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    //Listen to the Phone Number Text Field
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldDidChange:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:self.phoneNumberTextField];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldDidChange:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:self.passwordTextField];
    
    //Make button unclickable initially
    self.verifyButton.backgroundColor = [UIColor grayColor];
    self.verifyButton.titleLabel.font = [UIFont fontWithName:@"roboto" size:15.0f];
    [self.verifyButton setEnabled:NO];
    
    //Fonts
    [self.phoneNumberTextField setFont:[UIFont fontWithName:@"roboto" size:18.0f]];
    [self.passwordTextField setFont:[UIFont fontWithName:@"roboto" size:18.0f]];

    //Load the NSDictionary of Area Codes
    self.areaCodes = [[NSMutableDictionary alloc] init];
    [self loadAreaCodes];
    
    // Get Privacy and Terms ready
    selection = @"";
}

-(void) viewDidAppear:(BOOL)animated {
    [self.phoneNumberTextField becomeFirstResponder];

}

-(void) checkIfUserIsLoggedIn {
    
    // Check if user is has previously logged in
    NSString *auth_key = [SSKeychain passwordForService:serviceAuthKey account:account];
    NSString *user_id = [SSKeychain passwordForService:serviceUserID account:account];

    if (([auth_key length] != 0) && ([user_id length] != 0)) {
        NSLog(@"both not null, lets segueeee");
        
        InboxfeedTableViewController *loginController=[[UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"inboxTVC"];
        UINavigationController *navController=[[UINavigationController alloc]initWithRootViewController:loginController];
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.window.rootViewController = navController;
        
    } else {
        NSLog(@"User is not logged in.");
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // Hide Navigation Controller
    //[self.navigationController setNavigationBarHidden:YES];   //it hides
}

- (IBAction)unwindToRegister:(UIStoryboardSegue *)segue {
    
}

-(void)dismissKeyboard {
    [self.view endEditing:YES];
}

-(void)textFieldDidChange:(NSNotification *)notification {
    NSString *darkBlue = @"004e83";
    
    NSString *pn = self.phoneNumberTextField.text;
    NSString *pw = self.passwordTextField.text;
    
    BOOL appendingIsHappening = NO;
    if (pn.length > self.previousEditTextLength)
        appendingIsHappening = YES;

    if ((pn.length == 14) && (pw.length > 0 )) {
        self.verifyButton.backgroundColor = [UIColor colorWithHexString:darkBlue];
        [self.verifyButton setEnabled:YES];
    }
    else if (pn.length == 3) {
        if (appendingIsHappening) {
            NSString *ac = self.phoneNumberTextField.text;
            NSString *tpn = @"(";
            tpn = [tpn stringByAppendingString:ac];
            self.phoneNumberTextField.text = [tpn stringByAppendingString:@") "];
        }
    }
    else if (pn.length == 9) {
        if (appendingIsHappening) {
            self.phoneNumberTextField.text = [self.phoneNumberTextField.text stringByAppendingString:@"-"];
        }
    }
    else if (pn.length > 14) {
        self.phoneNumberTextField.text = [self.phoneNumberTextField.text substringToIndex:14];
    }
    else {
        //Set text field back to original colour
        self.verifyButton.backgroundColor = [UIColor grayColor];
        [self.verifyButton setEnabled:NO];
    }
    
    //Update the previousLength value
    self.previousEditTextLength = (int)pn.length;
    
}

-(void) loadAreaCodes {
    NSString* path = [[NSBundle mainBundle] pathForResource:@"AreaCodesSpace"
                                                     ofType:@"txt"];
    NSString* content = [NSString stringWithContentsOfFile:path
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];

    //took out the '\r' from delimiter string, couldn't load all objects otherwise
    NSArray *line = [content componentsSeparatedByString:@"\n"];
    for (int i = 0; i < (line.count-1); i++) {
        //replaced all space between each line into 1 space. Makes splitting more consistent.
        NSArray *code_state_pair = [line[i] componentsSeparatedByString:@" "];
        [self.areaCodes setObject:code_state_pair[1] forKey:code_state_pair[0] ];
    }

    NSLog(@"number of elements inside areaCode dictionary: %lu", [self.areaCodes count]);
}

// First, we try to log a user in. If this fails and his phone number doesn't exist, we try and register!
-(void)logUserIn {
    //Make Button Unclickable for 2 seconds to prevent rapid firing of API calls
    
    self.verifyButton.enabled = NO;
    [self performSelector:@selector(enableButton:) withObject:self.verifyButton afterDelay:2.0];
    
    // Spinner to show magic happening
    UIActivityIndicatorView * indicator = [Utility setLoadingIndicator:self indicatorCentre:self.view.center];
    self->indicator_spinner = indicator;
    [indicator startAnimating];
    
    // SETUP PARAMETERS
    NSString *api_endpoint = @"/users/auth_key/";
    NSString *url = [api_url_base stringByAppendingString:api_endpoint];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc]initWithCapacity:10];
    [params setObject:self.phoneNumber forKey:@"phone_number"];
    [params setObject:self.passwordTextField.text forKey:@"password"];
    [manager POST:url
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"JSON: %@", responseObject);
              
              //NSString *value = responseObject[@"type"];
              NSDictionary *dict = [responseObject objectAtIndex:0];
              NSString *type = dict[@"type"];
              [Utility stopIndicatorAnimating:indicator]; // Stop Spinner
              if ([type isEqualToString:@"success"]) {
                  
                  
                  NSLog(@"Successfully verified the user");
                  NSString *user_id = [dict[@"value"] valueForKey:@"user_id"];
                  NSString *key = [dict[@"value"] valueForKey:@"key"];
                  
                  // Add auth_key to the database
                  if ([SSKeychain setPassword:key forService:serviceAuthKey account:account]){
                      NSLog(@"auth_key added to Keychain");
                      BOOL addedUserID = [SSKeychain setPassword:user_id forService:serviceUserID account:account];
                      
                      // Go to Inbox Feed
                      if (addedUserID){
                          NSLog(@"user_id added to Keychain");

                          [self performSegueWithIdentifier: @"inboxFromLogin" sender: self];
                      }
                  }
                  else {
                      NSLog(@"auth_key could not be added to Keychain...try again");
                      // Catch this!
                  }
              }
              // If Unsuccessful, alert user
              else {
                  [Utility stopIndicatorAnimating:indicator]; // Stop Spinner

                  // Check error code
                  NSNumber *code = [dict[@"response"] valueForKey:@"code"];
                  NSString *message = [dict[@"response"] valueForKey:@"message"];
                  
                  // Move the user to the next screens
                  if ([code integerValue] == 5) {
                      NSLog(@"Error message: %@",message);
                      [self performSegueWithIdentifier: @"verificationFromLogin" sender: self];
                  }
                  else if ([code integerValue] == 10) {
                      NSLog(@"Phone number doesn't exist. Registration time!");
                      // Phone number does not exist. Let's go ahead and try to verify this!
                      [self registerNewUser];
                  }
                  else {
                      // Create an UIAlert Message and show it
                      UIAlertView * errorMsg = [UIAlertView createErrorMessage:(int)[code integerValue]];
                      [errorMsg show];
                      
                  }
            }
              
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error: %@", error);
              [Utility stopIndicatorAnimating:indicator];
          }];
    
}

- (void)registerNewUser {
    
    // SETUP PARAMETERS
    NSString *api_endpoint = @"/users/";
    NSString *url = [api_url_base stringByAppendingString:api_endpoint];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc]initWithCapacity:10];
    [params setObject:self.phoneNumber forKey:@"phone_number"];
    [manager POST:url
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"JSON: %@", responseObject);
              
              //NSString *value = responseObject[@"type"];
              NSDictionary *dict = [responseObject objectAtIndex:0];
              NSString *type = dict[@"type"];
              
              // If Succesful, go to verification view
              [Utility stopIndicatorAnimating:indicator_spinner];//Stop Spinner
              
              if ([type isEqualToString:@"success"]) {
                  [self performSegueWithIdentifier: @"verificationFromLogin" sender: self];
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
              [Utility stopIndicatorAnimating:indicator_spinner];
          }];
}

- (void)enableButton:(UIButton *)button
{
    button.enabled = YES;
}

/*
 *  TERMS
 *
 */

-(IBAction)privacyClicked:(id)sender {
    selection = @"privacy";
    [self performSegueWithIdentifier: @"privacy" sender: self];
}

-(IBAction)termsClicked:(id)sender {
    selection = @"termsOfUse";
    [self performSegueWithIdentifier: @"privacy" sender: self];
}

/*
 *  HELPER FUNCTIONS
 *
 */
- (IBAction) verifyPhoneNumber:(id)sender
{
    NSString *pw = self.passwordTextField.text;
    NSString *i18n =self.phoneNumberTextField.text;
    //Sanitize the textfield back into just numbers
    NSString *pn = [[i18n componentsSeparatedByCharactersInSet:
                            [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                           componentsJoinedByString:@""];
    
    //Check for [1 X X X ...] to be a Canadian or USA Prefix
    NSString *areaCode = [pn substringToIndex:3];
    NSLog(@"%@",areaCode);
    if ([self.areaCodes valueForKey:areaCode]) {
        NSLog(@"Area code found! Woohoo");
        
        //Save the fields that we'll need later
        self.phoneNumber = pn;
        self.password = pw;

        // Lets try and save this user now :)
        [self logUserIn];
    }
    else {
        NSLog(@"bad area code");
        NSString *msg = @"Your area code is: ";
        msg = [msg stringByAppendingString:areaCode];
        
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Error: Area Code Not Supported!"
                                                          message:msg
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [message show];
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"verificationFromLogin"]) {
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        PasscodeViewController *destVC  = (PasscodeViewController *)navController.topViewController;
        destVC.phoneNumber = self.phoneNumber; //pass phone number to the new view
        destVC.i18nNumber = self.phoneNumberTextField.text;
        destVC.password = self.password;
    }
    else if ([segue.identifier isEqualToString:@"privacy"]) {
        PrivacyandTermsViewController *navController = (PrivacyandTermsViewController *)segue.destinationViewController;
        navController.selection = @"privacy";
        if ([selection isEqualToString:@"termsOfUse"]) {
            navController.selection = @"termsOfUse";
        }

        NSLog(@"%@", navController.selection);
    }
}

#pragma mark - Deallocation
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    // Other dealloc work
}

@end
