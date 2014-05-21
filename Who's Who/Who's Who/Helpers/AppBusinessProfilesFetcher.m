//
//  AppBusinessProfilesFetcher.m
//  Who's Who
//
//  Created by Ken Boucher on 10/05/2014.
//  Copyright (c) 2014 Ken Boucher. All rights reserved.
//

#import "AppBusinessProfilesFetcher.h"
#import "AppDelegate.h"
#import "CoreDataManager.h"
#import "NetworkClient.h"
#import "Profile+Extensions.h"
#import "Photo+Extensions.h"

@implementation AppBusinessProfilesFetcher

+ (NSArray *)fetchCachedProfilesInContext:(NSManagedObjectContext *)context
{
	// Retrieve the objects to return
	NSFetchRequest *fetchRequest = [Profile fetchRequest];
	NSArray *profileArray = [context executeFetchRequest:fetchRequest error:nil];
	
	return profileArray;
}

+ (NSArray *)fetchProfiles:(NSError **)error
{
	// Retrieve the main context from the core data manager
	AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
	NSManagedObjectContext *mainContext = appDelegate.coreDataManager.mainContext;
	NSManagedObjectContext *privateContext = [appDelegate.coreDataManager createPrivateContext];
	
	// First get the html data from the TAB profiles page
	NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://www.theappbusiness.com/our-team/"]];
	
	NSSet *modifiedObjects = nil;//[AppBusinessProfilesFetcher parseData:data inContext:privateContext];
	
	[AppBusinessProfilesFetcher deleteOldProfilesWithModifiedProfiles:modifiedObjects inContext:privateContext];
	
	[privateContext save:nil];
	
	NSArray *profileArray = [AppBusinessProfilesFetcher fetchCachedProfilesInContext:mainContext];
	
	return profileArray;
}

+ (void)deleteOldProfilesWithModifiedProfiles:(NSSet *)modifiedProfiles inContext:(NSManagedObjectContext *)context
{
	NSFetchRequest *fetchRequest = [Profile fetchRequest];
	NSArray *originalProfileArray = [context executeFetchRequest:fetchRequest error:nil];
	NSMutableSet *originalSet = [NSMutableSet setWithArray:originalProfileArray];
	
	[originalSet minusSet:modifiedProfiles];
	
	for (Profile *oldProfile in originalSet)
	{
		[context deleteObject:oldProfile];
	}
}

@end
