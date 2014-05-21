//
//  PhotoManager.h
//  Who's Who
//
//  Created by Ken Boucher on 20/05/2014.
//  Copyright (c) 2014 Ken Boucher. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhotoManager : NSObject

@property (strong, nonatomic, readonly) NSMutableDictionary *operationDictionary;

- (id)init;

+ (BOOL)fileExistsWithFileName:(NSString *)fileName;

- (void)imageWithSourceURL:(NSURL *)url
				 indexPath:(NSIndexPath *)indexPath
		   completionBlock:(void (^)(NSString *fullImagePath,
									 NSString *smallImagePath,
									 BOOL cancelled))completionBlock;
+ (UIImage *)imageWithFilePath:(NSString *)filePath;

@end
