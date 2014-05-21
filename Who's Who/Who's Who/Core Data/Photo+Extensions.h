//
//  Photo+Extensions.h
//  Who's Who
//
//  Created by Ken Boucher on 21/05/2014.
//  Copyright (c) 2014 Ken Boucher. All rights reserved.
//

#import "Photo.h"

#define kKeyPhotoProfile		@"name"
#define kKeyPhotoSourceURL		@"sourceURL"

@interface Photo (Extensions)

+ (Photo *)photoWithSourceURL:(NSString *)sourceURLString
					inContext:(NSManagedObjectContext *)context;
- (void)updateWithDictionary:(NSDictionary *)dictionary;

@end
