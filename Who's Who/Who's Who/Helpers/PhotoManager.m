//
//  PhotoManager.m
//  Who's Who
//
//  Created by Ken Boucher on 20/05/2014.
//  Copyright (c) 2014 Ken Boucher. All rights reserved.
//

#import "PhotoManager.h"

@implementation PhotoManager

+ (NSString *)documentPathWithFileName:(NSString *)fileName
{
	NSString *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
	return [documentsPath stringByAppendingPathComponent:fileName];
}

+ (BOOL)fileExistsWithFileName:(NSString *)fileName
{
	NSString *fullPath = [PhotoManager documentPathWithFileName:fileName];
	return [[NSFileManager defaultManager] fileExistsAtPath:fullPath];
}

+ (void)imageWithSourceURL:(NSURL *)url
			 completionBlock:(void (^)(NSString *fullImagePath,
									   NSString *smallImagePath))completionBlock
{
	NSParameterAssert(completionBlock);
	
	dispatch_queue_t downloadQueue = dispatch_queue_create(NULL, NULL);
	
	dispatch_async(downloadQueue, ^{
		NSData *imageData = [NSData dataWithContentsOfURL:url];
		
		NSData *fullImageData = imageData;
		NSString *fullImagePath = [NSString stringWithFormat:@"full%@", [[NSUUID UUID] UUIDString]];
		[PhotoManager saveImageData:fullImageData filePath:fullImagePath];
		
		NSData *smallImageData = UIImageJPEGRepresentation([PhotoManager resizedImageWithData:imageData], 0.5);
		NSString *smallImagePath = [NSString stringWithFormat:@"small%@", [[NSUUID UUID] UUIDString]];
		[PhotoManager saveImageData:smallImageData filePath:smallImagePath];
		
		UIImage *image = [UIImage imageWithData:imageData];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			completionBlock(fullImagePath, smallImagePath);
		});
	});
}

// Returns success
+ (BOOL)saveImageData:(NSData *)data
				   filePath:(NSString *)filePath
{
	NSString *fullPath = [PhotoManager documentPathWithFileName:filePath];
	return [data writeToFile:fullPath atomically:YES];
}

+ (UIImage *)imageWithFilePath:(NSString *)filePath
{
	NSString *fullPath = [PhotoManager documentPathWithFileName:filePath];
	return [UIImage imageWithContentsOfFile:fullPath];
}

+ (UIImage *)resizedImageWithData:(NSData *)data
{
	UIImage *image = [UIImage imageWithData:data];
	CGSize newSize = CGSizeMake(150, 150);
	
	UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	
	return newImage;
}

@end
