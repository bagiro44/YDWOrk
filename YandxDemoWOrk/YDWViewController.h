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
#import "UNRouteView.h"
#import "YDWLocationUpdate.h"
#import "YDWCoffeSearch.h"

@interface YDWViewController : UIViewController <UIToolbarDelegate, MKMapViewDelegate, CLLocationManagerDelegate, UITextFieldDelegate>
{
    MKMapRect _routeRect;
    NSDate* _fromDateToShowRoute;
    NSDate* _toDateToShowRoute;
}



- (IBAction)showCoffe:(id)sender;
- (IBAction)showAllUserRoute:(id)sender;
- (IBAction)showAndHideAnnotation:(id)sender;


@property BOOL isAnnotationHide;
@property BOOL isCoffeHide;

@property (strong, nonatomic) YDWLocationUpdate *locationBackForeManager;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet UITextField *fromDateTextField;
@property (weak, nonatomic) IBOutlet UITextField *toDateTextField;
@property (strong, nonatomic) UIDatePicker *datePicker;

@property (strong, nonatomic) UNRouteView *routeView;
@property (strong, nonatomic) NSMutableArray *routeArray;
@property (nonatomic, retain) MKPolyline* routeLine;
@property (nonatomic, retain) MKPolylineView* routeLineView;


- (IBAction)showWhereIAm:(id)sender;
- (IBAction)changeMapType:(id)sender;
- (IBAction)clearInterval:(id)sender;
- (void)clearRouteAnnotation;
- (void)showUserRoute;



@end
