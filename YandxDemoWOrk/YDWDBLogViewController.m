//
//  YDWDBLogViewController.m
//  YandxDemoWOrk
//
//  Created by Dmitriy Remezov on 24.12.13.
//  Copyright (c) 2013 Dmitriy Remezov. All rights reserved.
//

#import "YDWDBLogViewController.h"

@interface YDWDBLogViewController ()

@end

@implementation YDWDBLogViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    for (NSString *tempString in self.arrayLog) {
        self.logTextView.text = [NSString stringWithFormat:@"%@ +++ %@", self.logTextView.text, tempString];
    }
    //self.logTextView.text= [self.arrayLog description];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
