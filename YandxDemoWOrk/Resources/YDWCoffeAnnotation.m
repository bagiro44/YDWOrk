//
//  YDWCoffeAnnotation.m
//  YandxDemoWOrk
//
//  Created by Dmitriy Remezov on 12.01.14.
//  Copyright (c) 2014 Dmitriy Remezov. All rights reserved.
//

#import "YDWCoffeAnnotation.h"

@implementation YDWCoffeAnnotation

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self != nil)
    {
        CGRect frame = self.frame;
        frame.size = CGSizeMake(30.0, 35.0);
        self.frame = frame;
        self.backgroundColor = [UIColor clearColor];
        self.centerOffset = CGPointMake(-5, -5);
    }
    return self;
}

-(void) drawRect:(CGRect)rect
{
    [[UIImage imageNamed:@"Beverage-Coffee-02.png"] drawInRect:CGRectMake(0, 0.0, 30.0, 30.0)];
}

@end
