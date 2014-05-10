//
//  CoreDataManager.m
//  Who's Who
//
//  Created by Ken Boucher on 10/05/2014.
//  Copyright (c) 2014 Ken Boucher. All rights reserved.
//

#import "CoreDataManager.h"

@interface CoreDataManager ()

@property (strong, nonatomic) NSString *storeType;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;

@end

@implementation CoreDataManager

- (id)initWithStoreType:(NSString *)storeType managedObjectModel:(NSManagedObjectModel *)managedObjectModel
{
    self = [super init];
 
	if (self)
	{
		self.storeType = storeType;
		self.managedObjectModel = managedObjectModel;
	}
    return self;
}

@end
