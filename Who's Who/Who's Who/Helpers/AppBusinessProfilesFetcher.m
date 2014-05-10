//
//  AppBusinessProfilesFetcher.m
//  Who's Who
//
//  Created by Ken Boucher on 10/05/2014.
//  Copyright (c) 2014 Ken Boucher. All rights reserved.
//

#import "AppBusinessProfilesFetcher.h"

@implementation AppBusinessProfilesFetcher

+ (NSData *)dataForNSURL:(NSURL *)url
{
    NSData *htmlData = [NSData dataWithContentsOfURL:url];
	
	return htmlData;
}

+ (NSArray *)fetchProfiles
{
	
	return @[];
}

@end
