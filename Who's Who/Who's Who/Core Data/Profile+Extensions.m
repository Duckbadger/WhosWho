//
//  Profile+Extensions.m
//  Who's Who
//
//  Created by Ken Boucher on 10/05/2014.
//  Copyright (c) 2014 Ken Boucher. All rights reserved.
//

#import "Profile+Extensions.h"

@implementation Profile (Extensions)

- (void)getImageWithBlock:(void (^)(UIImage *image))completionBlock
{
	NSURL *url = [NSURL URLWithString:self.imageString];
	
	if (self.imageData == nil)
	{
		dispatch_queue_t downloadQueue = dispatch_queue_create("imageQueue", NULL);
		dispatch_async(downloadQueue, ^{
			NSData *imageData = [NSData dataWithContentsOfURL:url];
			
			self.imageData = imageData;
			
			UIImage *image = [UIImage imageWithData:imageData];
            completionBlock(image);
		});
	}
	else
	{
		UIImage *image = [UIImage imageWithData:self.imageData];
		completionBlock(image);
	}
}

@end
