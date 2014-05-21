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
#import "PhotoManager.h"
#import "Profile+Extensions.h"
#import "Photo.h"
#import "ProfileDetailTableViewController.h"

@interface ProfileListViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) CoreDataManager *coreDataManager;
@property (strong, nonatomic) NSArray *profileArray;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) PhotoManager *photoManager;

@end

@implementation ProfileListViewController

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
	
	self.collectionView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
	
	AppDelegate *appDel = [UIApplication sharedApplication].delegate;
	self.coreDataManager = appDel.coreDataManager;
	self.profileArray = [AppBusinessProfilesFetcher fetchCachedProfilesInContext:self.coreDataManager.mainContext];
	
	self.refreshControl = [[UIRefreshControl alloc] init];
	[self.refreshControl addTarget:self action:@selector(startRefresh)
				  forControlEvents:UIControlEventValueChanged];
	[self.collectionView addSubview:self.refreshControl];
	
	self.collectionView.alwaysBounceVertical = YES;
	
	[self.refreshControl beginRefreshing];
	[self.collectionView setContentOffset:CGPointMake(0, self.collectionView.contentOffset.y-self.refreshControl.frame.size.height) animated:YES];
	
	[self retrieveProfiles];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Class Methods
- (void)startRefresh
{
	[self retrieveProfiles];
}

- (void)retrieveProfiles
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
	dispatch_async(dispatch_queue_create(NULL, NULL), ^{
		
		NSError *error = nil;
		
		self.profileArray = [AppBusinessProfilesFetcher fetchProfiles:&error];
		NSLog(@"retrieved");
		
		dispatch_async(dispatch_get_main_queue(), ^{
			
			if (error)
			{
				[[[UIAlertView alloc] initWithTitle:@"Error"
										   message:error.localizedDescription
										  delegate:nil
								 cancelButtonTitle:@"Dismiss"
								  otherButtonTitles:nil] show];
			}
			
			[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
			
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

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	NSLog(@"Count = %ld", self.photoManager.operationDictionary.count);
	
	ProfilePreviewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"previewCell" forIndexPath:indexPath];

	// Populate the cell with info from the profile
	Profile *profile = self.profileArray[indexPath.row];
	cell.nameLabel.text = profile.name;
	cell.positionLabel.text = profile.position;

	Photo *mainPhoto = [profile mainPhoto];
	// If we have no image, we need to download it, update the collection view after
	// Else, we already have the data so just retrieve the data
	if (!mainPhoto.smallImageURL)
	{
		cell.profileImageView.image = nil;
		
		__weak Photo *weakPhoto = mainPhoto;
		__weak NSIndexPath *weakIndexPath = indexPath;
		[self.photoManager imageWithSourceURL:[NSURL URLWithString:mainPhoto.sourceURL]
									indexPath:indexPath
						 completionBlock:^(NSString *fullImagePath, NSString *smallImagePath, BOOL cancelled) {
							 
							 if (!cancelled)
							 {
								 weakPhoto.fullImageURL = fullImagePath;
								 weakPhoto.smallImageURL = smallImagePath;
								 
								 [self.coreDataManager.mainContext save:nil];
								 
								 dispatch_async(dispatch_get_main_queue(), ^{
									 [collectionView reloadItemsAtIndexPaths:@[weakIndexPath]];
								 });
							 }
						 }];
	}
	else
	{
		cell.profileImageView.image = [PhotoManager imageWithFilePath:mainPhoto.smallImageURL];
	}
	
    return cell;
}

#pragma mark - Collection View Delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	[self performSegueWithIdentifier:@"segueDetail" sender:indexPath];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"segueDetail"])
	{
		NSIndexPath *indexPath = (NSIndexPath *)sender;
		Profile *profile = self.profileArray[indexPath.row];
		
		ProfileDetailTableViewController *detailVC = segue.destinationViewController;
		detailVC.profile = profile;
	}
}

@end
