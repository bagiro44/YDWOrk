//
//  YDWLocationUpdate.m
//  YandxDemoWOrk
//
//  Created by Dmitriy Remezov on 23.12.13.
//  Copyright (c) 2013 Dmitriy Remezov. All rights reserved.
//

#import "YDWLocationUpdate.h"


static CGFloat const kMinUpdateDistance = 10.f;
static NSTimeInterval const kMinUpdateTime = 30.f;
static NSTimeInterval const kMaxTimeToLive = 30.f;

@implementation YDWLocationUpdate : NSObject


#pragma mark - NSObject

- (id)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:    UIApplicationDidEnterBackgroundNotification object:nil];
        //инициализация менеджера локации
        if ([CLLocationManager locationServicesEnabled]) {
                self.locationManager = [[CLLocationManager alloc] init];
                self.locationManager.delegate = self;
                self.locationManager.distanceFilter = 500;
        }else{
            NSLog(@"Location service are not enabled.");
        }
        
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Notification handlers

- (void)applicationDidBecomeActive {
    [self.locationManager stopMonitoringSignificantLocationChanges];
    [self.locationManager startUpdatingLocation];
}

- (void)applicationDidEnterBackground {
    [self.locationManager stopUpdatingLocation];
    [self.locationManager startMonitoringSignificantLocationChanges];
}

#pragma mark - Public

- (void)startUpdatingLocation {
    [self stopUpdatingLocation];
    [self isInBackground] ? [self.locationManager startMonitoringSignificantLocationChanges] : [self.locationManager startUpdatingLocation];
}

- (void)stopUpdatingLocation {
    [self.locationManager stopUpdatingLocation];
    [self.locationManager stopMonitoringSignificantLocationChanges];
}

- (void)endBackgroundTask {
    if (bgTask != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }
}
#pragma mark - Private

- (BOOL)isInBackground {
    return [UIApplication sharedApplication].applicationState == UIApplicationStateBackground;
}

#pragma mark - CLLocationManager Delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
//    if (oldLocation && ([newLocation.timestamp timeIntervalSinceDate:oldLocation.timestamp] < kMinUpdateTime)) {
//        return;
//    }
    
    if ([self isInBackground]) {
        if (self.locationUpdatedInBackground) {
            bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler: ^{
                [[UIApplication sharedApplication] endBackgroundTask:bgTask];
            }];
            
            self.locationUpdatedInBackground(newLocation);
            [self endBackgroundTask];
        }
    } else {
        if (self.locationUpdatedInForeground) {
            self.locationUpdatedInForeground(newLocation);
        }
    }
}


@end

