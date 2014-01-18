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
        isFirstLocationUpdate = YES;
        //инициализация менеджера локации
        if ([CLLocationManager locationServicesEnabled]) {
            self.locationManager = [[CLLocationManager alloc] init];
            self.locationManager.delegate = self;
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
            self.locationManager.distanceFilter = 100.0;
        }else{
        //оповещение пользователя о неработающем навигаторе
            UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:@"Нет доступа к сервису определения геопозиции. Проверьте настройки приватности для приложения." delegate:nil cancelButtonTitle:@"ОК" otherButtonTitles: nil];
            [errorView show];
            NSLog(@"Location service are not enabled.");
        }
        
    }
    return self;
}

//- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
//{
//    UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:@"Нет доступа к сервису определения геопозиции. Проверьте настройки приватности для приложения." delegate:nil cancelButtonTitle:@"ОК" otherButtonTitles: nil];
//    [errorView show];
//    NSLog(@"Location service are not enabled.");
//    NSLog(@"Error: %@", error.description);
//    
//}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//приложение вышло из фона
- (void)applicationDidBecomeActive {
    [self.locationManager stopMonitoringSignificantLocationChanges];
    [self.locationManager startUpdatingLocation];
}

//приложение вошло в фон
- (void)applicationDidEnterBackground {
    [self.locationManager stopUpdatingLocation];
    [self.locationManager startMonitoringSignificantLocationChanges];
}

//начать обновлять местоположение
- (void)startUpdatingLocation {
    [self stopUpdatingLocation];
    [self isInBackground] ? [self.locationManager startMonitoringSignificantLocationChanges] : [self.locationManager startUpdatingLocation];
}

//остановить обновление местоположения
- (void)stopUpdatingLocation {
    [self.locationManager stopUpdatingLocation];
    [self.locationManager stopMonitoringSignificantLocationChanges];
}

//проверка в фоне ли приложение
- (BOOL)isInBackground {
    return [UIApplication sharedApplication].applicationState == UIApplicationStateBackground;
}

//завершение фоновой задачи
- (void)endBackgroundTask {
    if (bgTask != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    if (([newLocation distanceFromLocation:oldLocation] > 50.0) || isFirstLocationUpdate)
    {
    isFirstLocationUpdate = NO;
    if ([CLLocationManager locationServicesEnabled]) {
        //задержка работы менеджера геолокации в зависимости от скорости перемещения
        if (![self isInBackground])
        {
            if ([newLocation.timestamp timeIntervalSinceDate:oldLocation.timestamp] < 4.0) {
                [self stopUpdatingLocation];
                double delayInSeconds = 30.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [self startUpdatingLocation];
                });
                return;
            }else if ([newLocation.timestamp timeIntervalSinceDate:oldLocation.timestamp]< 8.0)
            {
                [self stopUpdatingLocation];
                double delayInSeconds = 45.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [self startUpdatingLocation];
                });
                return;
            }else if ([newLocation.timestamp timeIntervalSinceDate:oldLocation.timestamp] < 16.0)
            {
                [self stopUpdatingLocation];
                double delayInSeconds = 60.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [self startUpdatingLocation];
                });
                return;
            }else if([newLocation.timestamp timeIntervalSinceDate:oldLocation.timestamp] < 32.0)
            {
                [self stopUpdatingLocation];
                double delayInSeconds = 90.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [self startUpdatingLocation];
                });
                return;
            }
            
        }
        
        NSLog(@"%f",[newLocation.timestamp timeIntervalSinceDate:oldLocation.timestamp]);
        
        //выполнение блоков, заданных при инициализации
        if ([self isInBackground]) {
            if (self.locationUpdatedInBackground) {
                bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler: ^{
                    [[UIApplication sharedApplication] endBackgroundTask:bgTask];
                }];
                self.locationUpdatedInBackground(newLocation);
                NSLog(@"Add location in back");
                [self endBackgroundTask];
            }
        } else {
            if (self.locationUpdatedInForeground) {
                self.locationUpdatedInForeground(newLocation);
                NSLog(@"Add location in fore");
            }
        }
    }
    }
    
}


@end

