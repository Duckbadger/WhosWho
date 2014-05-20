//
//  Profile.h
//  Who's Who
//
//  Created by Ken Boucher on 20/05/2014.
//  Copyright (c) 2014 Ken Boucher. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photo;

@interface Profile : NSManagedObject

@property (nonatomic, retain) NSString * biography;
@property (nonatomic, retain) NSData * fullImageData;
@property (nonatomic, retain) NSString * imageString;
@property (nonatomic, retain) NSDate * lastModified;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * position;
@property (nonatomic, retain) NSData * smallImageData;
@property (nonatomic, retain) NSSet *photos;
@end

@interface Profile (CoreDataGeneratedAccessors)

- (void)addPhotosObject:(Photo *)value;
- (void)removePhotosObject:(Photo *)value;
- (void)addPhotos:(NSSet *)values;
- (void)removePhotos:(NSSet *)values;

@end
