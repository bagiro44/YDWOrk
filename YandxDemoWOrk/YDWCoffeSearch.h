//
//  YDWCoffeSearch.h
//  YandxDemoWOrk
//
//  Created by Dmitriy Remezov on 12.01.14.
//  Copyright (c) 2014 Dmitriy Remezov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "YDWAnnotation.h"
#import "YDWCoffeAnnot.h"

@interface YDWCoffeSearch : NSObject

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) NSMutableDictionary *caffePlacesDictionary;
@property (nonatomic, strong) NSMutableArray *caffePlaces;


- (id) initWithLocation:(CLLocationCoordinate2D)location;
- (int) searchCaffe;


@end
