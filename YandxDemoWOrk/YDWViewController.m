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
#import "YDWCoffeAnnotation.h"
#import <Social/Social.h>

//#define METERS_PER_MILE 1609.344
//#define distanceFilterCONST 300.0

@interface YDWViewController ()

@end

@implementation YDWViewController
@synthesize routeView, routeLine, routeLineView, isAnnotationHide, isCoffeHide, showCaffeButton;



- (UIBarPosition)positionForBar:(id <UIBarPositioning>)bar
{
    //подстройка tabBar для iOS 7
    CGRect frame = self.toolBar.frame;
    frame.origin = CGPointMake(0, [UIApplication sharedApplication].statusBarFrame.size.height);
    self.toolBar.frame = frame;
    return UIBarPositionTopAttached;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    //инициализация массива для хранения отображаемого трека
    self.routeArray = [[NSMutableArray alloc] init];
    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, 162)];
    self.fromDateTextField.inputView = self.datePicker;
    self.toDateTextField.inputView = self.datePicker;
    [self showUserRoute];
    isCoffeHide = YES;

    //инициализация менеджера местоположения, с возможностью работы в фоне
    self.locationBackForeManager = [[YDWLocationUpdate alloc] init];
    //передача блока для работы НЕ в фоне
    __weak id weakSelf = self;
    [self.locationBackForeManager setLocationUpdatedInForeground:^ (CLLocation *location) {
        if (location) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //настройка даты для аннотации
                NSDate *currentDate = [NSDate dateWithTimeIntervalSinceNow:[[NSTimeZone localTimeZone] secondsFromGMT]];
                dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{     
                    
                    //добавление точки в БД
                [[(YDWAppDelegate *)[[UIApplication sharedApplication] delegate] DB] addPointDate:currentDate coordinates:location.coordinate];
                });
                [weakSelf showUserRoute];
            });
        }
    }];
    //передача блока для работы в фоне
    [self.locationBackForeManager setLocationUpdatedInBackground:^ (CLLocation *location) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDate *currentDate = [NSDate dateWithTimeIntervalSinceNow:[[NSTimeZone localTimeZone] secondsFromGMT]];
            dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                //добавление точки в БД
                [[(YDWAppDelegate *)[[UIApplication sharedApplication] delegate] DB] addPointDate:currentDate coordinates:location.coordinate];
            });
        });
        NSLog(@"%@", location);
    }];
    
    //запуск менеджера местоположения
    [self.locationBackForeManager startUpdatingLocation];
    
    //назначаем делегат toolBar'у
	self.toolBar.delegate = self;
    
    //инициализация представления карты
    self.mapView.mapType = MKMapTypeStandard;
    self.mapView.delegate = self;
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.mapView = nil;
    self.locationBackForeManager = nil;
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



#pragma MapView

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

- (IBAction)showWhereIAm:(id)sender {
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
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

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if([annotation isKindOfClass:[MKUserLocation class]] || ([annotation isKindOfClass:[YDWAnnotation class]]))
        return nil;
    
    
    NSString *annotationIdentifier = @"PinViewAnnotation";
    
    YDWCoffeAnnotation *pinView = (YDWCoffeAnnotation *) [mapView
                                                          dequeueReusableAnnotationViewWithIdentifier:
                                                          annotationIdentifier];
    
    if (!pinView)
    {
        pinView = [[YDWCoffeAnnotation alloc]
                   initWithAnnotation:annotation
                   reuseIdentifier:annotationIdentifier];
        pinView.canShowCallout = YES;
    }
    else
    {
        pinView.annotation = annotation;
    }
    
    return pinView;
}

#pragma Route
//показать пройденный пользователем маршрут за заданный интервал
- (void) showUserRoute
{
    NSTimeZone *zone = [NSTimeZone localTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:self.datePicker.date];
    [[self routeArray] removeAllObjects];
    NSArray *tempArray;
    if (_toDateToShowRoute == 0 || _fromDateToShowRoute == 0) {
        //показывает только точки за последние 24 часа
        NSDate *startDate = [[NSDate date] dateByAddingTimeInterval:-60*60*24+interval];
        NSDate *endDate = [[NSDate date] dateByAddingTimeInterval:interval];
        
        tempArray = [[(YDWAppDelegate *)[[UIApplication sharedApplication] delegate] DB] searchPointsFromDate:startDate toDate:endDate];
    }else
    {
        tempArray = [[(YDWAppDelegate *)[[UIApplication sharedApplication] delegate] DB] searchPointsFromDate:_fromDateToShowRoute toDate:_toDateToShowRoute];
    }
    (nil != [self routeLine])?[[self mapView] removeOverlay:[self routeLine]]:nil;
    [self clearRouteAnnotation];
    for (Points *item in tempArray) {
        YDWAnnotation *tempAnnotation = [[YDWAnnotation alloc] initWithCoordinates:CLLocationCoordinate2DMake([item.latitude doubleValue], [item.longtitude doubleValue]) title:[NSString stringWithFormat:@"%@", item.date] subTitle:@""];
        [[self routeArray] addObject:tempAnnotation];
        [self isAnnotationHide]?nil:[[self mapView] addAnnotation:tempAnnotation];
    }
    [self loadRoute];
    (nil != [self routeLine])?[[self mapView] addOverlay:[self routeLine ]]:nil;
    tempArray = Nil;
}

//создание линии для маршрута и выделение области с маршрутом
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

//добавить изображение маршрута на карту
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
	MKOverlayView* overlayView = nil;
    self.routeLineView = nil;
    self.routeLineView = [[MKPolylineView alloc] initWithPolyline:self.routeLine];
	self.routeLineView.fillColor = [UIColor redColor];
	self.routeLineView.strokeColor = [UIColor redColor];
	self.routeLineView.lineWidth = 3;
	overlayView = self.routeLineView;
	
	return overlayView;
	
}


#pragma annotations
//показать/скрыть метки на карте
- (IBAction)showAndHideAnnotation:(id)sender {
    if (isAnnotationHide == NO) {
        isAnnotationHide = YES;
        [self clearRouteAnnotation];
    }else
    {
        isAnnotationHide = NO;
        [self showUserRoute];
        //[self.mapView addAnnotations:self.routeArray];
    }
}

//очистка интервала выборки контрольных точек
- (IBAction)clearInterval:(id)sender
{
    self.fromDateTextField.text = @"";
    self.toDateTextField.text = @"";
    _fromDateToShowRoute = 0;
    _toDateToShowRoute = 0;
    [self showUserRoute];
}

//показать весь пройденный маршрут
- (IBAction)showAllUserRoute:(id)sender {
    [self zoomInOnRoute];
}

//показать участок карты с треком
-(void) zoomInOnRoute
{
	[self.mapView setVisibleMapRect:_routeRect];
}

//удаление аннотаций маршрута с карты
- (void)clearRouteAnnotation
{
    NSArray *tempAnnotationArray = [self.mapView annotations];
    for (int i =0; i<tempAnnotationArray.count; i++)
    {
        if ([[tempAnnotationArray objectAtIndex:i] isKindOfClass:[YDWAnnotation class]])
        {
            [[self mapView] removeAnnotation:[tempAnnotationArray objectAtIndex:i]];
        }
    }
    tempAnnotationArray = nil;
}

#pragma dataChooseTextField

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

//выбраны даты выборки
- (void) textFieldDidEndEditing:(UITextField *)textField
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd.MM.yyyy HH:mm:ss";
    
    NSTimeZone *zone = [NSTimeZone localTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:self.datePicker.date];
    
    if (textField.tag == 10) {
        textField.text = [dateFormatter stringFromDate:self.datePicker.date];
        _fromDateToShowRoute = [self.datePicker.date dateByAddingTimeInterval:interval];
        NSLog(@"%@", _fromDateToShowRoute);
        
    }else
    {
        textField.text = [dateFormatter stringFromDate:self.datePicker.date];
        _toDateToShowRoute = [self.datePicker.date dateByAddingTimeInterval:interval];
        NSLog(@"%@", _toDateToShowRoute);
        
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showUserRoute];
    });
    
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += 215;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:-10];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
    [textField resignFirstResponder];
}


//сдвигает вьюху чтобы показать пикер
- (void) textFieldDidBeginEditing:(UITextField *)textField{
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += -215;     
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:-10];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

#pragma I need coffe
//показать ближайшие работающие кофейни
- (IBAction)showCoffe:(id)sender
{
    if (isCoffeHide)
    {
        [sender setEnabled:NO];
        [self.activityIndicator setHidden:NO];
        [self.activityIndicator startAnimating];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            
            [[self mapView] removeAnnotations:[self.mapView annotations]];
            [self.mapView addAnnotations:self.routeArray];
            
            YDWCoffeSearch *coffeObject = [[YDWCoffeSearch alloc] initWithLocation:[[self.locationBackForeManager.locationManager location] coordinate]];
            switch ([coffeObject searchCaffe]) {
                case 0:
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"Нет данных" message:@"В данном месте нет открытых кафе поблизости" delegate:nil cancelButtonTitle:@"ОК" otherButtonTitles: nil];
                        [errorView show];
                        [self showUserRoute];
                        [self.activityIndicator stopAnimating];
                        [sender setEnabled:YES];
                    });
                    break;
                }
                case 1:
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[self mapView] addAnnotations:coffeObject.caffePlaces];
                        [self showUserRoute];
                        isCoffeHide = NO;
                        [self.activityIndicator stopAnimating];
                        [sender setEnabled:YES];
                        
                    });
                    break;
                }
                case -1:
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:@"Нет соединения с Интернетом, проверьте возможность доступа в сеть Интернет" delegate:nil cancelButtonTitle:@"ОК" otherButtonTitles: nil];
                        [errorView show];
                        [self showUserRoute];
                        [self.activityIndicator stopAnimating];
                        [sender setEnabled:YES];
                        
                    });
                    break;
                }
                default:
                    break;
            }
                    });

    }else
    {
        isCoffeHide = YES;
        [[self mapView] removeAnnotations:[self.mapView annotations]];
        [self.mapView addAnnotations:self.routeArray];
    }
}


@end
