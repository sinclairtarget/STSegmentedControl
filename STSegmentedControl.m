//
//  STSegmentedControl.m
//
//  Created by Sinclair Target on 12/26/14.
//

#import "SPC_SegmentedControl.h"
#import <math.h>

static const CGFloat defaultCornerRadius = 5;
static const CGFloat labelInset = 2.5;
static const CGFloat imageInset = 5;

@interface SPC_SegmentedControl ()

// The subviews in each segment, either a UILabel or a UIImageView.
// holds NSDictionaries with "view" and "selected" keys representing
// (view, selected) tuples
// NOTE: the @"view" key will return NSNull if the view does not exist
@property (strong, nonatomic) NSMutableArray* segmentContentViews;

@end

@implementation SPC_SegmentedControl

// =======================================================================
#pragma mark - Property Accessors
// =======================================================================
@synthesize numberOfSegments = _numberOfSegments;

- (void)setNumberOfSegments:(NSUInteger)numberOfSegments
{
    _numberOfSegments = numberOfSegments;
    [self clearSegmentContentViews];
    [self setNeedsDisplay];
}

- (NSUInteger)numberOfSegments
{
    if (_numberOfSegments == 0)
        _numberOfSegments = 2;
    return _numberOfSegments;
}

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    self.layer.cornerRadius = cornerRadius;
}

- (CGFloat)cornerRadius
{
    return self.layer.cornerRadius;
}

- (NSMutableArray*)segmentContentViews
{
    if (!_segmentContentViews)
        _segmentContentViews = [[NSMutableArray alloc] init];
    return _segmentContentViews;
}

- (UIColor*)highlightColor
{
    if (!_highlightColor)
        _highlightColor = [UIColor whiteColor];
    return _highlightColor;
}

// =======================================================================
#pragma mark - Initialization
// =======================================================================
// OVERRIDE
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        [self commonInit];
    }
    
    return self;
}

// OVERRIDE
-(void)awakeFromNib
{
    [super awakeFromNib];
    
    [self commonInit];
}

// Initializes the view whether it was created in IB or programmatically
- (void)commonInit
{
    self.cornerRadius = defaultCornerRadius;
    self.layer.borderWidth = 1.0;
    self.clipsToBounds = YES;
    
    [self clearSegmentContentViews];
    
    // add UIGestureRecognizer to listen for taps
    UITapGestureRecognizer* tapRecognizer =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(handleTap:)];
    tapRecognizer.numberOfTapsRequired = 1;
    [self addGestureRecognizer:tapRecognizer];
}

// =======================================================================
#pragma mark - Drawing
// =======================================================================
- (void)drawRect:(CGRect)rect
{
    self.layer.borderColor = self.tintColor.CGColor;
    
    [self drawSegments];
    [self drawDividers];
}

- (void)drawSegments
{
    // Push the context so we don't change it
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    for (int i = 0; i < self.numberOfSegments; i++)
    {
        NSDictionary* dict = self.segmentContentViews[i];
        UIView* segmentContentView = dict[@"view"];
        
        if ([dict[@"selected"] boolValue])
        {
            // fill the background
            CGRect segmentFrame = [self contentFrameForSegment:i
                                                     withInset:0];
            UIBezierPath* path =
                [UIBezierPath bezierPathWithRect:segmentFrame];
            [self.tintColor setFill];
            [path fill];
            
            // set tint color to highlight color
            if (![segmentContentView isEqual:[NSNull null]])
            {
                [self contentView:segmentContentView
                     setTintColor:self.highlightColor];
            }
        }
        else
        {
            // set tint color to current tint color
            [self contentView:segmentContentView
                 setTintColor:self.tintColor];
        }
    }
    
    // Pop the context
    CGContextRestoreGState(context);
}

- (void)drawDividers
{
    // Push the context so we don't change it
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    float width = self.bounds.size.width;
    float height = self.bounds.size.height;
    float segmentWidth = width / self.numberOfSegments;
    
    UIBezierPath* path = [[UIBezierPath alloc] init];
    for (int i = 0; i < self.numberOfSegments - 1; i++)
    {
        CGPoint dividerStart = CGPointMake((i + 1) * segmentWidth, 0);
        CGPoint dividerEnd = CGPointMake(dividerStart.x, height);
        [path moveToPoint:dividerStart];
        [path addLineToPoint:dividerEnd];
    }
    
    [self.tintColor setStroke]; // use tint color
    [path stroke];
    
    // Pop the context
    CGContextRestoreGState(context);
}

// =======================================================================
#pragma mark - Layout
// =======================================================================
// OVERRIDE
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    for (int i = 0; i < self.numberOfSegments; i++)
    {
        UIView* view = self.segmentContentViews[i][@"view"];
        if ([view isKindOfClass:[UILabel class]])
            view.frame = [self contentFrameForSegment:i
                                            withInset:labelInset];
        else
            view.frame = [self contentFrameForSegment:i
                                            withInset:imageInset];
    }
}

// =======================================================================
#pragma mark - Segment Content
// =======================================================================
- (void)setTitle:(NSString*)title forSegmentAtIndex:(NSUInteger)segment
{
    if (segment > self.numberOfSegments)
        @throw [NSException exceptionWithName:@"Segment Out of Bounds"
                                       reason:@"No segment at that index"
                                     userInfo:nil];
    
    UILabel* label =
        [[UILabel alloc]
            initWithFrame:[self contentFrameForSegment:segment
                                             withInset:labelInset]];
    label.text = title;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = self.tintColor;
    
    [self setSubview:label forSegmentAtIndex:segment];
}

- (void)setImage:(UIImage*)image forSegmentAtIndex:(NSUInteger)segment
{
    if (segment > self.numberOfSegments)
        @throw [NSException exceptionWithName:@"Segment Out of Bounds"
                                       reason:@"No segment at that index"
                                     userInfo:nil];
    
    UIImageView* imageView =
        [[UIImageView alloc]
             initWithFrame:[self contentFrameForSegment:segment
                                              withInset:imageInset]];
    
    // a template image ignores colors and just uses alpha values
    UIImage* templateImage =
        [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    imageView.image = templateImage;
    imageView.tintColor = self.tintColor;
    
    [self setSubview:imageView forSegmentAtIndex:segment];
}

- (BOOL)isSelectedForSegmentAtIndex:(NSUInteger)segment
{
    return [self.segmentContentViews[segment][@"selected"] boolValue];
}

// private
- (void)setSubview:(UIView*)view forSegmentAtIndex:(NSUInteger)segment
{
    UIView* segmentView = self.segmentContentViews[segment][@"view"];
    if (![segmentView isEqual:[NSNull null]])
        [segmentView removeFromSuperview];
    
    self.segmentContentViews[segment][@"view"] = view;
    [self addSubview:view];
}

// =======================================================================
#pragma mark - Handling Taps
// =======================================================================
// select the segment the tap occurred in
- (void)handleTap:(UITapGestureRecognizer*)tapRecognizer
{
    CGPoint tapPoint = [tapRecognizer locationInView:self];
    float segmentWidth = self.bounds.size.width / self.numberOfSegments;
    uint segment = floorf(tapPoint.x / segmentWidth);
    
    NSMutableDictionary* dict = self.segmentContentViews[segment];
    
    if (![dict[@"selected"] boolValue])
        dict[@"selected"] = @YES;
    else
        dict[@"selected"] = @NO;
    
    [self setNeedsDisplay];
    
    [self.delegate selectionChangedInSegmentedControl:self];
}

// =======================================================================
#pragma mark - Private Helper Methods
// =======================================================================
// removes all subviews and resets self.segmentContentViews
- (void)clearSegmentContentViews
{
    for (UIView* subview in self.subviews)
        [subview removeFromSuperview];
    
    [self.segmentContentViews removeAllObjects];
    
    for (int i = 0; i < self.numberOfSegments; i++)
    {
        NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
        dict[@"selected"] = @NO;
        dict[@"view"] = [NSNull null];
        [self.segmentContentViews addObject:dict];
    }
}
         
// returns the frame for a given segment content view
- (CGRect)contentFrameForSegment:(NSUInteger)segment
                      withInset:(CGFloat)inset
{
    float segmentWidth = self.bounds.size.width / self.numberOfSegments;
    float segmentHeight = self.bounds.size.height;
    float segmentX = segment * segmentWidth;
    return CGRectMake(segmentX + inset,
                      inset,
                      segmentWidth - (2 * inset),
                      segmentHeight - (2 * inset));
}

// set text color on a UILabel, but tint color on a UIImageView
- (void)contentView:(UIView*)view setTintColor:(UIColor*)tintColor
{
    if ([view respondsToSelector:@selector(setTextColor:)])
        ((UILabel*)view).textColor = tintColor;
    else
        view.tintColor = tintColor;
}

@end
