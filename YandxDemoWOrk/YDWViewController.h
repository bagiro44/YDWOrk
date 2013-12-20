//
//  YDWViewController.h
//  YandxDemoWOrk
//
//  Created by Dmitriy Remezov on 20.12.13.
//  Copyright (c) 2013 Dmitriy Remezov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface YDWViewController : UIViewController <UIToolbarDelegate, MKMapViewDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;

@end
