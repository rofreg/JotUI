//
//  JotStroke.h
//  JotTouchExample
//
//  Created by Adam Wulf on 1/9/13.
//  Copyright (c) 2013 Adonit, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "JotStrokeDelegate.h"
#import "JotBrushTexture.h"
#import "PlistSaving.h"

@class SegmentSmoother, AbstractBezierPathElement;

/**
 * a simple class to help us manage a single
 * smooth curved line. each segment will interpolate
 * between points into a nice single curve, and also
 * interpolate width and color including alpha
 */
@interface JotStroke : NSObject<PlistSaving>

@property (nonatomic, readonly) SegmentSmoother* segmentSmoother;
@property (nonatomic, readonly) NSArray* segments;
@property (nonatomic, readonly) JotBrushTexture* texture;
@property (nonatomic, weak) NSObject<JotStrokeDelegate>* delegate;

/**
 * create an empty stroke with the input texture
 */
-(id) initWithTexture:(JotBrushTexture*)_texture;

-(CGRect) bounds;

/**
 * returns YES if the point modified the stroke by adding a new segment,
 * or NO if the segment is unmodified because there are still too few
 * points to interpolate
 *
 * @param point the point to add to the stroke
 * @param width the width of stroke at the input point
 * @param color the color of the stroke at the input point
 * @param smoothFactor the smoothness between the previous point and the input point.
 *        0 is straight, 1 is curvy, > 1 and < 0 is loopy or bouncy
 */
-(BOOL) addPoint:(CGPoint)point withWidth:(CGFloat)width andColor:(UIColor*)color andSmoothness:(CGFloat)smoothFactor;

/**
 * remove a segment from the stroke
 */
-(void) removeElement:(AbstractBezierPathElement*)element;


/**
 * cancel the stroke and notify the delegate
 */
-(void) cancel;

@end
