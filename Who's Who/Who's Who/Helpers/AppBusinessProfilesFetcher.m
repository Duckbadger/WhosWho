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
	NetworkClient *client = [[NetworkClient alloc] init];
	NSError *fetchError = nil;
	NSSet *mappingDictionaries = [client fetchProfileMappingDictionaries:&fetchError];
	
	if (fetchError)
	{
		*error = fetchError;
		
		return [AppBusinessProfilesFetcher fetchCachedProfilesInContext:mainContext];
	}
	
	NSSet *modifiedProfiles = [AppBusinessProfilesFetcher processMappingDictionaries:mappingDictionaries inContext:privateContext];
	
	[AppBusinessProfilesFetcher deleteOldProfilesWithModifiedProfiles:modifiedProfiles inContext:privateContext];
	
	[privateContext save:nil];
	
	NSArray *profileArray = [AppBusinessProfilesFetcher fetchCachedProfilesInContext:mainContext];
	
	return profileArray;
}

/*
 *	Processes the set of dictionaries that are mapped to profile and photo properties
 *	Returns a set of modified profiles
 */
+ (NSSet *)processMappingDictionaries:(NSSet *)mappingDictionaries inContext:(NSManagedObjectContext *)context
{
	NSMutableSet *modifiedProfiles = [NSMutableSet new];
	
	for (NSMutableDictionary *profileMappingDictionary in mappingDictionaries)
	{
		// Retrieve the photo dictionary from the profile and remove it from the original dict
		NSMutableDictionary *photoDictionary = profileMappingDictionary[kKeyProfilePhoto];
		[profileMappingDictionary removeObjectForKey:kKeyProfilePhoto];
		
		//----
		// Create new profile or fetch existing one and update
		Profile *profile = [Profile profileWithName:profileMappingDictionary[kKeyProfileName] inContext:context];
		
		[profile updateWithDictionary:profileMappingDictionary];
		
		//----
		// Fill in properties for Photo
		[photoDictionary setObject:profile forKey:kKeyPhotoProfile];
		Photo *photo = [Photo photoWithSourceURL:photoDictionary[kKeyPhotoSourceURL] inContext:context];
		
		[photo updateWithDictionary:photoDictionary];
		
		[modifiedProfiles addObject:profile];
	}
	
	return modifiedProfiles;
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
