//
//  PlotViewController.m
//  CorePlotAnimation
//
//  Created by fjm on 14-11-3.
//  Copyright (c) 2014年 nathantour. All rights reserved.
//

#import "PlotViewController.h"

@interface PlotViewController ()

@property (nonatomic, strong) UIView *hostView;


@end

@implementation PlotViewController

@synthesize detailItem;
@synthesize hostView;


- (void)viewDidLoad {
    [super viewDidLoad];
    hostView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-64)];
    hostView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:hostView];
    
    NSArray *dataSource = [NSArray arrayWithObjects:@"100", @"159", @"200", @"180", @"50", nil];
    detailItem.plotData = dataSource;
    [detailItem renderInView:hostView withTheme:nil animated:YES];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
