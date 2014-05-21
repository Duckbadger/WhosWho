//
//  Profile+Extensions.m
//  Who's Who
//
//  Created by Ken Boucher on 10/05/2014.
//  Copyright (c) 2014 Ken Boucher. All rights reserved.
//

#import "Profile+Extensions.h"
#import "NSManagedObject+CoreDataManagerExtensions.h"
#import <KZPropertyMapper/KZPropertyMapper.h>

@implementation Profile (Extensions)

/*
 *	Gets the photo with an index of 0, which is the main photo
 *	Index added for now due to possible extensions in future of multiple photos
 */
- (Photo *)mainPhoto
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"index = %ld", 0];
	NSSet *filteredSet = [self.photos filteredSetUsingPredicate:predicate];
	
	return (filteredSet.count > 0) ? filteredSet.anyObject : nil;
}

/*
 *	Fetches or creates a profile with the name property filled in
 */
+ (Profile *)profileWithName:(NSString *)name
				   inContext:(NSManagedObjectContext *)context
{
	// Create new profile or fetch existing one
	NSFetchRequest *fetchRequest = [Profile fetchRequest];
	fetchRequest.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
	
	Profile *profile = nil;
	
	NSArray *profileArray = [context executeFetchRequest:fetchRequest error:nil];
	if (profileArray.count > 0)
	{
		profile = profileArray.firstObject;
	}
	else
	{
		profile = [Profile insertInContext:context];
		profile.name = name;
	}
	
	return profile;
}

/*
 *	Updates instance of a profile with a dictionary mapped to properties
 */
- (void)updateWithDictionary:(NSDictionary *)dictionary
{
	[KZPropertyMapper mapValuesFrom:dictionary toInstance:self usingMapping:
	 @{kKeyProfileName : KZProperty(name),
	   kKeyProfilePosition : KZProperty(position),
	   kKeyProfileBiography : KZProperty(biography)
	   }];
}

@end
