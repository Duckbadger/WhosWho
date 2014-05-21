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
		self.operationDictionary = [NSMutableDictionary new];
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
				 indexPath:(NSIndexPath *)indexPath
			 completionBlock:(void (^)(NSString *fullImagePath,
									   NSString *smallImagePath,
									   BOOL cancelled))completionBlock
{
	NSParameterAssert(completionBlock);
		
	__weak PhotoManager *weakSelf = self;
	DownloadImageOperation *downloadImageOperation = [[DownloadImageOperation alloc] initWithImageURL:url
																					  completionBlock:
													  ^(NSString *fullImagePath, NSString *smallImagePath, BOOL cancelled) {
														  
														  dispatch_async(dispatch_get_main_queue(), ^{
															  completionBlock(fullImagePath, smallImagePath, cancelled);
														  });
														  
														  [weakSelf.operationDictionary removeObjectForKey:indexPath];
																						  
													  }];

	
	// Only add to the operation dictionary if indexpath exists, may not need to keep track
	if (indexPath)
	{
		[self.operationDictionary setObject:downloadImageOperation forKey:indexPath];
	}
	
	[self.downloadOperationQueue addOperation:downloadImageOperation];
}

- (void)cancelDownloadWithIndexPath:(NSIndexPath *)indexPath
{
	DownloadImageOperation *downloadImageOperation = self.operationDictionary[indexPath];
	
	[downloadImageOperation cancel];
}

+ (UIImage *)imageWithFilePath:(NSString *)filePath
{
	NSString *fullPath = [PhotoManager documentPathWithFileName:filePath];
	return [UIImage imageWithContentsOfFile:fullPath];
}



@end
