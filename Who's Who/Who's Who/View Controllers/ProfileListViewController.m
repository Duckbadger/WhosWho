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
@property (strong, nonatomic) UIRefreshControl *refreshControl;

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

	self.refreshControl = [[UIRefreshControl alloc] init];

	self.collectionView.alwaysBounceVertical = YES;
	
	AppDelegate *appDel = [UIApplication sharedApplication].delegate;
	self.coreDataManager = appDel.coreDataManager;
	
	self.profileArray = [AppBusinessProfilesFetcher fetchCachedProfiles];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self.refreshControl addTarget:self action:@selector(startRefresh)
			 forControlEvents:UIControlEventValueChanged];
	[self.collectionView addSubview:self.refreshControl];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];

	[self.refreshControl beginRefreshing];
	[self.collectionView setContentOffset:CGPointMake(0, self.collectionView.contentOffset.y-self.refreshControl.frame.size.height) animated:YES];
	
	dispatch_async(dispatch_queue_create("refreshQueue", NULL), ^{
		
		self.profileArray = [AppBusinessProfilesFetcher fetchProfiles];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.collectionView reloadData];
			[self.refreshControl endRefreshing];
		});
	});
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Class Methods
- (void)startRefresh
{
	dispatch_async(dispatch_queue_create("refreshQueue", NULL), ^{
		
		self.profileArray = [AppBusinessProfilesFetcher fetchProfiles];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.collectionView reloadData];
			[self.refreshControl endRefreshing];
		});
	});
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
	if (![profile hasCachedImage])
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
