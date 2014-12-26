//
//  STSegmentedControl.h
//
//  Created by Sinclair Target on 12/26/14.
//

#import <UIKit/UIKit.h>
#import "STSegmentedControlDelegate.h"

/**
 *  A custom implementation of a UISegmentedControl-like control which supports
 *  multiple selection.
 */
@interface STSegmentedControl : UIView

/**
 *  The delegate that receives events from this control.
 */
@property (weak, nonatomic) id <STSegmentedControlDelegate> delegate;

/**
 *  Number of segments in the control.
 */
@property (nonatomic) NSUInteger numberOfSegments;

/**
 *  The radius of the entire control's corners.
 */
@property (nonatomic) CGFloat cornerRadius;

/**
 *  Segment content in a selected segment will be set to this color.
 *
 *  The default is white.
 */
@property (strong, nonatomic) UIColor* highlightColor;

// =======================================================================
//                  @name Setting Segment Content
// =======================================================================
/**
 *  Sets a text title for a given segment.
 *  @param title   The title to display in the segment.
 *  @param segment The index of the segment.
 */
- (void)setTitle:(NSString*)title forSegmentAtIndex:(NSUInteger)segment;

/**
 *  Sets an image for a given segment.
 *  @param image   The image to display in the segment.
 *  @param segment The index of the segment.
 */
- (void)setImage:(UIImage*)image forSegmentAtIndex:(NSUInteger)segment;

// =======================================================================
//                  @name Getting Selection State
// =======================================================================
/**
 *  Returns the selection state of a segment.
 *  @param segment The index of the segment.
 *  @return True if the segment is selected, false otherwise.
 */
- (BOOL)isSelectedForSegmentAtIndex:(NSUInteger)segment;

@end
