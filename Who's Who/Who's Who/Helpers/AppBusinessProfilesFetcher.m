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
#import "Photo.h"
#import <TFHpple.h>

@implementation AppBusinessProfilesFetcher

+ (NSArray *)fetchCachedProfiles
{
	// Retrieve the main context from the core data manager
	AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
	NSManagedObjectContext *mainContext = appDelegate.coreDataManager.mainContext;
	
	// Retrieve the objects to return
	NSFetchRequest *fetchRequest = [Profile fetchRequest];
	NSArray *profileArray = [mainContext executeFetchRequest:fetchRequest error:nil];
	
	return profileArray;
}

+ (NSArray *)fetchProfiles
{
	// Retrieve the main context from the core data manager
	AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
	NSManagedObjectContext *mainContext = appDelegate.coreDataManager.mainContext;
	
	// First get the html data from the TAB profiles page
	NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://www.theappbusiness.com/our-team/"]];
	
	NSSet *modifiedObjects = [AppBusinessProfilesFetcher parseData:data];
	
		
	NSArray *profileArray = [AppBusinessProfilesFetcher fetchCachedProfiles];
	
	return profileArray;
}

/*
 *	Parses the HTML data and extracts the user data
 *	Returns a set of all the modified Profile objects
 */
+ (NSSet *)parseData:(NSData *)data
{
	NSMutableSet *modifiedObjects = nil;
	
	// If we have any data to parse, go ahead and parse it.
	if (data)
	{
		AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
		NSManagedObjectContext *mainContext = appDelegate.coreDataManager.mainContext;

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
		NSManagedObjectContext *privateContext = [appDelegate.coreDataManager createPrivateContext];
		
		/*
		 *	Note - Structure for the profileElement is:
		 *	[0]	Image
		 *	[1]	Name
		 *	[2]	Position
		 *	[3]	Bio
		 */
		for (TFHppleElement *profileElement in userProfilesElements)
		{
			NSMutableDictionary *profileDictionary = [NSMutableDictionary new];
			
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
			NSString *imageString = imageElement.attributes[@"src"];
			
			//----
			// Create new profile or fetch existing one and update
			Profile *profile = [Profile profileWithName:name inContext:privateContext];
			
			[profile updateWithDictionary:profileDictionary];
			
			//----
			// Fill in properties for Photo
			NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sourceURL == %@", imageString];
			NSSet *filteredSet = [profile.photos filteredSetUsingPredicate:predicate];
			Photo *photo = nil;
			if (filteredSet.count > 0)
			{
				photo = filteredSet.anyObject;
			}
			else
			{
				photo = [Photo insertInContext:privateContext];
			}
			
			photo.profile = profile;
			photo.sourceURL = imageString;
			
		}
		
		// Save the context
		[privateContext save:nil];
		
		// End DATA IMPORT
		//-----
		
		//-----
		// Delete old profiles
		// Anything not updated was therefore not on the website anymore
		// Check for anything below the last modified date
		// Only do this if the url was valid, i.e. got userProfileElements
		if (userProfilesElements.count > 0)
		{
			[self deleteOldProfilesWithContext:mainContext andLastModifiedData:lastModified];
		}
		
		return modifiedObjects;
	}
	else
	{
		return modifiedObjects;
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
