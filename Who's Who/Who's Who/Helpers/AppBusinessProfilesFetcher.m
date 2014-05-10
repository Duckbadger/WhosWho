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

+ (NSArray *)fetchProfiles
{
	// First get the html data from the TAB profiles page
	NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://www.theappbusiness.com/our-team/"]];
	
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
    NSString *userProfileXpathQueryString = @"//div[@class='col col2']";//@"//section[@id='users']";//@"//div[@class='wrapper']";
	NSArray *userProfilesElements = [htmlParser searchWithXPathQuery:userProfileXpathQueryString];
	NSDate *lastModified = [NSDate date];
	
	// Retrieve the main context from the core data manager
	AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
	NSManagedObjectContext *mainContext = appDelegate.coreDataManager.mainContext;
	
	/*
	 *	Note - Structure for the profileElement is:
	 *	[0]	Image
	 *	[1]	Name
	 *	[2]	Position
	 *	[3]	Bio
	 */
	for (TFHppleElement *profileElement in userProfilesElements)
	{
		// Create new profile
		Profile *profile = [Profile insertInContext:mainContext];
		
		//----
		// Name
		TFHppleElement *hTagElement = profileElement.children[1];
		TFHppleElement *nameElement = hTagElement.children.firstObject;
		profile.name = nameElement.content;
		
		//----
		// Position
		TFHppleElement *pTagElement = profileElement.children[2];
		TFHppleElement *positionElement = pTagElement.children.firstObject;
		profile.position = positionElement.content;
		
		//----
		// Bio
		TFHppleElement *userDescriptionPTagElement = profileElement.children[3];
		TFHppleElement *bioElement = userDescriptionPTagElement.children.firstObject;
		profile.biography = bioElement.content;
		
		//----
		// Image
		TFHppleElement *srcElement = profileElement.children[0];
		TFHppleElement *imageElement = srcElement.children.firstObject;
		profile.imageString = imageElement.attributes[@"src"];
		
		//----
		// Last modified
		profile.lastModified = lastModified;
	}
	
	// Save the context
	[mainContext save:nil];
	
	// Retrieve the objects to return
	NSFetchRequest *fetchRequest = [Profile fetchRequest];
	NSArray *profileArray = [mainContext executeFetchRequest:fetchRequest error:nil];
	
	return profileArray;
}

@end
