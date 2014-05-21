//
//  DownloadImageOperation.m
//  Who's Who
//
//  Created by Ken Boucher on 21/05/2014.
//  Copyright (c) 2014 Ken Boucher. All rights reserved.
//

#import "DownloadImageOperation.h"

@interface DownloadImageOperation ()

@property (strong, nonatomic) NSURL *imageURL;
@property (copy, nonatomic) void (^imageCompletionBlock)(NSString *fullImagePath, NSString *smallImagePath, BOOL cancelled);

@end


@implementation DownloadImageOperation

- (id)initWithImageURL:(NSURL *)imageURL
	   completionBlock:(void (^)(NSString *fullImagePath,
								 NSString *smallImagePath,
								 BOOL cancelled))imageCompletionBlock
{
	NSParameterAssert(imageURL);
	NSParameterAssert(imageCompletionBlock);
	
	if (self = [super init])
	{
		self.imageURL = imageURL;
		self.imageCompletionBlock = imageCompletionBlock;
	}
	
	return self;
}

- (void)main
{
	@autoreleasepool {
		
		NSURLRequest *request = [NSURLRequest requestWithURL:self.imageURL
												 cachePolicy:NSURLRequestUseProtocolCachePolicy
											 timeoutInterval:20.0];
		NSData *imageData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
		
		if (self.isCancelled)
		{
			self.imageCompletionBlock(nil, nil, YES);
			return;
		}
		
		NSData *fullImageData = imageData;
		NSString *fullImagePath = [NSString stringWithFormat:@"full%@", [[NSUUID UUID] UUIDString]];
		[DownloadImageOperation saveImageData:fullImageData filePath:fullImagePath];
		
		NSData *smallImageData = UIImageJPEGRepresentation([DownloadImageOperation resizedImageWithData:imageData], 0.5);
		NSString *smallImagePath = [NSString stringWithFormat:@"small%@", [[NSUUID UUID] UUIDString]];
		[DownloadImageOperation saveImageData:smallImageData filePath:smallImagePath];
		
		self.imageCompletionBlock(fullImagePath, smallImagePath, NO);
	}
}

+ (NSString *)documentPathWithFileName:(NSString *)fileName
{
	NSString *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
	return [documentsPath stringByAppendingPathComponent:fileName];
}

/*
 *	Writes the data to file with a given file path
 */
+ (BOOL)saveImageData:(NSData *)data
			 filePath:(NSString *)filePath
{
	NSString *fullPath = [DownloadImageOperation documentPathWithFileName:filePath];
	return [data writeToFile:fullPath atomically:YES];
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

- (void)cancel
{
	
}

@end
