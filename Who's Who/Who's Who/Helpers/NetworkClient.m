//
//  NetworkClient.m
//  Who's Who
//
//  Created by Ken Boucher on 21/05/2014.
//  Copyright (c) 2014 Ken Boucher. All rights reserved.
//

#import "NetworkClient.h"
#import <TFHpple.h>
#import "Profile+Extensions.h"
#import "Photo+Extensions.h"

@implementation NetworkClient

- (id)init
{
	self = [super init];
	return self;
}

/*
 *	Queries the web page and returns a dictionary of all the modified objects
 */
- (NSSet *)fetchProfileDictionaries:(NSError **)error
{
	NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://www.theappbusiness.com/our-team/"]];
	
	if (!data)
	{
		*error = [NSError errorWithDomain:@"com.TAB.ErrorDomain"
									 code:408
								 userInfo:@{ NSLocalizedDescriptionKey : @"The request timed out" }];
		
		return nil;
	}
	else
	{
		NSSet *modifiedObjects = [NetworkClient parseData:data];
		
		return modifiedObjects;
	}
}

/*
 *	Parses the HTML data and extracts the user data
 *	Returns a set of all the modified Profile objects
 */
+ (NSSet *)parseData:(NSData *)data
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
			
			[profileDictionary setObject:photoDictionary
								  forKey:kKeyProfilePhoto];
			
			//----
			// Add the profileDictionary to the modified objects set
			[modifiedObjects addObject:profileDictionary];
		}
		
		// End DATA IMPORT
		//-----
	}
	
	return modifiedObjects;
}


@end
