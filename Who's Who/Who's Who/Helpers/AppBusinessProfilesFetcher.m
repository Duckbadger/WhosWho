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
#import "Profile+Extensions.h"
#import "Photo+Extensions.h"
#import <TFHpple.h>

@implementation AppBusinessProfilesFetcher

+ (NSArray *)fetchCachedProfilesInContext:(NSManagedObjectContext *)context
{
	// Retrieve the objects to return
	NSFetchRequest *fetchRequest = [Profile fetchRequest];
	NSArray *profileArray = [context executeFetchRequest:fetchRequest error:nil];
	
	return profileArray;
}

+ (NSArray *)fetchProfiles
{
	// Retrieve the main context from the core data manager
	AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
	NSManagedObjectContext *mainContext = appDelegate.coreDataManager.mainContext;
	NSManagedObjectContext *privateContext = [appDelegate.coreDataManager createPrivateContext];
	
	// First get the html data from the TAB profiles page
	NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://www.theappbusiness.com/our-team/"]];
	
	NSSet *modifiedObjects = [AppBusinessProfilesFetcher parseData:data inContext:privateContext];
	
	[AppBusinessProfilesFetcher deleteOldProfilesWithModifiedProfiles:modifiedObjects inContext:privateContext];
	
	[privateContext save:nil];
	
	NSArray *profileArray = [AppBusinessProfilesFetcher fetchCachedProfilesInContext:mainContext];
	
	return profileArray;
}

/*
 *	Parses the HTML data and extracts the user data
 *	Returns a set of all the modified Profile objects
 */
+ (NSSet *)parseData:(NSData *)data inContext:(NSManagedObjectContext *)context
{
	NSMutableSet *modifiedObjects = [NSMutableSet new];
	
	// If we have any data to parse, go ahead and parse it.
	if (data)
	{
		// HTML parser
		TFHpple *htmlParser = [TFHpple hppleWithHTMLData:data];
		
		/*
		 *	Note - Format is as follows:
		 *	Also note [] means there are multiples of this element
		 *	<section id="users">	// Start here, class=wrapper is repeated elsewhere
		 *		class="wrapper"
		 *			[]<div class="row">
		 *				[]<div class="col col2">
		 *					<div class="title">
		 *						<img />
		 *					<h3> // Name
		 *					<p> // Position
		 *					<p class="user-description"> // Bio
		 */
				
		// Get all the profiles
		NSString *userProfileXpathQueryString = @"//div[@class='col col2']";
		NSArray *userProfilesElements = [htmlParser searchWithXPathQuery:userProfileXpathQueryString];
		NSDate *lastModified = [NSDate date];
		
		//-----
		// DATA IMPORT
		//-----
		
		/*
		 *	Note - Structure for the profileElement is:
		 *	[0]	Image
		 *	[1]	Name
		 *	[2]	Position
		 *	[3]	Bio
		 */
		NSInteger index = 0;
		for (TFHppleElement *profileElement in userProfilesElements)
		{
			index++;
//			if (index > 20) break;
			
			NSMutableDictionary *profileDictionary = [NSMutableDictionary new];
			NSMutableDictionary *photoDictionary = [NSMutableDictionary new];
			
			//----
			// Name
			TFHppleElement *hTagElement = profileElement.children[1];
			TFHppleElement *nameElement = hTagElement.children.firstObject;
			NSString *name = (nameElement.content) ?: @"";
			[profileDictionary setObject:name
								 forKey:kKeyProfileName];
			
			//----
			// Position
			TFHppleElement *pTagElement = profileElement.children[2];
			TFHppleElement *positionElement = pTagElement.children.firstObject;
			[profileDictionary setObject:(positionElement.content) ?: [NSNull null]
								 forKey:kKeyProfilePosition];
			
			//----
			// Bio
			TFHppleElement *userDescriptionPTagElement = profileElement.children[3];
			TFHppleElement *bioElement = userDescriptionPTagElement.children.firstObject;
			[profileDictionary setObject:(bioElement.content) ?: [NSNull null]
								 forKey:kKeyProfileBiography];
			
			//----
			// Image
			TFHppleElement *srcElement = profileElement.children[0];
			TFHppleElement *imageElement = srcElement.children.firstObject;
			NSString *imageString = (imageElement.attributes[@"src"]) ?: @"";
			[photoDictionary setObject:imageString
								  forKey:kKeyPhotoSourceURL];
			
			//----
			// Create new profile or fetch existing one and update
			Profile *profile = [Profile profileWithName:name inContext:context];
			
			[profile updateWithDictionary:profileDictionary];
			
			[photoDictionary setObject:profile
								forKey:kKeyPhotoProfile];
			
			//----
			// Fill in properties for Photo
			Photo *photo = [Photo photoWithSourceURL:imageString inContext:context];
	
			[photo updateWithDictionary:photoDictionary];
			
			//----
			// Add the profile to the modified objects set
			[modifiedObjects addObject:profile];
		}
		
		// End DATA IMPORT
		//-----
	}
	
	return modifiedObjects;
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

+ (void)deleteOldProfilesWithContext:(NSManagedObjectContext *)context andLastModifiedData:(NSDate *)lastModified
{
	NSFetchRequest *oldProfilesFetchRequest = [Profile fetchRequest];
	oldProfilesFetchRequest.predicate = [NSPredicate predicateWithFormat:@"lastModified < %@", lastModified];
	NSArray *oldProfileArray = [context executeFetchRequest:oldProfilesFetchRequest error:nil];
	for (Profile *profile in oldProfileArray)
	{
		[context deleteObject:profile];
	}
	[context save:nil];
}

@end
