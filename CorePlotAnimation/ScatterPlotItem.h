//
//  ScatterPlotItem.h
//  CorePlotAnimation
//
//  Created by fjm on 14-11-3.
//  Copyright (c) 2014年 nathantour. All rights reserved.
//

#import "PlotItem.h"
#import "CPDConstants.h"

@interface ScatterPlotItem : PlotItem<CPTPlotSpaceDelegate,
CPTScatterPlotDataSource,
CPTScatterPlotDelegate,
CPTBarPlotDelegate, CPTPlotAreaDelegate>

{
@private
    CPTGraphHostingView *scatterPlotView;
    
    CPTXYGraph *scatterPlot;
    
    NSMutableArray *dataForPlot;
    
    NSInteger selectedIndex;
}

@property (nonatomic) float cx;   //除数
@property (nonatomic, assign) NSUInteger numberOfFractional; //显示的小数位数
@property (nonatomic, strong) NSString *titleString;
@property (nonatomic, strong) NSMutableArray *plotData;
@property (nonatomic) NSInteger searchType;  // 查询的类型， 按日为0 按月为1
@property (readwrite, retain, nonatomic) NSMutableArray *dataForPlot;
@property (nonatomic) NSInteger selectedIndex;
@property (nonatomic, strong) CPTGraphHostingView *hostView;
@property (nonatomic, strong) NSString *selectDateString; //选择的日期的字符串;

//-(void)renderScatterPlotInLayer:(CPTGraphHostingView *)layerHostingView withTheme:(CPTTheme *)theme;

- (void)showDefaultPopString; //渲染完后显示默认的pop 视图


@end
