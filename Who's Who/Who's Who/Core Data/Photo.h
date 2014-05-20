//
//  Photo.h
//  Who's Who
//
//  Created by Ken Boucher on 20/05/2014.
//  Copyright (c) 2014 Ken Boucher. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Profile;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSString * smallImageURL;
@property (nonatomic, retain) NSString * fullImageURL;
@property (nonatomic, retain) NSNumber * index;
@property (nonatomic, retain) Profile *profile;

@end
