//
//  Points.h
//  YandxDemoWOrk
//
//  Created by Dmitriy Remezov on 24.12.13.
//  Copyright (c) 2013 Dmitriy Remezov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Points : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * longtitude;
@property (nonatomic, retain) NSNumber * latitude;

@end
