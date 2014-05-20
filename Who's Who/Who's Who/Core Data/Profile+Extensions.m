//
//  Profile+Extensions.m
//  Who's Who
//
//  Created by Ken Boucher on 10/05/2014.
//  Copyright (c) 2014 Ken Boucher. All rights reserved.
//

#import "Profile+Extensions.h"

@implementation Profile (Extensions)

/*
 *	Gets the photo with an index of 0, which is the main photo
 *	Index added for now due to possible extensions in future of multiple photos
 */
- (Photo *)mainPhoto
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"index == ", 0];
	NSSet *filteredSet = [self.photos filteredSetUsingPredicate:predicate];
	
	return (filteredSet.count > 0) ? filteredSet.anyObject : nil;
}

@end
