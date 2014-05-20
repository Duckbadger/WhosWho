//
//  AppDelegate.m
//  Who's Who
//
//  Created by Ken Boucher on 10/05/2014.
//  Copyright (c) 2014 Ken Boucher. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:255.0/255
															  green:68.0/255
															   blue:0.0/255
															  alpha:1.0]];
	
	[[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
	
	NSDictionary *textTitleOptions = [NSDictionary dictionaryWithObjectsAndKeys:
									  [UIColor whiteColor], NSForegroundColorAttributeName,
									  nil];
	[[UINavigationBar appearance] setTitleTextAttributes:textTitleOptions];
	
	[[UIRefreshControl appearance] setTintColor:[UIColor colorWithRed:255.0/255
																green:68.0/255
																 blue:0.0/255
																alpha:1.0]];
	
    return YES;
}

- (CoreDataManager *)coreDataManager
{
    if (!_coreDataManager)
	{
        NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:nil];
        _coreDataManager = [[CoreDataManager alloc] initWithStoreType:NSSQLiteStoreType managedObjectModel:model];
    }
	
    return _coreDataManager;
}

@end
