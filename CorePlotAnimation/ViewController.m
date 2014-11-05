//
//  ViewController.m
//  CorePlotAnimation
//
//  Created by fjm on 14-11-3.
//  Copyright (c) 2014年 nathantour. All rights reserved.
//

#import "ViewController.h"
#import "PlotListTableViewController.h"


@interface ViewController ()
- (IBAction)enterMainViewController:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}



- (IBAction)enterMainViewController:(id)sender {
    
    UINavigationController *navigationCotroller = [[UINavigationController alloc] initWithRootViewController:[[PlotListTableViewController alloc] init]];
    [self presentViewController:navigationCotroller animated:YES completion:nil];
    
}
@end
