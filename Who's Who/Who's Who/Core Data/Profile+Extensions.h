//
//  Profile+Extensions.h
//  Who's Who
//
//  Created by Ken Boucher on 10/05/2014.
//  Copyright (c) 2014 Ken Boucher. All rights reserved.
//

#import "Profile.h"

#define kKeyProfileName			@"name"
#define kKeyProfilePosition		@"position"
#define kKeyProfileBiography	@"biography"

@interface Profile (Extensions)

- (Photo *)mainPhoto;
+ (Profile *)profileWithName:(NSString *)name
				   inContext:(NSManagedObjectContext *)context;
- (void)updateWithDictionary:(NSDictionary *)dictionary;

@end
