//
//  PhotoManager.m
//  Who's Who
//
//  Created by Ken Boucher on 20/05/2014.
//  Copyright (c) 2014 Ken Boucher. All rights reserved.
//

#import "PhotoManager.h"
#import "DownloadImageOperation.h"

@interface PhotoManager ()

@property (strong, nonatomic) NSMutableDictionary *operationDictionary;

@property (strong, nonatomic) NSOperationQueue *downloadOperationQueue;;

@end


@implementation PhotoManager

- (id)init
{
	self = [super init];
	
	if (self)
	{
		self.downloadOperationQueue = [NSOperationQueue new];
	}
	
	return self;
}

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

- (void)imageWithSourceURL:(NSURL *)url
			 completionBlock:(void (^)(NSString *fullImagePath,
									   NSString *smallImagePath))completionBlock
{
	NSParameterAssert(completionBlock);
	
//	dispatch_queue_t downloadQueue = dispatch_queue_create(NULL, NULL);
	
//	dispatch_async(downloadQueue, ^{
	
	DownloadImageOperation *downloadImageOperation = [[DownloadImageOperation alloc] initWithImageURL:url
																					  completionBlock:
													  ^(NSString *fullImagePath, NSString *smallImagePath) {

														  dispatch_async(dispatch_get_main_queue(), ^{
															  completionBlock(fullImagePath, smallImagePath);
														  });
														  
													  }];
	
				
	[self.downloadOperationQueue addOperation:downloadImageOperation];
}

+ (UIImage *)imageWithFilePath:(NSString *)filePath
{
	NSString *fullPath = [PhotoManager documentPathWithFileName:filePath];
	return [UIImage imageWithContentsOfFile:fullPath];
}



@end
