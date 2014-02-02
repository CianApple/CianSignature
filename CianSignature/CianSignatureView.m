//
//  CianSignatureView.m
//  CianSignature
//
//  Created by Jai Dhorajia on 27/11/13.
//  Copyright (c) 2013 Softweb. All rights reserved.
//

/*
 Signature View - Developed by Cian
 
 - Ready to use UIView for generating stylish signatures. Recently I found out that many apps needed an implementation of signatures. Till now we were using a primitive way to drawing signatures which not only looked ugly but also was not fast and memory consuming. So I started working on it and during my research I found out many different ways of achieving it. Mainly being Cocos2D, GLKit and Coregraphics. All are capable to implement this feature. 
 
 - But carefully analyzing our needs and to implement this feature in the easiest and best possible way. I found out that Coregraphics is the way to go. So I started researching and as we have worked on 'Racana', it didnt take much time to figure out a way to implement it. I sorted out the best possible memory efficient way which is very easy to implement in our projects.
 
 - Some of the better implementations are:
    * Using Gestures instead of UITouches.
    * Understanding a line smoothening alogrithm (Catmull-Spline algorithm) developed in language C.
    * This implementation was still laggy, so used drawingQueue and dispatch_async for curbing the lag.
    * Switch case provides some extra speed while jumping conditions
    * Catmull Rom Spline algorithm implemented for line smoothening
    * Ramer–Douglas–Peucker algorithm could also be used.
    * Adding buffer to improve the drawing experience.
    * Memory check when in ARC doesnt give a crash and is released properly.
    * Drawing a dot in coregraphics is easy but doesnt go with the flow. Tried to implement it properly but has no effect to match it with the line style.

 - There is still a large scope of improvement in this code. Practically we are using paid source codes like TenOne Autograph library for achieving this feature. It costs $99 for a single license and $499 for multiple licenses.
     So why to spend so much money if we can develop it ourselves.
 
 - Still things that are needed to be fixed:
    * Sometimes due to the velocity of finger touch, the line thickness becomes uneven.
    * For still better drawing performance, we can first draw the line real-time and then apply smoothening algorithm.
      This will significantly improve the performance but wouldn't give the feel of nice signature.
    * Implementing CALayer can boost the performance and memory.
    * Code for clearing the image is done but just need to add a code for capturing the signature as a UIImage (not that hard).
    * Make the class readily available for drag and drop use.
    * If you don't like ARC, just declare few variables globally and release them in dealloc.
    * You will notice that one end of the line is not pointed while the other end is. Code could be enhanced to do this which will make the signature look nice. I left it because it seemed to me like unnecessary calculations.
    * Implementing a dot/point is not impressive in our code. We can research a bit more on it and come out with a nice effect of it.
    
 Note: Have referred many sources on the internet so would not be able to list them out. But mainly try to search these keywords:
    * Catmull Rom Spline Algorithm
    * How to draw smooth lines in iOS
    * Azam Khan             (Best tutorial on this matter)
    * Ray Wanderlich        (Few tricks here)
    * Draw a point using uibezierpath
    * Make drawing in coregraphics faster
*/

#import "CianSignatureView.h"

///////////////////////////////////////////
// Defines and Struct
///////////////////////////////////////////
#define CAPACITY 50
#define FF 0.05
#define LOWER 0.01
#define UPPER 1.0
#define LINECOLOR [UIColor blueColor]
typedef struct
{
    CGPoint firstPoint;
    CGPoint secondPoint;
} LineSegment;

///////////////////////////////////////////
// Variable Declarations
///////////////////////////////////////////
@implementation CianSignatureView
{
    UIImage *incrementalImage;
    CGPoint pts[5];
    uint ctr;
    CGPoint pointsBuffer[CAPACITY];
    uint bufIdx;
    dispatch_queue_t drawingQueue;
    BOOL isFirstTouchPoint;
    LineSegment lastSegmentOfPrev;
}

///////////////////////////////////////////
// View Delegate Methods
///////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        drawingQueue = dispatch_queue_create("drawingQueue", NULL);
        
        // Capture touches
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(eraseDrawing:)];
        longPress.minimumPressDuration = 1;
        longPress.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:longPress];
        
        UITapGestureRecognizer *tapOnce = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(drawDot:)];
        tapOnce.numberOfTapsRequired = 1; // Tap once to draw dot!
        [self addGestureRecognizer:tapOnce];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        pan.maximumNumberOfTouches = 1;
        pan.minimumNumberOfTouches = 1;
        pan.delaysTouchesBegan =YES;
        pan.cancelsTouchesInView = YES;
        [self addGestureRecognizer:pan];
    }
    return self;
}
- (void)drawRect:(CGRect)rect
{
    [incrementalImage drawInRect:rect];
}

///////////////////////////////////////////
// Gesture Delegate Methods
///////////////////////////////////////////
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

///////////////////////////////////////////
// Gesture Call Methods
///////////////////////////////////////////
- (void)eraseDrawing:(UITapGestureRecognizer *)t
{
    incrementalImage = nil;
    [self setNeedsDisplay];
}
- (void)drawDot:(UITapGestureRecognizer *)tap
{
    CGPoint currentPoint = [tap locationInView:self];
    dispatch_async(drawingQueue, ^{
        UIBezierPath *offsetPath = [UIBezierPath bezierPath];
        
        [offsetPath moveToPoint:currentPoint];
        [offsetPath addArcWithCenter:currentPoint radius:2.0f startAngle:0 endAngle:M_PI*2 clockwise:YES];
        
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 0.0);
        
        if (!incrementalImage)
        {
            UIBezierPath *rectpath = [UIBezierPath bezierPathWithRect:self.bounds];
            [[UIColor whiteColor] setFill];
            [rectpath fill];
        }
        [incrementalImage drawAtPoint:CGPointZero];
        [LINECOLOR setStroke];
        [LINECOLOR setFill];
        [offsetPath stroke];
        [offsetPath fill];
        incrementalImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [offsetPath removeAllPoints];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setNeedsDisplay];
        });
    });
}
- (void)pan:(UIPanGestureRecognizer *)pan
{
    CGPoint currentPoint = [pan locationInView:self];
    
    switch (pan.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            ctr = 0;
            bufIdx = 0;
            pts[0] = currentPoint;
            isFirstTouchPoint = YES;
        }
            break;
            
        case UIGestureRecognizerStateChanged:
        {
            CGPoint p = currentPoint;
            ctr++;
            pts[ctr] = p;
            if (ctr == 4)
            {
                pts[3] = CGPointMake((pts[2].x + pts[4].x)/2.0, (pts[2].y + pts[4].y)/2.0);
                
                for ( int i = 0; i < 4; i++)
                    pointsBuffer[bufIdx + i] = pts[i];
                
                bufIdx += 4;
                CGRect bounds = self.bounds;
                
                dispatch_async(drawingQueue, ^{
                    UIBezierPath *offsetPath = [UIBezierPath bezierPath];
                    if (bufIdx == 0) return;
                    
                    LineSegment ls[4];
                    for ( int i = 0; i < bufIdx; i += 4)
                    {
                        if (isFirstTouchPoint)
                        {
                            ls[0] = (LineSegment){pointsBuffer[0], pointsBuffer[0]};
                            [offsetPath moveToPoint:ls[0].firstPoint];
                            isFirstTouchPoint = NO;
                        }
                        else
                            ls[0] = lastSegmentOfPrev;
                        
                        float frac1 = FF/clamp(len_sq(pointsBuffer[i], pointsBuffer[i+1]), LOWER, UPPER); 
                        float frac2 = FF/clamp(len_sq(pointsBuffer[i+1], pointsBuffer[i+2]), LOWER, UPPER);
                        float frac3 = FF/clamp(len_sq(pointsBuffer[i+2], pointsBuffer[i+3]), LOWER, UPPER);
                        ls[1] = [self lineSegmentPerpendicularTo:(LineSegment){pointsBuffer[i], pointsBuffer[i+1]} ofRelativeLength:frac1];
                        ls[2] = [self lineSegmentPerpendicularTo:(LineSegment){pointsBuffer[i+1], pointsBuffer[i+2]} ofRelativeLength:frac2];
                        ls[3] = [self lineSegmentPerpendicularTo:(LineSegment){pointsBuffer[i+2], pointsBuffer[i+3]} ofRelativeLength:frac3];
                        
                        [offsetPath moveToPoint:ls[0].firstPoint]; 
                        [offsetPath addCurveToPoint:ls[3].firstPoint controlPoint1:ls[1].firstPoint controlPoint2:ls[2].firstPoint];
                        [offsetPath addLineToPoint:ls[3].secondPoint];
                        [offsetPath addCurveToPoint:ls[0].secondPoint controlPoint1:ls[2].secondPoint controlPoint2:ls[1].secondPoint];
                        [offsetPath closePath];
                        
                        lastSegmentOfPrev = ls[3];
                        // Note: Apply smoothing on the shared line segment of the two adjacent offsetPaths
                        
                    }
                    UIGraphicsBeginImageContextWithOptions(bounds.size, YES, 0.0);
                    
                    if (!incrementalImage)
                    {
                        UIBezierPath *rectpath = [UIBezierPath bezierPathWithRect:self.bounds];
                        [[UIColor whiteColor] setFill];
                        [rectpath fill];
                    }
                    
                    [incrementalImage drawAtPoint:CGPointZero];
                    [LINECOLOR setStroke];
                    [LINECOLOR setFill];
                    [offsetPath stroke];
                    [offsetPath fill];
                    
                    incrementalImage = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    [offsetPath removeAllPoints];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        bufIdx = 0;
                        [self setNeedsDisplay];
                    });
                });
                pts[0] = pts[3];
                pts[1] = pts[4];
                ctr = 1;
            }
        }
            break;
            
        case UIGestureRecognizerStateEnded:
            break;
            
        default:
            break;
    }
}

///////////////////////////////////////////
// Algorithm Helper Methods
///////////////////////////////////////////
-(LineSegment) lineSegmentPerpendicularTo: (LineSegment)pp ofRelativeLength:(float)fraction
{
    CGFloat x0 = pp.firstPoint.x, y0 = pp.firstPoint.y, x1 = pp.secondPoint.x, y1 = pp.secondPoint.y;
    
    CGFloat dx, dy;
    dx = x1 - x0;
    dy = y1 - y0;
    
    CGFloat xa, ya, xb, yb;
    xa = x1 + fraction/2 * dy;
    ya = y1 - fraction/2 * dx;
    xb = x1 - fraction/2 * dy;
    yb = y1 + fraction/2 * dx;
    
    return (LineSegment){ (CGPoint){xa, ya}, (CGPoint){xb, yb} };
}
float len_sq(CGPoint p1, CGPoint p2)
{
    float dx = p2.x - p1.x;
    float dy = p2.y - p1.y;
    return dx * dx + dy * dy;
}
float clamp(float value, float lower, float higher)
{
    if (value < lower) return lower;
    if (value > higher) return higher;
    return value;
}
@end
