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
#import "Profile.h"
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
		for (TFHppleElement *profileElement in userProfilesElements)
		{
			//----
			// Name
			TFHppleElement *hTagElement = profileElement.children[1];
			TFHppleElement *nameElement = hTagElement.children.firstObject;
			NSString *name = nameElement.content;
			
			//----
			// Position
			TFHppleElement *pTagElement = profileElement.children[2];
			TFHppleElement *positionElement = pTagElement.children.firstObject;
			NSString *position = positionElement.content;
			
			//----
			// Bio
			TFHppleElement *userDescriptionPTagElement = profileElement.children[3];
			TFHppleElement *bioElement = userDescriptionPTagElement.children.firstObject;
			NSString *biography = bioElement.content;
			
			//----
			// Image
			TFHppleElement *srcElement = profileElement.children[0];
			TFHppleElement *imageElement = srcElement.children.firstObject;
			NSString *imageString = imageElement.attributes[@"src"];
			
			//----
			// Create new profile or fetch existing one
			NSFetchRequest *fetchRequest = [Profile fetchRequest];
			fetchRequest.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
			
			Profile *profile = nil;
			NSArray *profileArray = [mainContext executeFetchRequest:fetchRequest error:nil];
			if (profileArray.count > 0)
			{
				profile = profileArray.firstObject;
			}
			else
			{
				profile = [Profile insertInContext:mainContext];
			}
			
			//----
			// Fill in properties for Profile
			profile.name = name;
			profile.position = position;
			profile.biography = biography;
			profile.imageString = imageString;
			profile.lastModified = lastModified;
		}
		
		// Save the context
		[mainContext save:nil];
		
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
	}
	
	NSArray *profileArray = [AppBusinessProfilesFetcher fetchCachedProfiles];
	
	return profileArray;
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
