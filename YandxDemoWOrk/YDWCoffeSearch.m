//
//  YDWCoffeSearch.m
//  YandxDemoWOrk
//
//  Created by Dmitriy Remezov on 12.01.14.
//  Copyright (c) 2014 Dmitriy Remezov. All rights reserved.
//

#import "YDWCoffeSearch.h"

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
        self.coordinate = location;
    }
    return self;
}

- (void) searchCaffe
{
    //запрос на получение наименования местности
    NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%f,%f&radius=1000&types=cafe&sensor=false&key=AIzaSyBvPFoi7u9PRayKCp646i8zonRGipBsyQ0", self.coordinate.latitude, self.coordinate.longitude];
    NSLog(@"%@", urlString);
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    urlString = NULL;
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30.f];
    url = Nil;
    NSURLResponse *response;
    NSError *error;
    NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
    
    
    NSMutableDictionary  * json = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error: &error];
    

}

@end
