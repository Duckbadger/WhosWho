//
//  DownloadImageOperation.h
//  Who's Who
//
//  Created by Ken Boucher on 21/05/2014.
//  Copyright (c) 2014 Ken Boucher. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DownloadImageOperation : NSOperation

- (id)initWithImageURL:(NSURL *)imageURL
	   completionBlock:(void (^)(NSString *fullImagePath,
								 NSString *smallImagePath,
								 BOOL cancelled))imageCompletionBlock;

@end
