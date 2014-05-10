//
//  NSManagedObject+CoreDataManagerExtensions.m
//  Who's Who
//
//  Created by Ken Boucher on 10/05/2014.
//  Copyright (c) 2014 Ken Boucher. All rights reserved.
//

#import "NSManagedObject+CoreDataManagerExtensions.h"

@implementation NSManagedObject (CoreDataManagerExtensions)

+ (NSString *)entityName
{
    return NSStringFromClass([self class]);
}

+ (instancetype)insertInContext:(NSManagedObjectContext *)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:context];
}

+ (NSFetchRequest *)fetchRequest
{
    return [NSFetchRequest fetchRequestWithEntityName:[self entityName]];
}

@end
