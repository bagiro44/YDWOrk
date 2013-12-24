//
//  YDWViewController.m
//  YandxDemoWOrk
//
//  Created by Dmitriy Remezov on 20.12.13.
//  Copyright (c) 2013 Dmitriy Remezov. All rights reserved.
//

#import "YDWViewController.h"
#import "YDWAnnotation.h"
#import "YDWAppDelegate.h"
#import "YDWDBLogViewController.h"

#define METERS_PER_MILE 1609.344
#define distanceFilterCONST 300.0

@interface YDWViewController ()

@end

@implementation YDWViewController
@synthesize routeView, routeLine, routeLineView, isAnnotationHide;

- (UIBarPosition)positionForBar:(id <UIBarPositioning>)bar
{
    //подстройка tabBar для iOS 7
    CGRect frame = self.toolBar.frame;
    frame.origin = CGPointMake(0, [UIApplication sharedApplication].statusBarFrame.size.height);
    self.toolBar.frame = frame;
    return UIBarPositionTopAttached;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    if ([self.fromDateTextField isFirstResponder] && [touch view] != self.fromDateTextField)
    {[self.fromDateTextField resignFirstResponder];}
    else if ([self.toDateTextField isFirstResponder] && [touch view] != self.toDateTextField)
    {[self.toDateTextField resignFirstResponder];}
    [super touchesBegan:touches withEvent:event];
}

- (void) textFieldDidBeginEditing:(UITextField *)textField{
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += -215;  /*specify the points to move the view up*/
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:-10];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += 215;   /*specify the points to move the view down*/
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:-10];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
    [textField resignFirstResponder];
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, 162)];
    
    self.fromDateTextField.inputView = self.datePicker;
    
    
    
    
    //инициализация менеджера местоположения, с возможностью работы в фоне
    self.locationBackForeManager = [[YDWLocationUpdate alloc] init];
    //передача блока для работы НЕ в фоне
    [self.locationBackForeManager setLocationUpdatedInForeground:^ (CLLocation *location) {
        if (location) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //настройка даты для аннотации
                NSDate *currentDate = [NSDate dateWithTimeIntervalSinceNow:[[NSTimeZone localTimeZone] secondsFromGMT]];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
                dateFormatter.dateFormat = @"dd-MM-yyyy HH:mm:ss";
                [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
                
                //создание новой аннотации
                YDWAnnotation *newAnnotation = [[YDWAnnotation alloc] initWithCoordinates:[location coordinate] title:[NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:currentDate]] subTitle:@""];
                
                //добавление аннотации на карту
                isAnnotationHide?nil:[[self mapView] addAnnotation:newAnnotation];
                
                //добавление аннотации в трек
                [[self routeArray] addObject:newAnnotation];
                
                //добавление точки в БД
                [[(YDWAppDelegate *)[[UIApplication sharedApplication] delegate] DB] addPointDate:currentDate coordinates:location.coordinate];
                
                //отображение трека
                (nil != [self routeLine])?[[self mapView] removeOverlay:[self routeLine ]]:nil;
                [self loadRoute];
                (nil != [self routeLine])?[[self mapView] addOverlay:[self routeLine ]]:nil;
            });
        }
    }];
    //передача блока для работы в фоне
    [self.locationBackForeManager setLocationUpdatedInBackground:^ (CLLocation *location) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            YDWAnnotation *newAnnotation = [[YDWAnnotation alloc] initWithCoordinates:[location coordinate] title:[NSString stringWithFormat:@"%@", [[[NSDate alloc] init] description]] subTitle:@""];
            isAnnotationHide?nil:[[self mapView] addAnnotation:newAnnotation];
            [[self routeArray] addObject:newAnnotation];
        });
        NSLog(@"%@", location);
    }];
    
    //запуск менеджера местоположения
    [self.locationBackForeManager startUpdatingLocation];
    
    //инициализация массива для хранения отображаемого трека
    self.routeArray = [[NSMutableArray alloc] init];
    
    //назначаем делегат toolBar'у
	self.toolBar.delegate = self;
    
    //инициализация представления карты
    self.mapView.mapType = MKMapTypeStandard;
    self.mapView.delegate = self;
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
}

- (void) dealloc
{
    self.mapView = nil;
    self.locationBackForeManager = nil;
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
	routeView.hidden = YES;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
	routeView.hidden = NO;
	[routeView setNeedsDisplay];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    //путем смены вида карты получается очистить память до 50-70 мб
    switch (self.mapView.mapType) {
        case MKMapTypeHybrid:
        {
            self.mapView.mapType = MKMapTypeStandard;
            self.mapView.mapType = MKMapTypeHybrid;
        }
            
            break;
        case MKMapTypeStandard:
        {
            self.mapView.mapType = MKMapTypeHybrid;
            self.mapView.mapType = MKMapTypeStandard;
        }
            
            break;
        default:
            break;
    }
}

- (IBAction)showWhereIAm:(id)sender {
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
	MKOverlayView* overlayView = nil;
		if(nil == self.routeLineView)
		{
			self.routeLineView = [[MKPolylineView alloc] initWithPolyline:self.routeLine];
			self.routeLineView.fillColor = [UIColor redColor];
			self.routeLineView.strokeColor = [UIColor redColor];
			self.routeLineView.lineWidth = 3;
		}else
        {
            self.routeLineView = nil;
            self.routeLineView = [[MKPolylineView alloc] initWithPolyline:self.routeLine];
			self.routeLineView.fillColor = [UIColor redColor];
			self.routeLineView.strokeColor = [UIColor redColor];
			self.routeLineView.lineWidth = 3;
        }
		
		overlayView = self.routeLineView;
	
	return overlayView;
	
}

-(void) loadRoute
{
	MKMapPoint northEastPoint;
	MKMapPoint southWestPoint;
	
    
    MKMapPoint* points = malloc(sizeof(CLLocationCoordinate2D) * self.routeArray.count);
	
	for(int i = 0; i < self.routeArray.count; i++)
	{
        CLLocationCoordinate2D coordinate = [[self.routeArray objectAtIndex:i] coordinate];
		MKMapPoint point = MKMapPointForCoordinate(coordinate);
		if (i == 0) {
			northEastPoint = point;
			southWestPoint = point;
		}
		else
		{
			if (point.x > northEastPoint.x)
				northEastPoint.x = point.x;
			if(point.y > northEastPoint.y)
				northEastPoint.y = point.y;
			if (point.x < southWestPoint.x)
				southWestPoint.x = point.x;
			if (point.y < southWestPoint.y)
				southWestPoint.y = point.y;
		}
        
		points[i] = point;
        
	}

	self.routeLine = [MKPolyline polylineWithPoints:points count:self.routeArray.count];
    
	_routeRect = MKMapRectMake(southWestPoint.x, southWestPoint.y, northEastPoint.x - southWestPoint.x, northEastPoint.y - southWestPoint.y);
	free(points);
	
}

-(void) zoomInOnRoute
{
	[self.mapView setVisibleMapRect:_routeRect];
}


- (IBAction)changeMapType:(id)sender {
    //изменение типа карты
    switch ([sender selectedSegmentIndex]) {
        case 0:
            self.mapView.mapType = MKMapTypeStandard;
            break;
        case 1:
            self.mapView.mapType = MKMapTypeSatellite;
            break;
        case 2:
            self.mapView.mapType = MKMapTypeHybrid;
            break;
        default:
            break;
    }
}


- (IBAction)clearInterval:(id)sender
{
    //_fromDate = ;
    //_toDate = ;
}
- (IBAction)settingsAction:(id)sender {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    YDWDBLogViewController *detailController = (YDWDBLogViewController *)[storyboard instantiateViewControllerWithIdentifier:@"logView"];
    NSMutableArray *arr = [[(YDWAppDelegate *)[[UIApplication sharedApplication] delegate] DB] searchPointsFromDate:[[NSDate alloc] init] toDate:[[NSDate alloc] init]];
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:[arr count]];
    for (Points *item in arr) {
        [tempArray addObject:[NSString stringWithFormat:@"Date: %@ \ncoordinate: %@, \n%@ \n", item.date,
                                              item.latitude, item.longtitude]];
    }
    detailController.arrayLog = tempArray;
    [detailController setModalPresentationStyle:UIModalPresentationCurrentContext];
    [self presentModalViewController:detailController animated:YES];
    
    if (nil != self.routeLine) {
        [self.mapView removeOverlay:self.routeLine];
        self.routeLine = nil;
	}
    [self loadRoute];
	if (nil != self.routeLine) {
		[self.mapView addOverlay:self.routeLine];
	}
	[self zoomInOnRoute];
}

- (IBAction)showHideAnnotations:(id)sender {
    //показать/скрыть аннотации на карте
    if ([self.mapView.annotations count] > 1) {
        isAnnotationHide = YES;
        [self.mapView removeAnnotations:self.routeArray];
    }else
    {
        isAnnotationHide = NO;
       [self.mapView addAnnotations:self.routeArray];
    }
    
}
@end
