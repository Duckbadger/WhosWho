//
//  Profile+Extensions.h
//  Who's Who
//
//  Created by Ken Boucher on 10/05/2014.
//  Copyright (c) 2014 Ken Boucher. All rights reserved.
//

#import "Profile.h"

@interface Profile (Extensions)

- (BOOL)hasCachedImage;
- (void)getImageWithBlock:(void (^)(UIImage *image))completionBlock;
- (UIImage *)getCachedSmallImage;
- (UIImage *)getCachedFullImage;

@end
