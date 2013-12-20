//
//  YDWViewController.m
//  YandxDemoWOrk
//
//  Created by Dmitriy Remezov on 20.12.13.
//  Copyright (c) 2013 Dmitriy Remezov. All rights reserved.
//

#import "YDWViewController.h"

@interface YDWViewController ()

@end

@implementation YDWViewController

- (UIBarPosition)positionForBar:(id <UIBarPositioning>)bar
{
    CGRect frame = self.toolBar.frame;
    frame.origin = CGPointMake(0, [UIApplication sharedApplication].statusBarFrame.size.height);
    self.toolBar.frame = frame;
    return UIBarPositionTopAttached;
}

- (void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"%f", newLocation.coordinate.latitude);
    NSLog(@"%f", newLocation.coordinate.longitude);
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"%@", error);
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    //назначаем делегат toolBar'у
	self.toolBar.delegate = self;
    //инициализация представления карты
    self.mapView = [[MKMapView alloc] init];
    self.mapView.mapType = MKMapTypeStandard;
    self.mapView.delegate = self;
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    //инициализация менеджера локации
    if ([CLLocationManager locationServicesEnabled]) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        [self.locationManager startUpdatingLocation];
    }else{
        NSLog(@"Location service are not enabled.");
    }
}

- (void) viewDidUnload
{
    self.mapView = nil;
    [self.locationManager stopUpdatingLocation ];
    self.locationManager = nil;
}

- (void) viewWillAppear:(BOOL)animated
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
