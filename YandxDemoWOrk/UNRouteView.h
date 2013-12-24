//
//  UNRouteView.h
//  MapExample
//
//  Created by Alximik on 11.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface UNRouteView : UIView

@property (nonatomic, assign) MKMapView *map;
@property (nonatomic, retain) NSArray *points;
@property (nonatomic, retain) UIColor *lineColor;

- (id)initWithRoute:(NSArray*)routePoints mapView:(MKMapView*)mapView;

@end
