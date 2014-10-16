//
//  SelectOrgTableViewController.m
//  aventador
//
//  Created by Victor Zhang on 2014-05-05.
//  Copyright (c) 2014 Vokko. All rights reserved.
//

#import "SelectOrgTableViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "Organization.h"

@interface SelectOrgTableViewController ()

@end

@implementation SelectOrgTableViewController {
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.organization_list.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"selectOrgCell" forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"selectOrgCell"];
    }
    
    Organization *org = nil;
    org = [self.organization_list objectAtIndex:indexPath.row];
    
    cell.textLabel.text = org.name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    Organization *org = self.organization_list[indexPath.row];
    
    [self.delegate orgSelected:org.name withID:org.org_id];
    [self.navigationController popViewControllerAnimated:TRUE];

}

@end
