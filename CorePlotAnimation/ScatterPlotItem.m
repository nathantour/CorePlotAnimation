//
//  ScatterPlotItem.m
//  CorePlotAnimation
//
//  Created by fjm on 14-11-3.
//  Copyright (c) 2014年 nathantour. All rights reserved.
//

#import "ScatterPlotItem.h"
#define FONT_SIZE 12.0f
#define DATA_LABEL_FONT_SIZE 8
#define CPDBarWidth 0.25

@interface ScatterPlotItem ()
{
    NSTimer *dataTimer;
    NSUInteger currentIndex;
}

@property (nonatomic, strong) CPTScatterPlot *boundLinePlot;   //进港货量
@property (nonatomic, strong) CPTScatterPlot *boundLinePlot2;  //出港货量
@property (nonatomic) NSUInteger count;
@property (nonatomic, assign) NSInteger yAxisMaxValue;   // y轴的最大值
@property (nonatomic, strong) NSMutableArray *reloadPlotData;
@property (nonatomic, assign) NSUInteger yLabelOffset;  //当前最大值是几位数，用来判断ylabel的off

@end

@implementation ScatterPlotItem

@synthesize plotData;
@synthesize cx;
@synthesize yAxisMaxValue;
@synthesize numberOfFractional;
@synthesize selectedIndex;
@synthesize dataForPlot;
@synthesize hostView;
@synthesize boundLinePlot;
@synthesize boundLinePlot2;
@synthesize reloadPlotData;
@synthesize yLabelOffset;

-(id)init
{
    if ( (self = [super init]) ) {
        selectedIndex = NSNotFound;
        self.section = kDemoPlots;
        currentIndex = 0;
        reloadPlotData = [[NSMutableArray alloc] initWithCapacity:5];
        
    }
    
    return self;
}


#pragma mark -
#pragma mark Plot construction methods

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#else

-(void)setFrameSize:(NSSize)newSize
{
    scatterPlotView.frame = NSMakeRect(0.0,
                                       0.0,
                                       newSize.width,
                                       newSize.height);
    [scatterPlotView needsDisplay];
}
#endif

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
-(void)renderInView:(UIView *)hostingView withTheme:(CPTTheme *)theme animated:(BOOL)animated
#else
-(void)renderInView:(NSView *)hostingView withTheme:(CPTTheme *)theme animated:(BOOL)animated
#endif
{
    [self killGraph];
    
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    CGRect viewRect = [hostingView bounds];
    
    scatterPlotView = [[CPTGraphHostingView alloc] initWithFrame:CGRectMake(0.0,
                                                                            0.0,
                                                                            viewRect.size.width,
                                                                            viewRect.size.height)];
    
#else
    NSRect viewRect = [hostingView bounds];
    
    scatterPlotView = [[CPTGraphHostingView alloc] initWithFrame:NSMakeRect(0.0,
                                                                            0.0,
                                                                            viewRect.size.width,
                                                                            viewRect.size.height)];
    
    [scatterPlotView setAutoresizesSubviews:YES];
    [scatterPlotView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    
#endif
    
    [hostingView addSubview:scatterPlotView];
    
    
    [self renderScatterPlotInLayer:scatterPlotView withTheme:theme];
}

-(void)killGraph
{
    scatterPlotView.hostedGraph = nil;
    [scatterPlotView removeFromSuperview];
    scatterPlotView = nil;
    
    [super killGraph];
}

-(void)renderScatterPlotInLayer:(CPTGraphHostingView *)layerHostingView withTheme:(CPTTheme *)theme
{
    // Create graph from theme
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
    CGRect bounds = scatterPlotView.bounds;
#else
    CGRect bounds = NSRectToCGRect(scatterPlotView.bounds);
#endif
    hostView = layerHostingView;
    scatterPlot = [[CPTXYGraph alloc] initWithFrame:bounds];
    [self addGraph:scatterPlot toHostingView:layerHostingView];
    
    scatterPlot.plotAreaFrame.plotArea.delegate = self;
    scatterPlot.plotAreaFrame.paddingLeft   += 0;
    scatterPlot.plotAreaFrame.paddingTop    += 5;
    scatterPlot.plotAreaFrame.paddingRight  += 0;
    scatterPlot.plotAreaFrame.paddingBottom += 5;
    scatterPlot.plotAreaFrame.masksToBorder   = NO;
    
    // Create grid line styles
    CPTMutableLineStyle *majorGridLineStyle = [CPTMutableLineStyle lineStyle];
    majorGridLineStyle.lineWidth = 0.5;
    majorGridLineStyle.lineColor = [[CPTColor lightGrayColor] colorWithAlphaComponent:0.25];
    
    CPTMutableLineStyle *minorGridLineStyle = [CPTMutableLineStyle lineStyle];
    minorGridLineStyle.lineWidth = 0.5;
    minorGridLineStyle.lineColor = [[CPTColor lightGrayColor] colorWithAlphaComponent:0.25];
    

    self.yAxisMaxValue = 200;
    self.yLabelOffset = -20;
    NSInteger increment = yAxisMaxValue/10; //y轴每一个刻度的数值
    CGFloat yLabelTickOffset;  //y轴label的偏移值
    float xMax = self.plotData.count;        //获取x轴的最大值
    
    //设置单位label
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    textStyle.color                = [CPTColor grayColor];
    textStyle.fontName             = @"Helvetica-Bold";
    textStyle.fontSize             = FONT_SIZE+1;
    scatterPlot.titleTextStyle           = textStyle;
    scatterPlot.titlePlotAreaFrameAnchor = CPTRectAnchorTopRight;
    
    // x轴的箭头设置为None不显示
    CPTXYAxisSet *xyAxisSet = (CPTXYAxisSet *)scatterPlot.axisSet;
    CPTXYAxis *xAxis        = xyAxisSet.xAxis;
    CPTLineCap *lineCap = [[CPTLineCap alloc] init];
    lineCap.lineStyle    = xAxis.axisLineStyle;
    lineCap.lineCapType  = CPTLineCapTypeNone;
    lineCap.size         = CGSizeMake(12.0, 12.0);
    xAxis.axisLineCapMax = lineCap;
    
    CPTLineStyle * lineStyle=[[ CPTLineStyle alloc ] init ];
    
    //设置x、y轴的取值范围
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)scatterPlot.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(-1.5) length:CPTDecimalFromDouble(plotData.count+1.5)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromInteger(0) length:CPTDecimalFromInteger(yAxisMaxValue+increment)];
    
    //设置x轴
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)scatterPlot.axisSet;
    CPTXYAxis *x          = axisSet.xAxis;
    x.majorGridLineStyle          = majorGridLineStyle;//这里设置x轴中主刻度的栅格，平行于y轴
    x.minorGridLineStyle = minorGridLineStyle;
    x.labelingPolicy = CPTAxisLabelingPolicyNone;
    // 直角坐标： 0
    x. orthogonalCoordinateDecimal = CPTDecimalFromString ( @"0" );
    x.labelOffset = 0;
    // 标题位置： 7.5 单位
    // 向下偏移： 55.0
    x. axisLineStyle = nil;
    
    
    CPTMutableTextStyle *xTitleTextStyle = [CPTMutableTextStyle textStyle];
    xTitleTextStyle.color                = [CPTColor lightGrayColor];
    xTitleTextStyle.fontSize             = FONT_SIZE;
    xTitleTextStyle.fontName =     @"HelveticaNeue-Thin";
    x.titleTextStyle = xTitleTextStyle;
    x.labelTextStyle = xTitleTextStyle;
    x.titleLocation =  CPTDecimalFromFloat (xMax-2);
    
    NSMutableSet *xLabels = [NSMutableSet set];
    for (int i = 0; i < self.plotData.count; i ++) {
        CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:@"xTitle" textStyle:x.labelTextStyle];
        NSDecimal location = CPTDecimalFromFloat(i);
        label.tickLocation = location;
        label.offset = x.majorTickLength + x.labelOffset;
        if (label) {
            [xLabels addObject:label];
        }
        
    }
    x.axisLabels = xLabels;
    
    //y 轴
    CPTXYAxis *y = axisSet.yAxis ;
    //y 轴：线型设置
    y. axisLineStyle = nil;
    //y 轴：线型设置
    y. majorTickLineStyle = lineStyle;
    //y 轴：不显示小刻度线
    y. minorTickLineStyle = lineStyle ;
    y. majorTickLength = 0 ;
    // 小刻度线：长度
    y. minorTickLength = 0 ;
    // 大刻度线间距： 50 单位
    NSUInteger interval = yAxisMaxValue/10;
    y. majorIntervalLength = CPTDecimalFromString ( [NSString stringWithFormat:@"%ld", (long)interval] );
    // 坐标原点： 0
    y.majorGridLineStyle          = majorGridLineStyle;//这里设置x轴中主刻度的栅格，平行于y轴
    y.minorGridLineStyle = minorGridLineStyle;
    y. orthogonalCoordinateDecimal = CPTDecimalFromString ( @"-1.5" );
    // 轴标题
    //清除默认的轴标签,使用自定义的轴标签
    y.labelingPolicy = CPTAxisLabelingPolicyNone;
    y.titleLocation = CPTDecimalFromInteger(yAxisMaxValue/2);
    CPTMutableTextStyle *yTitleTextStyle = [CPTMutableTextStyle textStyle];
    yTitleTextStyle.color                = [CPTColor lightGrayColor];
    yTitleTextStyle.fontSize             = FONT_SIZE;
    yTitleTextStyle.fontName =     @"HelveticaNeue-Thin";
    yTitleTextStyle.textAlignment = NSTextAlignmentNatural;
    y.titleTextStyle = yTitleTextStyle;
    y.labelTextStyle = yTitleTextStyle;
    y.labelOffset = yLabelOffset;
    
    NSMutableSet *yLabels = [NSMutableSet set];
    NSMutableSet *yMajorLocations = [NSMutableSet set];
    for (NSInteger j = 0; j <= yAxisMaxValue+increment; j += increment) {
        CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%li", (long)j] textStyle:y.labelTextStyle];
        NSDecimal location = CPTDecimalFromInteger(j);
        label.tickLocation = CPTDecimalFromInteger(j+yLabelTickOffset);
//        label.offset = -y.majorTickLength - y.labelOffset ;
        if (label) {
            [yLabels addObject:label];
        }
        [yMajorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:location]];
        
    }
    y.axisLabels = yLabels;
    y.majorTickLocations = yMajorLocations;   //背景的黑色横线参照
    
    // 进货量折线图
    boundLinePlot = [[CPTScatterPlot alloc] init];
    boundLinePlot.identifier = CPDTickerSymbolEntering;
    boundLinePlot.dataSource    = self;
    CPTMutableLineStyle *lineStyle2 = [boundLinePlot.dataLineStyle mutableCopy];
    lineStyle2.miterLimit        = 1.0;
    lineStyle2.lineWidth         = 2;
    lineStyle2.lineColor         = [CPTColor colorWithComponentRed:246/255.0 green:188/255.0 blue:151/255.0 alpha:1];
    [scatterPlot addPlot:boundLinePlot];
    boundLinePlot.areaBaseValue = [[NSDecimalNumber zero] decimalValue];
    boundLinePlot.delegate      = self;
    
    
    //进货量折线图点得风格
    CPTMutableLineStyle *symbolLineStyle = [CPTMutableLineStyle lineStyle];
    symbolLineStyle.lineColor = [CPTColor clearColor];
    CPTPlotSymbol *plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    plotSymbol.lineStyle     = symbolLineStyle;
    plotSymbol.size          = CGSizeMake(35.0, 35.0);
    boundLinePlot.plotSymbol = plotSymbol;
    
    //出货量折线图
    boundLinePlot2 = [[CPTScatterPlot alloc] init];
    boundLinePlot2.identifier = CPDTickerSymbolLeaving;
    boundLinePlot2.dataSource    = self;
    
    //出货量折线图上点得风格
    CPTMutableLineStyle *symbolLineStyle2 = [CPTMutableLineStyle lineStyle];
    symbolLineStyle2.lineColor = [CPTColor clearColor];
    CPTPlotSymbol *plotSymbol2 = [CPTPlotSymbol ellipsePlotSymbol];
    plotSymbol2.lineStyle     = symbolLineStyle2;
    plotSymbol2.size          = CGSizeMake(35.0, 35.0);
    boundLinePlot2.plotSymbol = plotSymbol2;
    [scatterPlot addPlot:boundLinePlot2];
    boundLinePlot2.areaBaseValue = [[NSDecimalNumber zero] decimalValue];
    boundLinePlot2.delegate      = self;
    boundLinePlot2.plotSymbol = plotSymbol2;
    
    //添加图例
    CPTLegend *theLegend = [CPTLegend legendWithGraph:scatterPlot];
    theLegend.swatchSize      = CGSizeMake(18.0, 18.0);
    CPTMutableTextStyle *whiteTextStyle = [CPTMutableTextStyle textStyle];
    whiteTextStyle.color    = [CPTColor blackColor];
    whiteTextStyle.fontSize = FONT_SIZE+1;
    theLegend.textStyle     = whiteTextStyle;
    theLegend.rowMargin     = 10.0;
    theLegend.numberOfRows  = 1;
    theLegend.paddingTop    = 0;
    scatterPlot.legend             = theLegend;
    scatterPlot.legendAnchor       = CPTRectAnchorTopLeft;
    [self updateData];  //设置折线图出现的动画
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{

}

#pragma mark -
#pragma mark CPTScatterPlot delegate

-(void)scatterPlot:(CPTScatterPlot *)plot plotSymbolWasSelectedAtRecordIndex:(NSUInteger)index
{

}


#pragma mark -
#pragma mark Plot Data Source

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return _count+1;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    
    if ( fieldEnum == CPTScatterPlotFieldY ) {
        float priceValue = 0.0f;
        priceValue = [[self.plotData objectAtIndex:index] intValue];
        return [NSNumber numberWithInteger:priceValue];
        
    }else if (fieldEnum == CPTScatterPlotFieldX ){
        
        return [NSNumber numberWithInteger:index];
        
    }
    
    return [NSDecimalNumber numberWithUnsignedInteger:index];
}

- (void)updateData
{
    _count = 0;
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(animateGraph:) userInfo:nil repeats:YES];
}

- (void)animateGraph:(NSTimer *)timer
{
    if (_count < self.plotData.count) {
        [boundLinePlot reloadDataInIndexRange:NSMakeRange(_count, 1)];
        [boundLinePlot2 reloadDataInIndexRange:NSMakeRange(_count, 1)];
    } else {
        [timer invalidate];
    }
    _count += 1;
}

@end
