//
//  ProfileDetailTableViewController.m
//  Who's Who
//
//  Created by Ken Boucher on 10/05/2014.
//  Copyright (c) 2014 Ken Boucher. All rights reserved.
//

#import "ProfileDetailTableViewController.h"
#import "Profile+Extensions.h"

#define kTagImage	200

typedef enum
{
	ProfileRowImage = 0,
	ProfileRowName,
	ProfileRowPosition,
	ProfileRowBio,
} ProfileRow;

@interface ProfileDetailTableViewController ()

@end

@implementation ProfileDetailTableViewController

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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    return [super numberOfSectionsInTableView:tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [super tableView:tableView numberOfRowsInSection:section];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
	switch (indexPath.row)
	{
		case ProfileRowImage:
		{
			UIImageView *imageView = (UIImageView *)[cell viewWithTag:kTagImage];
			imageView.image = [self.profile getCachedFullImage];
			
			break;
		}
		case ProfileRowName:
		{
			cell.textLabel.text = self.profile.name;
			break;
		}
		case ProfileRowPosition:
		{
			cell.textLabel.text = self.profile.position;
			break;
		}
		case ProfileRowBio:
		{
			cell.textLabel.text = self.profile.biography;
			break;
		}
		default:
			break;
	}
	
    return cell;
}

@end
