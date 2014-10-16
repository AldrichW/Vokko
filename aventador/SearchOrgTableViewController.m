//
//  SearchOrgTableViewController.m
//  aventador
//
//  Created by Victor Zhang on 2014-05-02.
//  Copyright (c) 2014 Vokko. All rights reserved.
//

#import "SearchOrgTableViewController.h"
#import "AddOrganizationViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "Organization.h"

@interface SearchOrgTableViewController ()
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UITableView *searchOrganizationTableView;

@end

@implementation SearchOrgTableViewController {
    NSMutableArray *organization_list;
    NSMutableArray *searchResults;

}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadAllOrganizations];
    [self setupSearchResults];
}

// DISMISSING KEYBOARD
-(void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - Search
-(void) loadAllOrganizations {
    
    // Prepare parameters
    NSString *api_endpoint = @"/organizations/all/";
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
             NSLog(@"Organization/all/ request returned...");
             NSLog(@"JSON: %@", responseObject);
             
             //Count and add number of organizations
             if (!organization_list) {
                 organization_list = [[NSMutableArray alloc] init];
             }
             
             NSDictionary *dict = [responseObject objectAtIndex:0];
             if ([dict[@"type"] isEqualToString:@"success"]) {
             NSArray *orgs = dict[@"value"];
             for ( NSDictionary *org in orgs) {
                 NSString *org_name = org[@"name"];
                 NSNumber *org_id = org[@"organization_id"];
                 
                 Organization *org_object = [Organization newOrganization:org_name withImage:@"none" withID:org_id];
                 
                 //Should add this to core data
                 [organization_list insertObject:org_object atIndex:0];

             }
             
             [self.searchOrganizationTableView reloadData];
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

-(void) setupSearchResults {
    //searchResults = [NSMutableArray arrayWithCapacity:[orgList count]];
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"name contains[c] %@", searchText];
    searchResults = [[organization_list filteredArrayUsingPredicate:resultPredicate]mutableCopy];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}

#pragma mark - TableView


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [searchResults count];
        
    } else {
        return [organization_list count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SearchOrgTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    Organization *org = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        org = [searchResults objectAtIndex:indexPath.row];
    } else {
        org = [organization_list objectAtIndex:indexPath.row];
    }

    cell.textLabel.text = org.name;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier: @"joinOrganization" sender: self];
}

#pragma mark - Navigation

- (IBAction)unwindToSearchOrganizations:(UIStoryboardSegue *)segue {
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"preparing for Segue: %@", segue.identifier);
    
    if ([segue.identifier isEqualToString:@"joinOrganization"]) {
        
        NSIndexPath *indexPath = nil;
        Organization *org = nil;
        
        if (self.searchDisplayController.active) {
            indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
            org = [searchResults objectAtIndex:indexPath.row];
        } else {
            indexPath = [self.tableView indexPathForSelectedRow];
            org = [organization_list objectAtIndex:indexPath.row];
        }
        
        AddOrganizationViewController *destViewController = segue.destinationViewController;
        destViewController.organization_name = org.name;
        destViewController.organization_id = org.org_id;
    }
}


@end
