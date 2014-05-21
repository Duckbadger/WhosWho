//
//  NetworkClient.h
//  Who's Who
//
//  Created by Ken Boucher on 21/05/2014.
//  Copyright (c) 2014 Ken Boucher. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkClient : NSObject

- (id)init;
- (NSSet *)fetchProfileMappingDictionaries:(NSError **)error;

@end
