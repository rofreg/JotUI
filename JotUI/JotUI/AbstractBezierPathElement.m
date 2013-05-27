//
//  AbstractSegment.m
//  JotUI
//
//  Created by Adam Wulf on 12/19/12.
//  Copyright (c) 2012 Adonit. All rights reserved.
//

#import "AbstractBezierPathElement.h"
#import "AbstractBezierPathElement-Protected.h"

#define kAbstractMethodException [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)] userInfo:nil]

@implementation AbstractBezierPathElement

@synthesize startPoint;
@synthesize width;
@synthesize color;
@synthesize rotation;

-(id) initWithStart:(CGPoint)point{
    if(self = [super init]){
        startPoint = point;
    }
    return self;
}

/**
 * the length of the drawn segment. if it is a
 * curve, then it is the travelled distance along
 * the curve, not the linear distance between start
 * and end points
 */
-(CGFloat) lengthOfElement{
    @throw kAbstractMethodException;
}

-(CGFloat) angleOfStart{
    @throw kAbstractMethodException;
}

-(CGFloat) angleOfEnd{
    @throw kAbstractMethodException;
}


/**
 * return the number of vertices to use per
 * step. this should be a multiple of 3,
 * since rendering is using GL_TRIANGLES
 */
-(NSInteger) numberOfVerticesPerStep{
    return 6;
}

/**
 * the ideal number of steps we should take along
 * this line to render it with vertex points
 */
-(NSInteger) numberOfSteps{
    return MAX(floorf([self lengthOfElement] / kBrushStepSize), 1);
}

/**
 * this will return an array of vertex structs
 * that we can send to OpenGL to draw. Ideally,
 * subclasses will generate this array once to save
 * CPU cycles when drawing.
 *
 * the generated vertex array should be stored in
 * vertexBuffer ivar
 */
-(struct Vertex*) generatedVertexArrayWithPreviousElement:(AbstractBezierPathElement*)previousElement forScale:(CGFloat)scale{
    @throw kAbstractMethodException;
}


-(NSArray*) arrayOfPositionsForPoint:(CGPoint)point
                            andWidth:(CGFloat)stepWidth
                         andRotation:(CGFloat)stepRotation{
    point.x = point.x * scaleOfVertexBuffer;
    point.y = point.y * scaleOfVertexBuffer;
    
    CGRect rect = CGRectMake(point.x - stepWidth/2, point.y - stepWidth/2, stepWidth, stepWidth);
    
    CGPoint topLeft  = rect.origin; topLeft.y += rect.size.width;
    CGPoint topRight = rect.origin; topRight.y += rect.size.width; topRight.x += rect.size.width;
    CGPoint botLeft  = rect.origin;
    CGPoint botRight = rect.origin; botRight.x += rect.size.width;
    
    // TODO: rotation
    // translate + rotate + translate each point to rotate it
    
    CGAffineTransform translateTransform = CGAffineTransformMakeTranslation(point.x, point.y);
    CGAffineTransform rotationTransform = CGAffineTransformMakeRotation(stepRotation);
    CGAffineTransform customRotation = CGAffineTransformConcat(CGAffineTransformConcat( CGAffineTransformInvert(translateTransform), rotationTransform), translateTransform);
    
    topLeft = CGPointApplyAffineTransform(topLeft, customRotation);
    topRight = CGPointApplyAffineTransform(topRight, customRotation);
    botLeft = CGPointApplyAffineTransform(botLeft, customRotation);
    botRight = CGPointApplyAffineTransform(botRight, customRotation);
    
    
    NSMutableArray* outArray = [NSMutableArray array];
    [outArray addObject:[NSValue valueWithCGPoint:topLeft]];
    [outArray addObject:[NSValue valueWithCGPoint:topRight]];
    [outArray addObject:[NSValue valueWithCGPoint:botLeft]];
    [outArray addObject:[NSValue valueWithCGPoint:botRight]];
    [outArray addObject:[NSValue valueWithCGPoint:topRight]];
    [outArray addObject:[NSValue valueWithCGPoint:botLeft]];
    
    return outArray;
}

-(CGFloat) angleBetweenPoint:(CGPoint) point1 andPoint:(CGPoint)point2 {
    // Provides a directional bearing from point2 to the given point.
    // standard cartesian plain coords: Y goes up, X goes right
    // result returns radians, -180 to 180 ish: 0 degrees = up, -90 = left, 90 = right
    return atan2f(point1.y - point2.y, point1.x - point2.x) + M_PI_2;
}


/**
 * make sure to free the generated vertex info
 */
-(void) dealloc{
    if(vertexBuffer){
        free(vertexBuffer);
        vertexBuffer = nil;
    }
}

@end