//
//  NSManagedObject+CoreDataManagerExtensions.h
//  Who's Who
//
//  Created by Ken Boucher on 10/05/2014.
//  Copyright (c) 2014 Ken Boucher. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (CoreDataManagerExtensions)

+ (NSString *)entityName;
+ (instancetype)insertInContext:(NSManagedObjectContext *)context;


@end
