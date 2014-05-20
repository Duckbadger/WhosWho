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
    
	self.title = self.profile.name;
	self.tableView.backgroundColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [super numberOfSectionsInTableView:tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [super tableView:tableView numberOfRowsInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch (indexPath.row)
	{
		case ProfileRowBio:
		{
			// Have to work out the height dynamically for the cell based on the biography length
			UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
			UILabel *textLabel = cell.textLabel;
			CGSize maximumLabelSize = CGSizeMake(textLabel.frame.size.width, FLT_MAX);
			CGRect labelRect = [self.profile.biography
								boundingRectWithSize:maximumLabelSize
								options:NSStringDrawingUsesLineFragmentOrigin
								attributes:@{
											 NSFontAttributeName : textLabel.font
											 }
								context:nil];
			
			return labelRect.size.height + 20;
		}
		default:
		{
			return [super tableView:tableView heightForRowAtIndexPath:indexPath];
		}
	}
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
			
			imageView.layer.cornerRadius = 105.0;
			imageView.layer.masksToBounds = YES;
			imageView.layer.borderColor = [UIColor colorWithRed:255.0/255
														   green:68.0/255
															blue:0.0/255
														   alpha:1.0].CGColor;
			imageView.layer.borderWidth = 5.0;
			
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
