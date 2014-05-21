//
//  ProfileDetailTableViewController.m
//  Who's Who
//
//  Created by Ken Boucher on 10/05/2014.
//  Copyright (c) 2014 Ken Boucher. All rights reserved.
//

#import "ProfileDetailTableViewController.h"
#import "Profile+Extensions.h"	
#import "Photo.h"
#import "PhotoManager.h"

#define kTagImage	200

typedef enum
{
	ProfileRowImage = 0,
	ProfileRowPosition,
	ProfileRowBio,
} ProfileRow;

@interface ProfileDetailTableViewController ()

@property (strong, nonatomic) PhotoManager *photoManager;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;

@end

@implementation ProfileDetailTableViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
	{
		self.photoManager = [[PhotoManager alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	self.title = self.profile.name;
	self.tableView.backgroundColor = [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	self.photoImageView.layer.cornerRadius = CGRectGetWidth(self.photoImageView.frame) / 2;
	self.photoImageView.layer.masksToBounds = YES;
	self.photoImageView.layer.borderColor = [UIColor colorWithRed:255.0/255
															green:68.0/255
															 blue:0.0/255
															alpha:1.0].CGColor;
	self.photoImageView.layer.borderWidth = 5.0;
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
			Photo *mainPhoto = [self.profile mainPhoto];
			
			// If we have no image, we need to download it, update the collection view after
			// Else, we already have the data so just retrieve the data
			if (!mainPhoto.fullImageURL)
			{
				self.photoImageView.image = nil;
				
				__weak Photo *weakPhoto = mainPhoto;
				__weak NSIndexPath *weakIndexPath = indexPath;
				[self.photoManager imageWithSourceURL:[NSURL URLWithString:mainPhoto.sourceURL]
											indexPath:nil
								 completionBlock:^(NSString *fullImagePath, NSString *smallImagePath, BOOL cancelled) {
									 
									 weakPhoto.fullImageURL = fullImagePath;
									 weakPhoto.smallImageURL = smallImagePath;
									 
									 [weakPhoto.managedObjectContext save:nil];
									 
									 dispatch_async(dispatch_get_main_queue(), ^{
										 [tableView reloadRowsAtIndexPaths:@[weakIndexPath]
														  withRowAnimation:UITableViewRowAnimationAutomatic];
									 });
								 }];
			}
			else
			{
				self.photoImageView.image = [PhotoManager imageWithFilePath:mainPhoto.fullImageURL];
			}
			
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
