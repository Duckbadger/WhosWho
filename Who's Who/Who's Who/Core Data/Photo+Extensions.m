//
//  Photo+Extensions.m
//  Who's Who
//
//  Created by Ken Boucher on 21/05/2014.
//  Copyright (c) 2014 Ken Boucher. All rights reserved.
//

#import "Photo+Extensions.h"
#import "NSManagedObject+CoreDataManagerExtensions.h"
#import <KZPropertyMapper/KZPropertyMapper.h>

@implementation Photo (Extensions)

/*
 *	Fetches or creates a photo using the source URL
 */
+ (Photo *)photoWithSourceURL:(NSString *)sourceURLString
				   inContext:(NSManagedObjectContext *)context
{

	// Create new photo or fetch existing one
	NSFetchRequest *fetchRequest = [Photo fetchRequest];
	fetchRequest.predicate = [NSPredicate predicateWithFormat:@"sourceURL = %@", sourceURLString];

	Photo *photo = nil;
	
	NSArray *photoArray = [context executeFetchRequest:fetchRequest error:nil];
	if (photoArray.count > 0)
	{
		photo = photoArray.firstObject;
	}
	else
	{
		photo = [Photo insertInContext:context];
	}
	
	return photo;
}

/*
 *	Updates instance of photo
 */
- (void)updateWithDictionary:(NSDictionary *)dictionary
{
	[KZPropertyMapper mapValuesFrom:dictionary toInstance:self usingMapping:
	 @{kKeyPhotoProfile : KZProperty(profile),
	   kKeyPhotoSourceURL : KZProperty(sourceURL),
	   }];
}

@end
