//
//  UNRouteView.m
//  MapExample
//
//  Created by Alximik on 11.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "UNRouteView.h"

@implementation UNRouteView
@synthesize map;
@synthesize points;
@synthesize lineColor; 

-(void) dealloc
{
	self.points = nil;
    self.lineColor = nil;
}

-(id) initWithRoute:(NSArray*)routePoints mapView:(MKMapView*)mapView
{
	self = [super initWithFrame:CGRectMake(0.0f, 0.0f, mapView.frame.size.width, mapView.frame.size.height)];
    self.backgroundColor = [UIColor clearColor];
	
	[self setMap:mapView];
	[self setPoints:routePoints];
	
	CLLocationDegrees maxLat = -90;
	CLLocationDegrees maxLon = -180;
	CLLocationDegrees minLat = 90;
	CLLocationDegrees minLon = 180;
	
	for(int i = 0; i < self.points.count; i++)
	{
		CLLocation* currentLocation = [self.points objectAtIndex:i];
		if(currentLocation.coordinate.latitude > maxLat)
			maxLat = currentLocation.coordinate.latitude;
		if(currentLocation.coordinate.latitude < minLat)
			minLat = currentLocation.coordinate.latitude;
		if(currentLocation.coordinate.longitude > maxLon)
			maxLon = currentLocation.coordinate.longitude;
		if(currentLocation.coordinate.longitude < minLon)
			minLon = currentLocation.coordinate.longitude;
	}
	
	[self setUserInteractionEnabled:NO];
	[self.map addSubview:self];
    
	return self;
}


- (void)drawRect:(CGRect)rect
{
	if(!self.hidden && nil != self.points && self.points.count > 0)
	{
		CGContextRef context = UIGraphicsGetCurrentContext(); 
		
		if(!self.lineColor) {self.lineColor = [UIColor blueColor];}
		
		CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
		CGContextSetRGBFillColor(context, 0.0, 0.0, 1.0, 1.0);
        
		CGContextSetLineWidth(context, 2.0);
		
		for(int i = 0; i < self.points.count; i++) {
			CLLocation* location = [self.points objectAtIndex:i];
			CGPoint point = [map convertCoordinate:location.coordinate toPointToView:self];
			
			if(i == 0) {
				CGContextMoveToPoint(context, point.x, point.y);
			} else {
				CGContextAddLineToPoint(context, point.x, point.y);
			}
		}
		
		CGContextStrokePath(context);
	}
}

@end
