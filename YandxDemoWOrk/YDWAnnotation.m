//
//  YDWAnnotation.m
//  YandxDemoWOrk
//
//  Created by Dmitriy Remezov on 20.12.13.
//  Copyright (c) 2013 Dmitriy Remezov. All rights reserved.
//

#import "YDWAnnotation.h"

@implementation YDWAnnotation


@synthesize coordinate, title, subtititle;

- (id) init
{
    return [self initWithCoordinates:CLLocationCoordinate2DMake(43.07, -89.32) title:@"Home" subTitle:@""];
}

- (id) initWithCoordinates:(CLLocationCoordinate2D)paramCoordinates title:(NSString *)paramTitle subTitle:(NSString *)paramSubTitle{
    self = [super init];
    if(self != nil){
        coordinate = paramCoordinates;
        title = paramTitle;
        subtititle = paramSubTitle;
    }
    return self;
}

@end
