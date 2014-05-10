//
//  AppBusinessProfilesFetcher.m
//  Who's Who
//
//  Created by Ken Boucher on 10/05/2014.
//  Copyright (c) 2014 Ken Boucher. All rights reserved.
//

#import "AppBusinessProfilesFetcher.h"
#import <TFHpple.h>

@implementation AppBusinessProfilesFetcher

+ (NSArray *)fetchProfiles
{
	// First get the html data from the TAB profiles page
	NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://www.theappbusiness.com/our-team/"]];
	
	// HTML parser
	TFHpple *htmlParser = [TFHpple hppleWithHTMLData:data];
	
	/*
	 *	Note - Format is as follows:
	 *	Also note [] means there are multiples of this element
	 *	<section id="users">	// Start here, class=wrapper is repeated elsewhere
	 *		class="wrapper"
	 *			[]<div class="row">
	 *				[]<div class="col col2">
	 *					<div class="title">
	 *						<img />
	 *					<h3> // Name
	 *					<p> // Position
	 *					<p class="user-description"> // Bio
	 */
	
	//div[@class='column']
    NSString *userSectionXpathQueryString = @"//div[@class='wrapper']";//@"<section id=\"users\">";
	NSArray *userSectionArray = [htmlParser searchWithXPathQuery:userSectionXpathQueryString];
	
	

	NSLog(@"end");
	return @[];
}

@end
