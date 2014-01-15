//
//  YDWCoffeAnnot.h
//  YandxDemoWOrk
//
//  Created by Dmitriy Remezov on 13.01.14.
//  Copyright (c) 2014 Dmitriy Remezov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface YDWCoffeAnnot : NSObject <MKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtititle;


- (id) initWithCoordinates:(CLLocationCoordinate2D) paramCoordinates
                     title:(NSString *) paramTitle
                  subTitle:(NSString *) paramSubTitle;

@end
