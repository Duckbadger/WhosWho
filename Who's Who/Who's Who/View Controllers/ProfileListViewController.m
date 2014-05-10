//
//  ProfileListViewController.m
//  Who's Who
//
//  Created by Ken Boucher on 10/05/2014.
//  Copyright (c) 2014 Ken Boucher. All rights reserved.
//

#import "AppDelegate.h"
#import "ProfileListViewController.h"
#import "ProfilePreviewCell.h"
#import "AppBusinessProfilesFetcher.h"
#import "Profile+Extensions.h"

@interface ProfileListViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) CoreDataManager *coreDataManager;
@property (strong, nonatomic) NSArray *profileArray;

@end

@implementation ProfileListViewController

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
	
	AppDelegate *appDel = [UIApplication sharedApplication].delegate;
	self.coreDataManager = appDel.coreDataManager;
	
	self.profileArray = [AppBusinessProfilesFetcher fetchProfiles];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Collection View Data Sources

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return self.profileArray.count;
}

// The cell that is returned must be retrieved from a call to - dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	ProfilePreviewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"previewCell" forIndexPath:indexPath];

	// Populate the cell with info from the profile
	Profile *profile = self.profileArray[indexPath.row];
	cell.nameLabel.text = profile.name;
	cell.positionLabel.text = profile.position;
	
	// If we have no image, we need to download it, update the collection view after
	// Else, we already have the data so just retrieve the data
	if ([profile hasCachedImage])
	{
		cell.profileImageView.image = nil;
		
		[profile getImageWithBlock:^(UIImage *image) {
			cell.profileImageView.image = image;
			
			[self.coreDataManager.mainContext save:nil];
			dispatch_async(dispatch_get_main_queue(), ^{
				
				[collectionView reloadItemsAtIndexPaths:@[indexPath]];
			});
		}];
	}
	else
	{
		cell.profileImageView.image = [profile getCachedSmallImage];
	}
	
    return cell;
}

@end
