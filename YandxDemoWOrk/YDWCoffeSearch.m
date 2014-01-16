//
//  YDWCoffeSearch.m
//  YandxDemoWOrk
//
//  Created by Dmitriy Remezov on 12.01.14.
//  Copyright (c) 2014 Dmitriy Remezov. All rights reserved.
//

#import "YDWCoffeSearch.h"
//#import "YDWCoffeAnnot.m"

@implementation YDWCoffeSearch

- (id) init
{
    return [self initWithLocation:CLLocationCoordinate2DMake(0.0, 0.0)];
}

- (id) initWithLocation:(CLLocationCoordinate2D)location
{
    self = [super init];
    if (self != nil)
    {
        self.caffePlaces = [[NSMutableArray alloc] init];
        self.coordinate = location;
    }
    return self;
}

- (void) searchCaffe
{

    __block NSData *googleData = [[NSData alloc] init];
    NSString *urlAsString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%f,%f&radius=1000&types=cafe&opennow=true&sensor=false&key=AIzaSyBvPFoi7u9PRayKCp646i8zonRGipBsyQ0", self.coordinate.latitude, self.coordinate.longitude];
    NSLog(@"%@", urlAsString);
    NSURL *url = [NSURL URLWithString:urlAsString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NULL timeoutInterval:20];
    NSURLResponse *response = nil;
    NSError *error = nil;
    googleData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
    if (googleData != nil)
    {
        self.caffePlacesDictionary = [NSJSONSerialization JSONObjectWithData:googleData options: NSJSONReadingMutableContainers error: &error];
        NSArray * result = self.caffePlacesDictionary[@"results"];
        
        for(NSDictionary * dict in result)
        {
            YDWCoffeAnnot* newCaffe = [[YDWCoffeAnnot alloc] initWithCoordinates:CLLocationCoordinate2DMake([[[[dict valueForKey:@"geometry"] valueForKey:@"location"] valueForKey:@"lat"] doubleValue], [[[[dict valueForKey:@"geometry"] valueForKey:@"location"] valueForKey:@"lng"] doubleValue]) title:[dict valueForKey:@"name"] subTitle:[dict valueForKey:@"vicinity"]];
            [self.caffePlaces addObject:newCaffe];
        }
    }
    
}

@end
