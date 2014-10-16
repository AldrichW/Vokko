//
//  UploadImageViewController.m
//  aventador
//
//  Created by Aldrich Wingsiong on 2014-04-21.
//  Copyright (c) 2014 Vokko. All rights reserved.
//

#import "UploadImageViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "SelectOrgTableViewController.h"
#import "Utility.h"
#import "Post.h"
#import "PageContentViewController.h"
#import "Organization.h"

@interface UploadImageViewController ()

@property NSString *imageFileName;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *postButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (weak, nonatomic) IBOutlet UIButton *selectOrganizationButton;

@property (weak, nonatomic) NSNumber *organization_id;
@property (weak, nonatomic) NSString *organization_name;

// Gestures
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *up;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *down;

@end

@implementation UploadImageViewController {
    
    // Organizations
    NSMutableArray *verified_organizations_list;
    int numberOfVerifiedOrgs;
    int numImagesCurrentlyLoaded;
    int maxNumberOfStockImages;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Geolocation feature. Gets your location as soon as you hit the new post button.
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = 10000.0f; //Move 10km away for another reading
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self getLocation];
    
    // Stock Imagess
    numImagesCurrentlyLoaded = 3;
    maxNumberOfStockImages = 18;
    
    self.stockImages = [[NSMutableDictionary alloc] init];
    self.imageOrder = [[NSMutableArray alloc] init];
    
    // Preloading stock images
    [self.stockImages setObject:[UIImage imageNamed:@"img-1.png"] forKey:@"img-1.png"];
    [self.stockImages setObject:[UIImage imageNamed:@"img-2.png"] forKey:@"img-2.png"];
    [self.stockImages setObject:[UIImage imageNamed:@"img-3.png"] forKey:@"img-3.png"];

    [self.imageOrder addObject:@"img-1.png"];
    [self.imageOrder addObject:@"img-2.png"];
    [self.imageOrder addObject:@"img-3.png"];

    // Page Controller Delcaration and Instantiation
    // Create page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.pageViewController.dataSource = self;
    
    PageContentViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // Page Controller Height Offset
    CGFloat navHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat originY = self.navigationController.navigationBar.frame.origin.y;
    CGFloat screenWidth = self.view.frame.size.width;
    CGFloat screenHeight = self.view.frame.size.height;
    CGFloat y_offset_from_top = (screenHeight - screenWidth)/2;
    
    // Change the size of page view controller
    self.pageViewController.view.frame = CGRectMake(0, navHeight+originY, self.view.frame.size.width, self.view.frame.size.height - 2*y_offset_from_top);
    
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    // Buttons
    [self.cameraButton addTarget:self action:@selector(GetImageButton:) forControlEvents:UIControlEventTouchUpInside];

    // Text Listeners
    //Listen to the verification code Text Field
    self.messageTextView.delegate = self;


    //Prepare Listener To Hide Keyboard
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    // Bring Everything to the Front
    [self.view bringSubviewToFront:self.cameraButton];
    [self.view bringSubviewToFront:self.geotagLabel];
    [self.view bringSubviewToFront:self.messageTextView];
    [self.selectOrganizationButton setHidden:YES];
    
    // Order of API Calls
    numberOfVerifiedOrgs = 0;
    [self loadOrganizations];
    
}

-(NSString*) createStockImageName:(int) number {
    NSString * prefix = @"img-";
    NSString * extension = @".png";
    NSString * num = [NSString stringWithFormat:@"%d",number];
    
    NSArray *myStrings = [[NSArray alloc] initWithObjects:prefix, num, extension, nil];
    NSString *imageName = [myStrings componentsJoinedByString:@""];
    return imageName;
}

-(void) getMoreStockImages {
    for (int numStockImages = 1; numStockImages <= numImagesCurrentlyLoaded; numStockImages++) {
        
        NSString *image_key = [self createStockImageName:numStockImages];
        if ([self.stockImages objectForKey:image_key] == nil) {
            // GET FROM PARSE
            NSString *separator = [image_key substringWithRange:NSMakeRange(6,1)];
            NSString *image_number;
            image_number = [image_key substringWithRange:NSMakeRange(4,1)];
            
            if ([separator isEqualToString:@"."]){
                image_number = [image_key substringWithRange:NSMakeRange(4,2)];
            }
            NSNumber *imageNumber = [NSNumber numberWithInteger:[image_number intValue]];
            
            PFQuery *query = [PFQuery queryWithClassName:@"StockImages"];
            [query whereKey:@"imageNumber" equalTo:imageNumber];
            query.cachePolicy = kPFCachePolicyCacheElseNetwork;
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    // The find succeeded. Now let's hash all UIImages using their image key
                    NSLog(@"Successfully retrieved an image number: %@", image_number);
                    PFObject *postObject = [objects objectAtIndex:0];
                    // Get UIImage from Parse in Background Processs
                    PFFile *theImage = postObject[@"imageFile"];
                    // Image must be downloaded.
                    
                    [theImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                        if (!error) {
                            UIImage *photo = [UIImage imageWithData:data];
                            [self.stockImages setObject:photo forKey:image_key];
                            [self.imageOrder addObject:image_key];
                        }
                    }];
                } else {
                    // Log details of the failure
                    NSLog(@"Error retrieving image for key: %@... %@ %@", image_key, error, [error userInfo]);
                }
            }];
        
        }
    }
}


#pragma mark - SETUP
-(void) loadOrganizations {
    
    // Reset Defaults
    numberOfVerifiedOrgs = 0;
    
    // Prepare parameters
    NSString *api_endpoint = @"/organizations/";
    NSString *url = [api_url_base stringByAppendingString:api_endpoint];
    
    // Get Keychain Data
    NSString *auth_key = [SSKeychain passwordForService:serviceAuthKey account:account];
    NSString *user_id = [SSKeychain passwordForService:serviceUserID account:account];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:auth_key forHTTPHeaderField:@"X-API-KEY"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc]initWithCapacity:10];
    [params setObject:user_id forKey:@"user_id"];
    [manager GET:url
      parameters:params
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSLog(@"Organization request returned...");
             NSLog(@"JSON: %@", responseObject);
             
             //Count and add number of organizations
             if (!verified_organizations_list) {
                 verified_organizations_list = [[NSMutableArray alloc] init];
             }
             
             NSDictionary *dict = [responseObject objectAtIndex:0];
             if ([dict[@"type"] isEqualToString:@"success"]) {
                 NSArray *orgs = dict[@"value"];

                 for (int org_iter = 0; org_iter < orgs.count; org_iter++ ) {
                     NSDictionary *org = [orgs objectAtIndex:org_iter];
                     
                     // Store the name, to be used later
                     if ([org[@"verified"] isEqualToNumber:@1]) {
                         if (numberOfVerifiedOrgs == 0) {
                             self.organization_name = org[@"name"]; // Record this for later!
                             self.organization_id = org[@"organization_id"];
                         }
                         Organization *returnOrg = [Organization organizationFromJSON:org];
                         [verified_organizations_list insertObject:returnOrg atIndex:0];
                         numberOfVerifiedOrgs++;
                     }
                     
                 }
                 
                 // Replace the geotag label with the organization name
                 if (numberOfVerifiedOrgs >= 2) {
                     self.geotagLabel.text = self.organization_name;
                     [self.selectOrganizationButton setHidden:NO];
                     [self.geotagLabel setHidden:NO];
                 }
             }
             else {
                 // Check error code
                 NSNumber *code = [dict[@"response"] valueForKey:@"code"];
                 NSString *message = [dict[@"response"] valueForKey:@"message"];
                 NSLog(@"error is: %@ %@", code, message);
             }
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
         }];
}


- (IBAction)unwindToUploadImageView:(UIStoryboardSegue *)segue {
    
}

-(void)textFieldDidChange:(NSNotification *)notification{
    NSString *messageBody = self.messageTextView.text;
    
    if (messageBody.length > 140){
        self.messageTextView.text = [self.messageTextView.text substringToIndex: 140];
    }
    
}

/* POSTING a Vokko Post takes
 *  1) PFFile (image stored here) via Parse
 *  2) Post Information via AWS API
 *
 *  // image_key  =  either Parse Object ID    or    one of the stock imageNames (img-1.png)
 */
-(IBAction) submitVokkoPost:(UIButton*)sender {
    // Submit if there is an organization to submit from!
    if (numberOfVerifiedOrgs != 0) {
        
        // First disable the button
        self.postButton.enabled = NO;
        
        NSLog(@"Get Parse File Ready");
        // Save To Parse If First Image is From User
        // Get Current Screen
        int currentPage = [[self.pageViewController.viewControllers objectAtIndex:0] pageIndex];

        NSString *imageName = self.imageOrder[currentPage];
        if ([imageName isEqualToString:@"userChosenImage"]) {
            self.imageToUpload = [self.stockImages objectForKey:imageName];
            self.imageName = imageName;
            // Call Parse On This...
            
            NSData *imageData = UIImageJPEGRepresentation(self.imageToUpload, 0.05f);
            PFFile *imageFile = [PFFile fileWithName:self.imageName data:imageData];
            
            [imageFile saveInBackgroundWithBlock:^(BOOL fileSaved, NSError *error1) {
                if(fileSaved){
                    // Get user_id
                    NSString *user_id = [SSKeychain passwordForService:serviceUserID account:account];
                    
                    PFObject *postObject = [PFObject objectWithClassName:@"ImageFile"];
                    [postObject setObject:imageFile forKey:@"image_file"];
                    [postObject setObject:user_id forKey:@"user_id"];
                    
                    [postObject saveInBackgroundWithBlock:^(BOOL vokkoPostSaved, NSError *error2) {
                        if (vokkoPostSaved){
                            NSLog(@"Successfully saved image!");
                            
                            NSString *image_key;
                            // If an image was saved, use its objectID as image_key
                            image_key = [postObject objectId];
                            
                            //Now let's make a call to save the Vokko Post
                            NSLog(@"Now let's make a call to save the Vokko Post");
                            [self submitVokkoPostWithImage:image_key];
                            
                        }
                        else{
                            NSLog (@"Uh-oh we couldn't save your post because:%@",error2);
                            self.postButton.enabled = YES;
                        }
                    }];
                }
                else
                    NSLog (@"Uh-oh we couldn't save your image because:%@",error1);
            }];
            
        }
        else {
            [self submitVokkoPostWithImage:imageName];
        }
    }
    else {
        // No Organizations, Let's Alert the User
        [self alertNoVerifiedOrganizations];
    }
}

-(void) alertNoVerifiedOrganizations {
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"No verified organizations"
                                                      message:@"Please add or verify yourself into an organization before posting!"
                                                     delegate:self
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    message.tag = 1;
    
    [message show];
}

-(void) submitVokkoPostWithImage:(NSString*)image_key {
    
    // SETUP PARAMETERS
    NSString *api_base = @"http://ec2-54-187-34-224.us-west-2.compute.amazonaws.com";
    NSString *api_endpoint = @"/posts/";
    NSString *url = [api_base stringByAppendingString:api_endpoint];
    
    NSString *user_id = [SSKeychain passwordForService:serviceUserID account:account];
    NSString *auth_key = [SSKeychain passwordForService:serviceAuthKey account:account];
    NSString *geotext = self.organization_name;
    if (numberOfVerifiedOrgs == 1) {
        geotext = self.geotagLabel.text;
    }
    
    // Activity Spinner
    CGPoint p = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2 - 150);
    UIActivityIndicatorView *indicator = [Utility setLoadingIndicator:self indicatorCentre:p];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:auth_key forHTTPHeaderField:@"X-API-KEY"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc]initWithCapacity:10];
    [params setObject:user_id forKey:@"user_id"];
    [params setObject:self.organization_id forKey:@"organization_id"];
    [params setObject:self.messageTextView.text forKey:@"message"];
    [params setObject:image_key forKey:@"image_key"];
    [params setObject:geotext forKey:@"location"];
    
    [manager POST:url
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              //NSLog(@"JSON: %@", responseObject);
              NSLog(@"Trying to Post: %@ %@ %@ %@ %@", user_id, self.organization_id, self.messageTextView.text, image_key, self.geotagLabel.text);
              
              NSDictionary *dict = [responseObject objectAtIndex:0];
              NSString *type = dict[@"type"];
              
              // If Succesful, go to verification view
              [Utility stopIndicatorAnimating:indicator];
              
              if ([type isEqualToString:@"success"]) {
                  // Get the Post ID
                  // Right now nothing happens to the user :(
                  NSLog(@"Delegate and Create New Post");
                  [self.delegate newPostCreated];
                  [self.navigationController popViewControllerAnimated:TRUE];
              }
              // If Unsuccessful, alert user
              else {
                  // Check error code
                  NSNumber *code = [dict[@"response"] valueForKey:@"code"];
                  NSString *message = [dict[@"response"] valueForKey:@"message"];
                  if ([code integerValue] == 11) {
                      NSLog(@"Error message: %@",message);
                      //[self accountAlreadyExistsPopUp];
                  }
                  else if ([code integerValue] == 1) {
                      NSLog(@"Authentication Error: %@",message);
                      NSLog(@"Your Auth_Key is: %@", auth_key);
                      NSLog(@"Your user_id is: %@", user_id);
                  }
              }
              
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error: %@", error);
              [Utility stopIndicatorAnimating:indicator];
          }];
}

/*
 *  LOCATION METHODS
 *
 */

-(void) getLocation{
    [locationManager startUpdatingLocation];
}

-(void) locationManager: (CLLocationManager *) manager didFailWithError:(NSError *)error{
    
    NSLog(@"Error: Something Went Wrong. Couldn't update your location");
    
    return;
}

-(void) locationManager: (CLLocationManager *) manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    
    CLLocation *location = newLocation;
    
    if(!geocoder){
        geocoder = [[CLGeocoder alloc]init];
    }
    NSLog(@"%@",location);
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error){
            NSLog(@"Error: Reverse Geocoding failed!");
            return;
        }
        
        //That means this coordinate exists
        if (placemarks && placemarks.count > 0)
        {
            CLPlacemark *placemark = placemarks[0];
            
            NSDictionary *addressDictionary = placemark.addressDictionary;
            
            NSLog(@"%@ ", addressDictionary);
            NSString *address = [addressDictionary
                                 objectForKey:(NSString *)kABPersonAddressStreetKey];
            NSString *city = [addressDictionary
                              objectForKey:(NSString *)kABPersonAddressCityKey];
            NSString *state = [addressDictionary
                               objectForKey:(NSString *)kABPersonAddressStateKey];
            NSString *zip = [addressDictionary
                             objectForKey:(NSString *)kABPersonAddressZIPKey];
            
            
            NSLog(@"%@ %@ %@ %@", address,city, state, zip);
            
            [self.geotagLabel setText:[NSString stringWithFormat:@"@%@, %@",city,state]];
            [self.geotagLabel setHidden:NO];
            
        }
        return;
    }];
    
}

/*
 *  MESSAGE TEXT VIEW METHODS
 *
 */

- (void)textViewDidBeginEditing:(UITextView *)textView {
    NSString *defaultMessage= @"Share an idea or thought";

    if ([textView.text isEqualToString:defaultMessage]) {
        textView.text = @"";
    }
}


/*
 *  CAMERA METHODS
 *
 */

-(BOOL)launchCameraControllerFromViewController:(UploadImageViewController *)controller usingDelegate:(id<UIImagePickerControllerDelegate, UINavigationControllerDelegate>)delegate{
    
    //User gets to snap their own photo with the camera app
    if (cameraSourceChosen){
        BOOL cameraExists = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    
        if (!cameraExists||delegate==nil||controller==nil){
            NSLog(@"That sucks, you have no camera. get off that ipod shuffle");
            
            // JUST SET IT AS THE SF PICTURE
            NSString * firstImage = self.imageOrder[0];
            if ([firstImage isEqualToString:@"userChosenImage"]){
                [self.stockImages removeObjectForKey:@"userChosenImage"];
                [self.stockImages setObject:[UIImage imageNamed:@"SF-Pic.jpg"] forKey:@"userChosenImage"];
            }
            else {
                [self.imageOrder insertObject:@"userChosenImage" atIndex:0];
                [self.stockImages setObject:[UIImage imageNamed:@"SF-Pic.jpg"] forKey:@"userChosenImage"];
            }
            self.imageFileName = @"SF-Pic.jpg";
            return NO;
        }
    
        UIImagePickerController *camController = [[UIImagePickerController alloc]init];
        camController.sourceType = UIImagePickerControllerSourceTypeCamera;
    
        //specify which media types should this image picker controller expect
        camController.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:camController.sourceType];
        //don't give them image editing options
        camController.allowsEditing = NO;
    
        camController.delegate = delegate;
    
        [controller presentViewController:camController animated:YES completion:nil];
    
        return YES;
    }
    //user chooses a photo from the media library.
    else if (librarySourceChosen){
        BOOL browserExists = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
        
        if (!browserExists||delegate==nil||controller==nil){
            NSLog(@"Error: Media Browser does not exist or cannot be detected.");
            
            return NO;
        }
        
        UIImagePickerController *libController = [[UIImagePickerController alloc] init];
        libController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        libController.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:libController.sourceType];
        libController.allowsEditing =NO;
        libController.delegate = delegate;
        
        [controller presentViewController: libController animated:YES completion:nil];
        
        return YES;
    }
    return NO;
}

-(void) imagePickerControllerDidCancel:(UIImagePickerController *) picker{
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *) info {
    
    //variables that store the image/movie object
    UIImage *rawImage, *scaledImage, *imageToSave;
    
    //media type of the image/movie captured.
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    NSURL *imagePath = [info objectForKey:UIImagePickerControllerMediaURL];
    
    //saves the filename of the image just captured
    self.imageName = [imagePath lastPathComponent];
    
    if(CFStringCompare((CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo){
        
        scaledImage = (UIImage *) [info objectForKey:UIImagePickerControllerEditedImage];
        rawImage = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage];
        
        if(scaledImage){
            imageToSave = scaledImage;
        }
        else{
            imageToSave = rawImage;
        }
        
        // MAGICAL METHOD THAT MAKES IMAGE SQUARE
        CGFloat side = 320;
        imageToSave = [UIImageUtilities squareImageFromImage:imageToSave withSide:side];
        
        // Saving to Photo Roll
        if (cameraSourceChosen) {
            UIImageWriteToSavedPhotosAlbum(imageToSave, nil, nil, nil);
        }
        
        self.imageFileName = @"vokko_camera";
    }
    
    else if(CFStringCompare((CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo){
        NSString * moviePath = (NSString *) [[info objectForKey:UIImagePickerControllerMediaURL]path];
        
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(moviePath)){
            UISaveVideoAtPathToSavedPhotosAlbum(moviePath, nil, nil, nil);
        }
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    //make image 640x640
    NSString * firstImage = self.imageOrder[0];
    if ([firstImage isEqualToString:@"userChosenImage"]){
        [self.stockImages removeObjectForKey:@"userChosenImage"];
        [self.stockImages setObject:imageToSave forKey:@"userChosenImage"];
    }
    else {
        [self.imageOrder insertObject:@"userChosenImage" atIndex:0];
        [self.stockImages setObject:imageToSave forKey:@"userChosenImage"];
    }
    
    // Bring User Back To First Page
    PageContentViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)GetImageButton:(UIButton *)sender {
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:@"Select photo option:" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                            @"Camera",
                            @"Photo Library",
                            nil];
    popup.tag = 1;
    [popup showInView:[UIApplication sharedApplication].keyWindow];
}


- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    //resets flags to NO once actionSheet pops up
    cameraSourceChosen = NO;
    librarySourceChosen = NO;
    
    switch (popup.tag) {
        case 1: {
            switch (buttonIndex) {
                case 0:
                    cameraSourceChosen = YES;
                    break;
                case 1:
                    librarySourceChosen = YES;
                    break;
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
    
    // Now Launch!
    [self launchCameraControllerFromViewController:self usingDelegate:self];
}




/*
 * PAGE VIEW CONTROLLER FUNCTIONS
 *
 */

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PageContentViewController*) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PageContentViewController*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.imageOrder count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}


- (PageContentViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.imageOrder count] == 0) || (index >= [self.imageOrder count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    PageContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageContentViewController"];
    
    
    
    NSString *image_key = self.imageOrder[index];
    UIImage *image = [self.stockImages objectForKey:image_key];
    pageContentViewController.image = image;
    pageContentViewController.pageIndex = index;
    
    return pageContentViewController;
}


// Gestures
- (IBAction)swipeRight:(UISwipeGestureRecognizer *)recognizer {
    int currentPage = [[self.pageViewController.viewControllers objectAtIndex:0] pageIndex];
    
    // Don't do anything if we're already at the first page
    if (currentPage <= 0) {
        return;
    }
    
    // Instead get the view controller of the previous page
    PageContentViewController *newInitialViewController = (PageContentViewController *)[self viewControllerAtIndex:(currentPage - 1)];
    NSArray *initialViewControllers = [NSArray arrayWithObject:newInitialViewController];
    
    // Do the setViewControllers: again but this time use direction animation:
    [self.pageViewController setViewControllers:initialViewControllers direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
    
}

// Gestures
- (IBAction)swipeLeft:(UISwipeGestureRecognizer *)recognizer {
    int currentPage = [[self.pageViewController.viewControllers objectAtIndex:0] pageIndex];
    if ( (currentPage != maxNumberOfStockImages-1) &&
        (currentPage == self.imageOrder.count-2)) {
        
        numImagesCurrentlyLoaded = numImagesCurrentlyLoaded + 3;
        
        if (numImagesCurrentlyLoaded > maxNumberOfStockImages) {
            numImagesCurrentlyLoaded = maxNumberOfStockImages;
        }
        [self getMoreStockImages];
        
    }
    // Don't do anything if we're already at the first page
    if (currentPage >= [self.stockImages count] -1) {
        return;
    }
    
    // Instead get the view controller of the next page
    PageContentViewController *newInitialViewController = (PageContentViewController *)[self viewControllerAtIndex:(currentPage + 1)];
    NSArray *initialViewControllers = [NSArray arrayWithObject:newInitialViewController];
    
    // Do the setViewControllers: again but this time use direction animation:
    [self.pageViewController setViewControllers:initialViewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    
}



/*
 * HELPER FUNCTIONS
 *
 */

- (UIImage *)imageByCroppingImage:(UIImage *)image toSize:(CGSize)size
{
    double x = (image.size.width - size.width) / 2.0;
    double y = (image.size.height - size.height) / 2.0;
    
    CGRect cropRect = CGRectMake(x, y, size.height, size.width);
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
    
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return cropped;
}

+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


-(void) orgSelected:(NSString*)org_name withID:(NSNumber*)org_id {
    NSLog(@"getting selection back at Upload View %@ %@",org_name,org_id);
    self.organization_id = org_id;
    self.organization_name = org_name;
}

//attach an organization to the specific post
-(IBAction)selectAnOrganization:(id)sender {
    [self performSegueWithIdentifier: @"selectFromUpload" sender: self];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"selectFromUpload"]) {
        SelectOrgTableViewController *destViewController = segue.destinationViewController;
        destViewController.delegate = self;
        destViewController.organization_list = verified_organizations_list; //Pass forward
    }
}

@end
