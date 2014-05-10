//
//  Profile+Extensions.m
//  Who's Who
//
//  Created by Ken Boucher on 10/05/2014.
//  Copyright (c) 2014 Ken Boucher. All rights reserved.
//

#import "Profile+Extensions.h"

@implementation Profile (Extensions)

- (BOOL)hasCachedImage
{
	return (self.fullImageData && self.smallImageData);
}

- (void)getImageWithBlock:(void (^)(UIImage *image))completionBlock
{
	NSURL *url = [NSURL URLWithString:self.imageString];
	
	dispatch_queue_t downloadQueue = dispatch_queue_create("imageQueue", NULL);
	dispatch_async(downloadQueue, ^{
		NSData *imageData = [NSData dataWithContentsOfURL:url];
		
		self.fullImageData = imageData;
		self.smallImageData = UIImageJPEGRepresentation([Profile resizedImageWithData:imageData], 0.5);
		
		UIImage *image = [UIImage imageWithData:imageData];
		completionBlock(image);
	});
}

- (UIImage *)getCachedSmallImage
{
	return [UIImage imageWithData:self.smallImageData];
}

- (UIImage *)getCachedFullImage
{
	return [UIImage imageWithData:self.fullImageData];
}


+ (UIImage *)resizedImageWithData:(NSData *)data
{
	UIImage *image = [UIImage imageWithData:data];
	CGSize newSize = CGSizeMake(120, 120);
	
	UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	
	return newImage;
}

@end
