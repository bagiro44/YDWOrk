//
//  YDWAppDelegate.h
//  YandxDemoWOrk
//
//  Created by Dmitriy Remezov on 20.12.13.
//  Copyright (c) 2013 Dmitriy Remezov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "DataSource.h"

@interface YDWAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) DataSource *DB;

@end
