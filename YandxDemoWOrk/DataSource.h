//
//  DataSource.h
//  BookReader
//
//  Created by Dmitriy Remezov on 02.10.13.
//  Copyright (c) 2013 Dmitriy Remezov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>
#import "Points.h"

@interface DataSource : NSObject

@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

- (BOOL) addPointDate:(NSDate *)date coordinates:(CLLocationCoordinate2D)coordinates;
- (BOOL) deletePoint:(Points *)point;
- (NSMutableArray *) searchPointsFromDate:(NSDate *)fromDate toDate:(NSDate *) toDate;

@end
