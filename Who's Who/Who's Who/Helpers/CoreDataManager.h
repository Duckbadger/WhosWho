//
//  CoreDataManager.h
//  Who's Who
//
//  Created by Ken Boucher on 10/05/2014.
//  Copyright (c) 2014 Ken Boucher. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "NSManagedObject+CoreDataManagerExtensions.h"

@interface CoreDataManager : NSObject

@property (strong, nonatomic, readonly) NSManagedObjectContext *mainContext;

- (id)initWithStoreType:(NSString *)storeType managedObjectModel:(NSManagedObjectModel *)managedObjectModel;

@end
