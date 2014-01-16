//
//  DataSource.m
//  BookReader
//
//  Created by Dmitriy Remezov on 02.10.13.
//  Copyright (c) 2013 Dmitriy Remezov. All rights reserved.
//

#import "DataSource.h"

@implementation DataSource


- (NSArray *) searchPointsFromDate:(NSDate *)fromDate toDate:(NSDate *) toDate;
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *pointsEntity = [NSEntityDescription entityForName:@"Points" inManagedObjectContext:self.managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date >= %@", fromDate];
    NSPredicate *rp1 = [NSPredicate predicateWithFormat:@"date <= %@", toDate];
    predicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:predicate, rp1, nil]];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:pointsEntity];
    return [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
}



- (BOOL) addPointDate:(NSDate *)date coordinates:(CLLocationCoordinate2D)coordinates
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Points" inManagedObjectContext:self.managedObjectContext];
    //NSManagedObjectModel *iii = [NSEntityDescription insertNewObjectForEntityForName:[entity name]  inManagedObjectContext:self.managedObjectContext];
    Points *point = [[Points alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
    point.date = date;
    point.longtitude = [NSNumber numberWithDouble:coordinates.longitude];
    point.latitude = [NSNumber numberWithDouble:coordinates.latitude];
    if ([self saveContext])
    {
        return YES;
    }
    return NO;
}


- (BOOL) deletePoint:(Points *)point;
{
//    [self.managedObjectContext deleteObject:part];
//    if ([self saveContext]) {
//        return YES;
//    }
    return NO;
}


- (BOOL) saveContext
{
    if(nil != self.managedObjectContext){
        if([self.managedObjectContext hasChanges] && ![self.managedObjectContext save:nil])
        {
            NSLog(@"saveContext in datasource error");
            return NO;
            abort();
        }
    }
    return YES;
}


- (NSManagedObjectModel *)managedObjectModel
{
    if(nil != _managedObjectModel)
        return _managedObjectModel;
    
    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if(nil != _persistentStoreCoordinator)
        return _persistentStoreCoordinator;
    
    NSURL *storeURL = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                               inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:@"PointsDB.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    if(![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]){
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext
{
    if(nil != _managedObjectContext)
        return _managedObjectContext;
    
    NSPersistentStoreCoordinator *store = self.persistentStoreCoordinator;
    if(nil != store){
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:store];
    }
    
    return _managedObjectContext;
}

@end
