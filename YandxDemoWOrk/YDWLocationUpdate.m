//
//  YDWLocationUpdate.m
//  YandxDemoWOrk
//
//  Created by Dmitriy Remezov on 23.12.13.
//  Copyright (c) 2013 Dmitriy Remezov. All rights reserved.
//
//  менеджер локаций кастомный
//

#import "YDWLocationUpdate.h"

@implementation YDWLocationUpdate : NSObject

- (id)init {
    if (self = [super init]) {
        
        //настройка слушателя
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:    UIApplicationDidEnterBackgroundNotification object:nil];
        
        //инициализация менеджера локации
        if ([CLLocationManager locationServicesEnabled]) {
            self.locationManager = [[CLLocationManager alloc] init];
            self.locationManager.delegate = self;
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
            self.locationManager.distanceFilter = 100.0;
        }else{
            NSLog(@"Location service are not enabled.");
        }
        
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)applicationDidBecomeActive {
    [self.locationManager stopMonitoringSignificantLocationChanges];
    [self.locationManager startUpdatingLocation];
}

- (void)applicationDidEnterBackground {
    [self.locationManager stopUpdatingLocation];
    [self.locationManager startMonitoringSignificantLocationChanges];
}


- (void)startUpdatingLocation {
    [self stopUpdatingLocation];
    [self isInBackground] ? [self.locationManager startMonitoringSignificantLocationChanges] : [self.locationManager startUpdatingLocation];
}

- (void)stopUpdatingLocation {
    [self.locationManager stopUpdatingLocation];
    [self.locationManager stopMonitoringSignificantLocationChanges];
}


- (BOOL)isInBackground {
    return [UIApplication sharedApplication].applicationState == UIApplicationStateBackground;
}


- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    //задержка работы менеджера геолокации в зависимости от скорости перемещения
    if ([newLocation.timestamp timeIntervalSinceDate:oldLocation.timestamp] < 4.0) {
        [self stopUpdatingLocation];
        double delayInSeconds = 30.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self startUpdatingLocation];
        });
    }else if ([newLocation.timestamp timeIntervalSinceDate:oldLocation.timestamp]< 8.0)
    {
        [self stopUpdatingLocation];
        double delayInSeconds = 45.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self startUpdatingLocation];
        });
    }else if ([newLocation.timestamp timeIntervalSinceDate:oldLocation.timestamp] < 16.0)
    {
        [self stopUpdatingLocation];
        double delayInSeconds = 60.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self startUpdatingLocation];
        });
    }else if([newLocation.timestamp timeIntervalSinceDate:oldLocation.timestamp] < 32.0)
    {
        [self stopUpdatingLocation];
        double delayInSeconds = 90.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self startUpdatingLocation];
        });
    }
    
    NSLog(@"%f",[newLocation.timestamp timeIntervalSinceDate:oldLocation.timestamp]);
    
    //выпролнение блоков, заданных при инициализации
    if ([self isInBackground]) {
        if (self.locationUpdatedInBackground) {
            self.locationUpdatedInBackground(newLocation);
        }
    } else {
        if (self.locationUpdatedInForeground) {
            self.locationUpdatedInForeground(newLocation);
        }
    }
}


@end

