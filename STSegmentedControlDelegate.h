//
//  STSegmentedControlDelegate.h
//
//  Created by Sinclair Target on 12/26/14.
//

#import <Foundation/Foundation.h>

@class STSegmentedControl;

/**
 *  STSegmentedControlDelegate defines a protocol for classes wishing to
 *  receive events from an STSegmentedControl.
 */
@protocol STSegmentedControlDelegate <NSObject>

/**
 *  Notifies the delegate that the set of selected segments has changed.
 *  @param control The segmented control.
 */
- (void)selectionChangedInSegmentedControl:(STSegmentedControl*)control;

@end
