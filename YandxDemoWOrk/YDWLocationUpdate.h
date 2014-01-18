//
//  YDWLocationUpdate.h
//  YandxDemoWOrk
//
//  Created by Dmitriy Remezov on 23.12.13.
//  Copyright (c) 2013 Dmitriy Remezov. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

typedef void(^locationHandler)(CLLocation *location);

@interface YDWLocationUpdate : NSObject <CLLocationManagerDelegate>
{
    @private UIBackgroundTaskIdentifier bgTask;
    bool isFirstLocationUpdate;
}

@property (nonatomic, strong) CLLocationManager *locationManager;


@property (nonatomic, copy) locationHandler locationUpdatedInForeground;
@property (nonatomic, copy) locationHandler locationUpdatedInBackground;

- (void)startUpdatingLocation;
- (void)stopUpdatingLocation;

@end
