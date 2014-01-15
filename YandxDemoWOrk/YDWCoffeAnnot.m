//
//  YDWCoffeAnnot.m
//  YandxDemoWOrk
//
//  Created by Dmitriy Remezov on 13.01.14.
//  Copyright (c) 2014 Dmitriy Remezov. All rights reserved.
//

#import "YDWCoffeAnnot.h"

@implementation YDWCoffeAnnot

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
