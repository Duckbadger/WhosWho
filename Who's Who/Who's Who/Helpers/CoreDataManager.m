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
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic, readwrite) NSManagedObjectContext *mainContext;

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


- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
	if (!_persistentStoreCoordinator)
	{
		NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];

		NSURL *storeURL = [documentsURL URLByAppendingPathComponent:[NSString stringWithFormat:@"WhosWho.sqlite"]];
		
		NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
		
		NSDictionary *options = @{
								  NSMigratePersistentStoresAutomaticallyOption: @(YES),
								  NSInferMappingModelAutomaticallyOption : @(YES)
								  };
		NSError *error = nil;
		[persistentStoreCoordinator addPersistentStoreWithType:self.storeType
												 configuration:nil
														   URL:storeURL
													   options:options
														 error:&error];
		if (error)
		{
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			abort();
			
		}
		
		_persistentStoreCoordinator = persistentStoreCoordinator;
	}
	
	return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)mainContext
{
    if (!_mainContext)
	{
		_mainContext = [[NSManagedObjectContext alloc] init];
		_mainContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
    }
    
    return _mainContext;
}

@end
