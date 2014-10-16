//
//  TLMasterViewController.m
//  UITableViewCell-Swipe-for-Options
//
//  Created by Ash Furrow on 2013-07-29.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//  Modified by Victor Zhang
//

#import "OrganizationsTableViewController.h"
#import "TLSwipeForOptionsCell.h"
#import "AFHTTPRequestOperationManager.h"
#import "Organization.h"
#import "UIColor+HexColors.h"
#import "OrgTableViewCell.h"

@interface OrganizationsTableViewController () <TLSwipeForOptionsCellDelegate, UIActionSheetDelegate> {
    NSMutableArray *organization_list;
}

// We need to keep track of the most recently selected cell for the action sheet.
@property (nonatomic, weak) UITableViewCell *mostRecentlySelectedMoreCell;

@end

@implementation OrganizationsTableViewController {
    NSString *newestAddedOrg;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.allowsSelectionDuringEditing = YES;
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    
    //Prepare Listener To Hide Keyboard
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];

    // Listener for New Organization Added
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(addNewUnverifiedOrganization:)
                                                 name:@"addNewUnverifiedOrganization"
                                               object:nil];
    // Pull To Refresh
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc]
                                        init];
    refreshControl.tintColor = [UIColor colorWithHexString:@"fcd146"];
    [refreshControl addTarget:self action:@selector(pullToRefreshed) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    // API Call from Server to get all Orgs
    [self loadOrganizations];
}

-(void)dismissKeyboard {
    [self.view endEditing:YES];
}

-(void) pullToRefreshed {
    NSLog(@"pulling to refresh feed :)");
    [self performSelector:@selector(loadOrganizations) withObject:nil
               afterDelay:0.25];
}

#pragma mark - SETUP
-(void) loadOrganizations {
    
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
             if (!organization_list) {
                 organization_list = [[NSMutableArray alloc] init];
             }
             else{
                 [organization_list removeAllObjects];
             }
             
             NSDictionary *dict = [responseObject objectAtIndex:0];
             if ([dict[@"type"] isEqualToString:@"success"]) {
                 NSArray *orgs = dict[@"value"];
                 for ( NSDictionary *org in orgs) {
                     Organization *returnOrg = [Organization organizationFromJSON:org];
                     [organization_list insertObject:returnOrg atIndex:0];
                 }
                 
                 // Now reload the data
                 [self.tableView reloadData];
                 [self setSelectedOrganization];
                 [self.refreshControl endRefreshing];
             }
             else {
                 // Check error code
                 NSNumber *code = [dict[@"response"] valueForKey:@"code"];
                 NSString *message = [dict[@"response"] valueForKey:@"message"];
                 
                 if ([code intValue] == 1){
                     // Authentication error, boot the user back to Login :(
                     NSLog(@"Authentication Error... time to go back and relogin!");
                     
                 }
                 NSLog(@"error is: %@ %@", code, message);
             }
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
         }];
}


-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    // Need to do this to keep the view in a consistent state (layoutSubviews in the cell expects itself to be "closed")
    [[NSNotificationCenter defaultCenter] postNotificationName:TLSwipeForOptionsCellEnclosingTableViewDidBeginScrollingNotification object:self.tableView];
}
#pragma mark - DATA PASSBACKS
- (void)addNewUnverifiedOrganization:(NSNotification *)notification {
    NSDictionary *theData = [notification userInfo];
    NSString *organization_name =theData[@"organization_name"];
    NSString *organization_id = theData[@"organization_id"];
    
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber *num_org_id = [f numberFromString:organization_id];
    
    NSLog(@"Data Passback: %@ %@",organization_name, num_org_id);
    
    [self insertNewObject:organization_name withOrgID:num_org_id];
}

#pragma mark - MODEL ACCESS
// Inserts a new object into the _objects array.
- (void)insertNewObject:(NSString *)org_name withOrgID:(NSNumber*)org_id
{
    // Move the code below to what comes back from the next view
    if (!organization_list) {
        organization_list = [[NSMutableArray alloc] init];
    }
    
    Organization *org_object = [Organization newOrganization:org_name withImage:@"none" withID:org_id];
    [organization_list insertObject:org_object atIndex:0];
    [self.tableView reloadData];
    [self setSelectedOrganization];

    // Need to call this whenever we scroll our table view programmatically
    [[NSNotificationCenter defaultCenter] postNotificationName:TLSwipeForOptionsCellEnclosingTableViewDidBeginScrollingNotification object:self.tableView];
}

-(void) setSelectedOrganization {
    //Organization *temp_org = [organization_list objectAtIndex:0];
    //NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    //[standardDefaults setObject:[temp_org organization_id] forKey:@"organization_id"];
}


#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return organization_list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TLSwipeForOptionsCell *cell = (TLSwipeForOptionsCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    Organization *org = organization_list[indexPath.row];
    
    NSString * org_name = [org name];
    NSNumber * verified = [org verified];
    
    //if organization name too long, shorten and add "..."
    if (org_name.length>22){
        org_name = [org_name substringToIndex:22];
        [org_name stringByAppendingString:@"..."];
    }
    cell.textLabel.text = org_name;
    
    if ([verified intValue] == 0) {
        NSLog(@"Unverified company: %@ %d", org_name, [verified intValue]);
        [cell.cellImage setImage:[UIImage imageNamed:@"unverified.png"]];
    }
    
    cell.delegate = self;
    
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

- (IBAction)unwindToOrganizations:(UIStoryboardSegue *)segue {
    
}

#pragma UIScrollViewDelegate Methods

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [[NSNotificationCenter defaultCenter] postNotificationName:TLSwipeForOptionsCellEnclosingTableViewDidBeginScrollingNotification object:scrollView];
}

#pragma mark - TLSwipeForOptionsCellDelegate Methods 

-(void)cellDidSelectDelete:(TLSwipeForOptionsCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    [organization_list removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}


@end
