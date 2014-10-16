//
//  InboxfeedTableViewController.m
//  aventador
//
//  Created by Victor Zhang on 2014-04-20.
//  Copyright (c) 2014 Vokko. All rights reserved.
//

#import "InboxfeedTableViewController.h"
#import "DetailedViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "UIColor+HexColors.h"

#import "UploadImageViewController.h"
#import "SettingsTableViewController.h"
#import "Post.h"
#import "Utility.h"
#import "OrganizationItem.h"
#import "Organization.h"
#import "Post.h"
#import "PostItem.h"
#import "AppDelegate.h"
#import "REMenu.h"
#import "UIScrollView+GifPullToRefresh.h"
#import "RegisterViewController.h"


#import "SSKeychain.h"

@interface InboxfeedTableViewController ()

    @property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
    @property (strong, readwrite, nonatomic) REMenu *menu;

@end

@implementation InboxfeedTableViewController {
    int displayMyPosts;
    NSMutableArray *posts;
    
    //Loader
    NSMutableArray *drawing_imgs;
    NSMutableArray *loading_imgs;
    
    // Gradient Drawing
    BOOL gradientNotApplied;
    
    // Dynamic Loading
    int numberOfRowsDisplayed;
    int numberOfSections;
    BOOL isLoadingSomeMore;
    NSMutableArray *displayedPosts;
    
    Post *selectedPost;
    NSNumber *my_user_id;
    
    NSMutableDictionary *post_ids; // Duplicates
    NSMutableDictionary *image_files;

    // Org Stuff
    NSMutableArray *org_list_from_server;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
            // Load Stuff Here
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // NAVIGATION CONTROLLER
    UIImage *image = [UIImage imageNamed:@"vokko_logo"];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:image];
    
    // REMENU LOADING
    [self setupREMenu];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"hamburger"] style:UIBarButtonItemStyleBordered target:self action:@selector(toggleMenu)];
    
    // CORE DATA
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    self.managedObjectContext = appDelegate.managedObjectContext;

    // ORGANIZATIONS
    org_list_from_server = [[NSMutableArray alloc]init];
    
    // POSTS
    posts = [[NSMutableArray alloc]init];
    displayedPosts = [[NSMutableArray alloc]init];
    post_ids = [[NSMutableDictionary alloc] init];
    image_files = [[NSMutableDictionary alloc] init];

    displayMyPosts = 0;
    numberOfRowsDisplayed = 3;
    numberOfSections = 1;
    isLoadingSomeMore = NO;
    
    gradientNotApplied = YES;
    
    
    // Pull To Refresh
    /*
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc]
                                        init];
    refreshControl.tintColor = [UIColor colorWithHexString:@"fcd146"];
    [refreshControl addTarget:self action:@selector(pullToRefreshed) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
     */
    drawing_imgs = [[NSMutableArray alloc]init];
    loading_imgs = [[NSMutableArray alloc]init];

    for (NSUInteger i  = 0; i <= 7; i++) {
        NSString *fileName = [NSString stringWithFormat:@"v_loader-%d.png",i];
        [drawing_imgs addObject:[UIImage imageNamed:fileName]];
        [loading_imgs addObject:[UIImage imageNamed:fileName]];

    }
    [self.tableView addPullToRefreshWithDrawingImgs:drawing_imgs andLoadingImgs:loading_imgs andActionHandler:^{
        [self.tableView performSelector:@selector(didFinishPullToRefresh) withObject:nil afterDelay:2];
        
    }];
    
    
    // ACTIONS ORDERING
    [self updateTable];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    
}

-(void) didFinishPullToRefresh {
    
}

-(void) setupREMenu {
    
    // If we ever wanted to tint the top bar.
    /*
     if (REUIKitIsFlatMode()) {
     [self.navigationBar performSelector:@selector(setBarTintColor:) withObject:[UIColor colorWithRed:0/255.0 green:213/255.0 blue:161/255.0 alpha:1]];
     self.navigationBar.tintColor = [UIColor whiteColor];
     }*/
    
    REMenuItem *homeItem = [[REMenuItem alloc] initWithTitle:@"Inbox"
                                                       image:[UIImage imageNamed:@"menu_home"]
                                            highlightedImage:nil
                                                      action:^(REMenuItem *item) {
                                                          NSLog(@"Item: %@", item);
                                                          displayMyPosts = 0;
                                                          [self removeAllPostsAndCleanup];
                                                          [self updateTable];
                                                          [self retractMenuIfPossible];
                                                          UIImage *image = [UIImage imageNamed:@"vokko_logo"];
                                                          self.navigationItem.titleView = [[UIImageView alloc] initWithImage:image];

                                                      }];
    
    REMenuItem *myPostItem = [[REMenuItem alloc] initWithTitle:@"Outbox"
                                                         image:[UIImage imageNamed:@"menu_myPosts"]
                                              highlightedImage:nil
                                                        action:^(REMenuItem *item) {
                                                            NSLog(@"Item: %@", item);
                                                            displayMyPosts = 1;
                                                            NSLog(@"removing tables");
                                                            [self removeAllPostsAndCleanup];
                                                            NSLog(@"updating tables");
                                                            [self updateTable];
                                                            NSLog(@"retracting if possible");
                                                            [self retractMenuIfPossible];
                                                            self.navigationItem.titleView = nil;
                                                            [self updateNavTitle:@"Outbox"];
                                                        }];
    
    /*REMenuItem *notificationItem = [[REMenuItem alloc] initWithTitle:@"Activities"
                                                               image:[UIImage imageNamed:@"menu_activity"]
                                                    highlightedImage:nil
                                                              action:^(REMenuItem *item) {
                                                                  NSLog(@"Item: %@", item);
                                                                  [self retractMenuIfPossible];
                                                                  self.navigationItem.titleView = nil;
                                                                  [self updateNavTitle: @"Notifications"];

                                                              }];*/
    
    //notificationItem.badge = @"2";
    
    REMenuItem *settingsItem = [[REMenuItem alloc] initWithTitle:@"Settings"
                                                           image:[UIImage imageNamed:@"menu_settings"]
                                                highlightedImage:nil
                                                          action:^(REMenuItem *item) {
                                                              NSLog(@"Item: %@", item);
                                                              [self retractMenuIfPossible];
                                                              [self performSegueWithIdentifier: @"settingsFromInbox" sender: self];

                                                          }];
    
    homeItem.tag = 0;
    myPostItem.tag = 1;
    //notificationItem.tag = 2;
    settingsItem.tag = 2;
    
    self.menu = [[REMenu alloc] initWithItems:@[homeItem, myPostItem, settingsItem]];
    
    
    NSShadow* shadow = [NSShadow new];
    shadow.shadowOffset = CGSizeMake(0.0f, 1.0f);
    shadow.shadowColor = [UIColor whiteColor];
    [[UINavigationBar appearance] setTitleTextAttributes: @{
                                                            NSForegroundColorAttributeName: [UIColor colorWithHexString:@"004e83"],
                                                            NSFontAttributeName: [UIFont fontWithName:@"montserrat" size:20.0f],
                                                            NSShadowAttributeName: shadow
                                                            }];
    
    // Background view Stage Effect
    self.menu.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    self.menu.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.menu.backgroundView.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.600];
    
    //self.menu.imageAlignment = REMenuImageAlignmentRight;
    self.menu.closeOnSelection = NO;
    self.menu.appearsBehindNavigationBar = NO; // Affects only iOS 7
    
    
    if (!REUIKitIsFlatMode()) {
        self.menu.cornerRadius = 4;
        self.menu.shadowRadius = 4;
        self.menu.shadowColor = [UIColor blackColor];
        self.menu.shadowOffset = CGSizeMake(0, 1);
        self.menu.shadowOpacity = 1;
    }
    
    // Blurred background in iOS 7
    //
    self.menu.liveBlur = YES;
    self.menu.liveBlurBackgroundStyle = REMenuLiveBackgroundStyleDark;
    
    self.menu.imageOffset = CGSizeMake(5, -1);
    self.menu.waitUntilAnimationIsComplete = NO;
    self.menu.badgeLabelConfigurationBlock = ^(UILabel *badgeLabel, REMenuItem *item) {
        badgeLabel.backgroundColor = [UIColor colorWithRed:0 green:179/255.0 blue:134/255.0 alpha:1];
        badgeLabel.layer.borderColor = [UIColor colorWithRed:0.000 green:0.648 blue:0.507 alpha:1.000].CGColor;
    };
    
    
    [self.menu setClosePreparationBlock:^{
        NSLog(@"Menu will close");
    }];
    
    [self.menu setCloseCompletionHandler:^{
        NSLog(@"Menu did close");
    }];
}

-(void) updateNavTitle:(NSString *) title {
    self.navigationItem.title = title;
}


#pragma mark - Table view data source
-(void) removeAllPostsAndCleanup {
    [posts removeAllObjects];
    [post_ids removeAllObjects];
    [displayedPosts removeAllObjects];
    numberOfSections = 1;
    isLoadingSomeMore = NO;
}

-(void) pullToRefreshed {
    NSLog(@"pulling to refresh feed :)");
    [self performSelector:@selector(updateTable) withObject:nil
               afterDelay:0.25];
}

-(void) updateTable {
    /*  The operations performed below are:
     *    1)  API_Call to /posts/ to retrieve information
     *    2)  Async hit to Parse for all Images
     */
    
    NSString *api_endpoint;
    if (displayMyPosts == 0) {
        api_endpoint = @"/posts/";
    }
    else {
        api_endpoint = @"/posts/submitted/";
    }
    NSString *url = [api_url_base stringByAppendingString:api_endpoint];
    
    // Get Keychain Data
    NSString *auth_key = [SSKeychain passwordForService:serviceAuthKey account:account];
    NSString *user_id = [SSKeychain passwordForService:serviceUserID account:account];
    
    if (user_id == nil || auth_key == nil) {
        abort();
    }
    
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterNoStyle];
    my_user_id = [f numberFromString:user_id];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:auth_key forHTTPHeaderField:@"X-API-KEY"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc]initWithCapacity:10];
    [params setObject:user_id forKey:@"user_id"];
    [manager GET:url
      parameters:params
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             // LOG DATA
             NSLog(@"JSON: %@", responseObject);
             
             NSDictionary *dict = [responseObject objectAtIndex:0];
             // SUCCESS
             if ([dict[@"type"] isEqualToString:@"success"]) {
                 
                 NSArray *values = dict[@"value"];
                 NSLog(@"[Success]... DEJSON the Posts");
                 for ( NSDictionary* post_json in values) {
                     NSNumber *postID = [post_json valueForKey:@"post_id"];
                     NSString *post_id = [NSString stringWithFormat:@"%d", [postID intValue]];

                     // If no duplicates post_ids found, add new post
                     if (![post_ids objectForKey:post_id]) {
                         Post *post = [Post newPostFromJSON:post_json];
                         [posts addObject:post];
                         [post_ids setObject:@"1" forKey:post_id];
                     }
                 }
                 
                 // Clear the table so nothing appends and it's a fresh pull :)
                 [self loadSomeMore];
                 
                 // REMOVED BECAUSE MARK ALREADY SORTS BY UNREAD AND THEN DATE
                 // Sort Posts by Most Recent Date
                 /* NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:FALSE];
                 [posts sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
                 */
                 
                 // Now Refresh the Table!
                 [self.inboxFeedTableView reloadData];
                 //[self.refreshControl endRefreshing];
                 
             }
             else {
                 // Check error code
                 NSNumber *code = [dict[@"response"] valueForKey:@"code"];
                 
                 // Create an UIAlert Message and show it
                 UIAlertView * errorMsg = [UIAlertView createErrorMessage:[code integerValue]];
                 [errorMsg show];
                 
                 if ([code intValue] == 1){
                     // Authentication error, boot the user back to Login :(
                     NSLog(@"Authentication Error... time to go back and relogin!");
                     [SSKeychain deletePasswordForService:serviceAuthKey account:account];
                     [SSKeychain deletePasswordForService:serviceUserID account:account];
                     NSLog(@"Deleted authKey and UserID in keychain");
                     
                     RegisterViewController *registerVC=[[UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"registerVC"];
                     AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                     appDelegate.window.rootViewController = registerVC;
                     
                     
                     
                 }
             }

         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
         }];
}

-(void) getImageFilesFromParse:(NSString *) image_key {
    // Does the Image Currently Exist? If Not, Let's Download!
    if ([image_files objectForKey:image_key] == nil) {
        
        // Download from our Stock Images
        NSString *prefix = [image_key substringToIndex:3];
        if ([prefix isEqualToString:@"img"]){
            NSString *image_number = [image_key substringWithRange:NSMakeRange(4,1)];
            NSNumber *imageNumber = [NSNumber numberWithInteger:[image_number intValue]];
            
            PFQuery *query = [PFQuery queryWithClassName:@"StockImages"];
            [query whereKey:@"imageNumber" equalTo:imageNumber];
            query.cachePolicy = kPFCachePolicyCacheElseNetwork;
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    // The find succeeded. Now let's hash all UIImages using their image key
                    NSLog(@"Successfully retrieved an image");
                    PFObject *postObject = [objects objectAtIndex:0];
                    // Get UIImage from Parse in Background Processs
                    PFFile *theImage = postObject[@"imageFile"];
                    // Image must be downloaded.
                    
                    [theImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                        if (!error) {
                            UIImage *photo = [UIImage imageWithData:data];
                            [image_files setObject:photo forKey:image_key];
                            
                            NSLog(@"[STOCK IMAGE DOWNLOADED] with key: %@", image_key);
                            [self.inboxFeedTableView reloadData];
                        }
                    }];
                    
                    // Now Refresh the Table!
                    [self.inboxFeedTableView reloadData];
                    //[self.refreshControl endRefreshing];
                    
                } else {
                    // Log details of the failure
                    NSLog(@"Error retrieving image for key: %@... %@ %@", image_key, error, [error userInfo]);
                }
            }];

        }
        // Don't have it! time to hit PARSE :)
        else {
            PFQuery *query = [PFQuery queryWithClassName:@"ImageFile"];
            query.cachePolicy = kPFCachePolicyCacheElseNetwork;
            [query getObjectInBackgroundWithId:image_key block:^(PFObject *postObject, NSError *error) {
                if (!error) {
                    // The find succeeded. Now let's hash all UIImages using their image key
                    NSLog(@"Successfully retrieved an image");
                    
                    // Get UIImage from Parse in Background Processs
                    PFFile *theImage = postObject[@"image_file"];
                    // Image must be downloaded.
                    
                    [theImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                        if (!error) {
                            UIImage *photo = [UIImage imageWithData:data];
                            [image_files setObject:photo forKey:image_key];
                            
                            NSLog(@"[IMAGE DOWNLOADED] with key: %@", image_key);
                            [self.inboxFeedTableView reloadData];
                        }
                    }];
                    
                    // Now Refresh the Table!
                    [self.inboxFeedTableView reloadData];
                    //[self.refreshControl endRefreshing];
                    
                    
                } else {
                    // Log details of the failure
                    NSLog(@"Error retrieving image for key: %@... %@ %@", image_key, error, [error userInfo]);
                }
            }];
        }
    }
}


-(void) newPostCreated {
    [self updateTable];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return displayedPosts.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellReuseIdentifier = @"PostReuseID";
    PostCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[PostCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifier]
        ;
    }
    
    Post *p = [displayedPosts objectAtIndex:indexPath.row];
    cell.messageLabel.text = p.message;
    cell.locationLabel.text = p.location;

    // Configure photo
    NSString *image_key = p.image_key;
    UIImage *photo;
    if ([image_files objectForKey:image_key] == nil) {
        photo = [UIImage imageNamed:@"img-placeholder.png"];
    }
    else {
        photo = [image_files objectForKey:image_key];
    }
    cell.photoImageView.image = photo;

    // Gradient for Photo
    // Set image over layer
    if (gradientNotApplied) {
        NSLog(@"Applying gradient");
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = cell.photoImageView.frame;

        // Add colors to layer
        UIColor *endColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.25];
        UIColor *centerColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
        UIColor *beginColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:0.0];
        gradient.colors = [NSArray arrayWithObjects:
                           (id)[beginColor CGColor],
                           (id)[centerColor CGColor],
                           (id)[endColor CGColor],
                           nil];

        [cell.photoImageView.layer insertSublayer:gradient atIndex:0];
        gradientNotApplied = NO;
    }
    
    // Labels
    cell.discussNumberLabel.text = [p.num_comments stringValue];
    cell.noLabel.hidden = NO;
    cell.yesLabel.hidden = NO;
    cell.loveLabel.hidden = YES;
    cell.lovePercentLabel.hidden = YES;
    cell.notSoLoveLabel.hidden = YES;
    cell.notSoLovePercentLabel.hidden = YES;

    // Set Buttons
    cell.loveButton.tag = indexPath.row;
    cell.yesLabelButton.tag = indexPath.row;
    cell.noLabelButton.tag = indexPath.row;
    cell.notSoLoveButton.tag = indexPath.row;
    
    // Preset Buttons Pressed By the User
    if ([p.user_response intValue] != 0) {  // User Has Note Pressed Anything Before
        if ([p.user_response intValue] == 1) {
            cell.loveButton.selected = YES;
        } else {
            cell.notSoLoveButton.selected = YES;
        }
        cell.noLabel.hidden = YES;
        cell.yesLabel.hidden = YES;
        cell.loveLabel.hidden = NO;
        cell.lovePercentLabel.hidden = NO;
        cell.lovePercentLabel.text = [[NSString stringWithFormat:@"%d", [p.like_percent intValue]] stringByAppendingString:@"%"];
        cell.notSoLoveLabel.hidden = NO;
        cell.notSoLovePercentLabel.hidden = NO;
        cell.notSoLovePercentLabel.text = [[NSString stringWithFormat:@"%d", [p.dislike_percent intValue]] stringByAppendingString:@"%"];

    }
    
    cell.noLabel.tag = indexPath.row;
    cell.yesLabel.tag = indexPath.row;
    
    return cell;
}

- (NSIndexPath *)tableView:(UITableView*)tableView willSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    NSLog(@"row selected is: %d", indexPath.row);
    selectedPost = [posts objectAtIndex:indexPath.row];
    return indexPath;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"row is: %d", indexPath.row);
}

- (void)scrollViewDidScroll: (UIScrollView *)scroll {
    // Checking for three conditions:
    //   1) We must currently not be loading any new rows. View did scroll called alot so we slow it down.
    //   2) Don't call this when you have no posts... which is when the view is displayed for the first time.
    //   3) Don't call this when you're already at your max number of posts shown.
    
    if (!isLoadingSomeMore && posts.count !=0 && (displayedPosts.count != posts.count)) {
        // Create Spinner!
        NSInteger currentOffset = scroll.contentOffset.y;
        NSInteger maximumOffset = scroll.contentSize.height - scroll.frame.size.height;
        
        // Change 10.0 to adjust the distance from bottom
        if (maximumOffset - currentOffset <= 10.0) {
            isLoadingSomeMore = YES;
            numberOfSections++;

            // Show Have Nice Spinner... but don't yet
            [self loadSomeMore];
        }
         
         
    
    }
}

-(void) loadSomeMore {
    [displayedPosts removeAllObjects];
    for (int i = 0; i < (numberOfRowsDisplayed * numberOfSections); i++) {
        if (i > posts.count -1)
            break;
        Post * obj = [posts objectAtIndex:i];
        [displayedPosts addObject:obj];
        
        // Get Image From PARSE
        [self getImageFilesFromParse: obj.image_key];
    }
    [self.tableView reloadData];
    isLoadingSomeMore = NO;
}

/*
 *  BUTTON ACTIONS
 *
 */

#pragma mark - LIKE/DISLIKE API CALLS
-(void) viewedAPost:(int)response toRow:(int) row {
    //response should be "1 for yes" or "0 forno"
    Post *post = posts[row];

    // SETUP PARAMETERS
    NSString *api_endpoint = @"/posts/";
    NSString *url = [api_url_base stringByAppendingString:api_endpoint];
    
    NSNumber *org_id = post.organization_id;
    NSNumber *pid = post.post_id;

    NSString *user_id = [SSKeychain passwordForService:serviceUserID account:account];
    NSString *auth_key = [SSKeychain passwordForService:serviceAuthKey account:account];
    
    // Activity Spinner
    CGPoint p = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2 - 150);
    UIActivityIndicatorView *indicator = [Utility setLoadingIndicator:self indicatorCentre:p];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:auth_key forHTTPHeaderField:@"X-API-KEY"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc]initWithCapacity:10];
    [params setObject:user_id forKey:@"user_id"];
    [params setObject:pid forKey:@"post_id"];
    [params setObject:org_id forKey:@"organization_id"];
    if (response == 1)
        [params setObject:@"1" forKey:@"like_dislike"];
    else
        [params setObject:@"-1" forKey:@"like_dislike"];

    [manager PUT:url
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"JSON: %@", responseObject);
              NSLog(@"Sending a like/dislike to post: %@", pid);
              
              NSDictionary *dict = [responseObject objectAtIndex:0];
              NSString *type = dict[@"type"];
              if ([type isEqualToString:@"success"]) {
                  // If Succesful, that's that.
                  [Utility stopIndicatorAnimating:indicator];
              }
              // If Unsuccessful, alert user
              else {
                  // Check error code
                  NSNumber *code = [dict[@"response"] valueForKey:@"code"];
                  NSString *message = [dict[@"response"] valueForKey:@"message"];
                  if ([code integerValue] == 11) {
                      NSLog(@"Error message: %@",message);
                      abort();
                  }
              }
              
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error: %@", error);
              [Utility stopIndicatorAnimating:indicator];
          }];
}


#pragma mark - BUTTON ACTIONS
-(void) showPercentLabelsAtRow:(NSInteger)row withChoice:(int) choice {
    // Choice = 1 means love,   = -1  means dislike
    
    //No Hide the YES/NO labels and show the Stats
    NSIndexPath *myIP = [NSIndexPath indexPathForRow:row inSection:0];
    PostCell *cell = (PostCell*)[self.inboxFeedTableView cellForRowAtIndexPath:myIP];
    
    Post * p = posts[row];
    cell.noLabel.hidden = YES;
    cell.yesLabel.hidden = YES;
    cell.loveLabel.hidden = NO;
    cell.lovePercentLabel.hidden = NO;
    cell.notSoLoveLabel.hidden = NO;
    cell.notSoLovePercentLabel.hidden = NO;
    
    if (choice == 1) //Loved It!
    {
        int dp = 100 - [p.like_percent intValue];
        cell.notSoLovePercentLabel.text = [[NSString stringWithFormat:@"%d",dp] stringByAppendingString:@"%"];
        cell.lovePercentLabel.text = [[p.like_percent stringValue] stringByAppendingString:@"%"];
    }
    else {
        int lp = 100 - [p.dislike_percent intValue];
        cell.lovePercentLabel.text = [[NSString stringWithFormat:@"%d",lp] stringByAppendingString:@"%"];
        cell.notSoLovePercentLabel.text = [[p.dislike_percent stringValue] stringByAppendingString:@"%"];
    }
}

- (IBAction)onLoveSelected:(UIButton*)sender {
    Post *p = posts[sender.tag];
    int user_response = [p.user_response intValue];

    if (user_response == 0) {
        // Update our Internal Cache that User Has Clicked
        p.user_response = [NSNumber numberWithInt: 1];
        [posts replaceObjectAtIndex:sender.tag withObject:p];

        [sender setSelected:YES];
        [self viewedAPost:1 toRow:sender.tag];
        
        // Show Labels
        [self showPercentLabelsAtRow:sender.tag withChoice:1];
    }
}

- (IBAction)onDislikeSelected:(UIButton*)sender {
    Post *p = posts[sender.tag];
    int user_response = [p.user_response intValue];
    
    NSLog(@"dislike");
    if (user_response == 0) {
        // Update our Internal Cache that User Has Clicked
        p.user_response = [NSNumber numberWithInt: -1];
        [posts replaceObjectAtIndex:sender.tag withObject:p];

        [sender setSelected:YES];
        
        [self viewedAPost:0 toRow:sender.tag];
        // Show Labels
        [self showPercentLabelsAtRow:sender.tag withChoice:-1];
    }
}

-(IBAction)onComposeButtonClicked:(id)sender {
    //Check if they are part of an organization
    
    // TAKE THIS LINE OUT LATER
    NSString *organization_id = @"2";
    
    if (organization_id != nil) {
        NSLog(@"Seguing to Post View");
        [self performSegueWithIdentifier: @"postFromInboxfeed" sender: self];
        
    }
    else {
        NSLog(@"user doesn't have any organizations...");
        // User has not joined an organization yet... ask them to join!
    }
}

#pragma mark - MENU
-(void) toggleMenu {
    NSLog(@"lol");
    
    if (self.menu.isOpen)
        return [self.menu close];
    
    [self.menu showFromNavigationController:self.navigationController];
}

-(void) retractMenuIfPossible {
    if (self.menu.isOpen)
        return [self.menu close];

}


#pragma mark - NAVIGATION

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"postFromInboxfeed"]) {
        // Pull up REMenu if it's down
        [self retractMenuIfPossible];
        
        UploadImageViewController *destViewController = segue.destinationViewController;
        destViewController.delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"detailedPostFromInbox"]) {
        NSLog(@"About to go in");
        DetailedViewController * destViewController = segue.destinationViewController;
        destViewController.post = selectedPost;
        destViewController.image = [image_files objectForKey:selectedPost.image_key];
        destViewController.user_id = my_user_id;
        destViewController.x_api_key = [SSKeychain passwordForService:serviceAuthKey account:account];
    }
}

- (IBAction)unwindToInboxFeed:(UIStoryboardSegue *)segue
{
    
}

@end
