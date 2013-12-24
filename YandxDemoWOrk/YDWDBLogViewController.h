//
//  YDWDBLogViewController.h
//  YandxDemoWOrk
//
//  Created by Dmitriy Remezov on 24.12.13.
//  Copyright (c) 2013 Dmitriy Remezov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YDWDBLogViewController : UIViewController
- (IBAction)closeView:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *logTextView;
@property (strong, nonatomic) NSMutableArray *arrayLog;
@end
