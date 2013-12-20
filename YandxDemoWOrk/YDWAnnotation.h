//
//  YDWAnnotation.h
//  YandxDemoWOrk
//
//  Created by Dmitriy Remezov on 20.12.13.
//  Copyright (c) 2013 Dmitriy Remezov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface YDWAnnotation : NSObject <MKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, copy, readonly) NSString *subtititle;

- (id) initWithCoordinates:(CLLocationCoordinate2D) paramCoordinates
                     title:(NSString *) paramTitle
                  subTitle:(NSString *) paramSubTitle;

@end
