//
//  SettingsTableViewController.m
//  aventador
//
//  Created by Victor Zhang on 2014-04-21.
//  Copyright (c) 2014 Vokko. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "OrganizationsTableViewController.h"
#import "RegisterViewController.h"
#import "AppDelegate.h"
#import "RegisterViewController.h"

@interface SettingsTableViewController ()
// Logout Button
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;

@end

@implementation SettingsTableViewController {
    int section_index;
    int row_index;
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
    
    self.settingsDataArray = [[NSMutableArray alloc] init];
    
    //Organization section data
    NSArray *firstItemsArray = [[NSArray alloc] initWithObjects:@"My Organizations", nil];
    NSDictionary *firstItemsArrayDict = [NSDictionary dictionaryWithObject:firstItemsArray forKey:@"data"];
    [self.settingsDataArray addObject:firstItemsArrayDict];
    
    //Notification section data
    NSArray *secondItemsArray = [[NSArray alloc] initWithObjects:@"Replies", @"Favourites", nil];
    NSDictionary *secondItemsArrayDict = [NSDictionary dictionaryWithObject:secondItemsArray forKey:@"data"];
    
    // Setup Table
    section_index = 0;
    row_index = 0 ;
    
    [self.settingsDataArray addObject:secondItemsArrayDict];
    
    //Support section data
    NSArray *thirdItemsArray = [[NSArray alloc] initWithObjects:@"Privacy", @"Help", @"Logout", nil];
    NSDictionary *thirdItemsArrayDict = [NSDictionary dictionaryWithObject:thirdItemsArray forKey:@"data"];
    [self.settingsDataArray addObject:thirdItemsArrayDict];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Called by modal segue views to get back to Settings View
- (IBAction)unwindToList:(UIStoryboardSegue *)segue
{
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return [self.settingsDataArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //Number of rows it should expect should be based on the section
    NSDictionary *dictionary = [self.settingsDataArray objectAtIndex:section];
    NSArray *array = [dictionary objectForKey:@"data"];
    return [array count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if(section == 0)
        return @"";
    else if(section == 1)
        return @"NOTIFICATIONS";
    else if(section ==2)
        return @"SETTINGS";
    else {
        return @"ERROR";
        NSLog(@"[SettingVC] error in section title");
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"settingsCell" forIndexPath:indexPath];
    
    NSDictionary *dictionary = [self.settingsDataArray objectAtIndex:indexPath.section];
    NSArray *array = [dictionary objectForKey:@"data"];
    cell.textLabel.text = [array objectAtIndex:indexPath.row]; //gets back the row string
    
    //Add a checkmark if it's not the notifications section
    if (indexPath.section != 1 ) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    //Add sliders if it's the notifications section
    if (indexPath.section == 1) {
        NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
        NSString *replyState = [standardDefaults stringForKey:@"repliesKey"];
        NSString *favState = [standardDefaults stringForKey:@"favouritesKey"];
        
        UISwitch *toggleSwitch = [[UISwitch alloc] init];
        [toggleSwitch addTarget: self action: @selector(shareSettingsSwitched:) forControlEvents:UIControlEventValueChanged];
        toggleSwitch.tag = indexPath.row;
        if (indexPath.row == 0) {
            if ([replyState isEqualToString:@"On"]) {
                [toggleSwitch setOn:YES];
            }
        }
        else {
            if ([favState isEqualToString:@"On"]) {
                [toggleSwitch setOn:YES];
            }
        }
        cell.accessoryView = [[UIView alloc] initWithFrame:toggleSwitch.frame];

        [cell.accessoryView addSubview:toggleSwitch];
    }
        
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"row is: %d", indexPath.row);
    // My Organizations
    if (indexPath.section == 0 && indexPath.row == 0) {
        [self performSegueWithIdentifier: @"goToMyOrganizations" sender: self];
    }
    
    // settings section
    if (indexPath.section == 2) {
        // logout of app
        if (indexPath.row == 2) {
            NSLog(@"Logging out!");
            
            
            [SSKeychain deletePasswordForService:serviceAuthKey account:account];
            [SSKeychain deletePasswordForService:serviceUserID account:account];
            NSLog(@"Deleted authKey and UserID in keychain");

            RegisterViewController *registerVC=[[UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"registerVC"];
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            appDelegate.window.rootViewController = registerVC;
            
            
        }
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0){
        return 0;
    }
    return 40;
}

#pragma mark - Settings
- (IBAction)shareSettingsSwitched:(UISwitch *)sender {
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    if (sender.tag == 0) {
        NSLog(@"replies");
        if (sender.on == 0) {
            [standardDefaults setObject:@"Off" forKey:@"repliesKey"];
        } else if (sender.on == 1) {
            [standardDefaults setObject:@"On" forKey:@"repliesKey"];
        }
    } else if (sender.tag == 1) {
        NSLog(@"favourites");
        if (sender.on == 0) {
            [standardDefaults setObject:@"Off" forKey:@"favouritesKey"];
        } else if (sender.on == 1) {
            [standardDefaults setObject:@"On" forKey:@"favouritesKey"];
        }
    }
    [standardDefaults synchronize];
}

-(void) loadSwitchButtonStates {
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"Preparing to Segue!");
    //addToCartViewContollerForItem
    if([[segue identifier] isEqualToString:@"goToMyOrganizations"]){
        //NSIndexPath *selectedRow = [[self tableView] indexPathForSelectedRow];
        // OrganizationsTableViewController *vc = [segue destinationViewController];
        //[vc setValue:@"ha" forKey:@"haha"];
    }
    else if ([[segue identifier] isEqualToString:@"loginFromSettings"]) {
        [SSKeychain deletePasswordForService:serviceAuthKey account:account];
        [SSKeychain deletePasswordForService:serviceUserID account:account];
        NSLog(@"Deleted authKey and UserID in keychain");
    }
}


@end
