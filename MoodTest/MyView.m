//
//  MyView.m
//  MoodTest
//
//  Created by Yuichiro Takeuchi on 4/21/13.
//  Copyright (c) 2013 Yuichiro Takeuchi. All rights reserved.
//

#import "MyView.h"
#import "MyUtilities.h"

typedef struct
{
    double rVal;
    GLfloat bVal;
} MyColor;

@implementation MyView
{
    NSMutableDictionary *textAttribute;
    double circleRadius;
    //Color
    MyColor newColor;
    MyColor oldColor;
    //Strings
    NSString *wordCountString;
    NSString *emotionCountString;
    NSString *positiveCountString;
    NSString *negativeCountString;
}

@synthesize wordCount;
@synthesize emotionCount;
@synthesize positiveCount;
@synthesize negativeCount;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        textAttribute = [[NSMutableDictionary alloc] init];
		[textAttribute setObject:[NSFont fontWithName:@"Helvetica" size:14] forKey:NSFontAttributeName];
		[textAttribute setObject:[NSColor colorWithCalibratedWhite:1.0 alpha:1.0] forKey:NSForegroundColorAttributeName];        
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    //Fill with old color
    [[NSColor colorWithCalibratedRed:oldColor.rVal green:0.0 blue:oldColor.bVal alpha:1.0] set];
    [NSBezierPath fillRect:dirtyRect];
    //Draw circle with new color
    double cp = 225.0 - circleRadius;
    double dm = 2.0 * circleRadius;
    NSBezierPath *circlePath = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(cp, cp, dm, dm)];
    [[NSColor colorWithCalibratedRed:newColor.rVal green:0.0 blue:newColor.bVal alpha:1.0] set];
    [circlePath fill];
    [circlePath setLineWidth:2.0];
    [[NSColor colorWithCalibratedRed:(0.5 + (0.5 * newColor.rVal)) green:0.5 blue:(0.5 + (0.5 * newColor.bVal)) alpha:1.0] set];
    [circlePath stroke];
    //Draw strings
    [wordCountString drawAtPoint:NSMakePoint(10.0, 425.0) withAttributes:textAttribute];
    [emotionCountString drawAtPoint:NSMakePoint(10.0, 409.0) withAttributes:textAttribute];
    [positiveCountString drawAtPoint:NSMakePoint(10.0, 393.0) withAttributes:textAttribute];
    [negativeCountString drawAtPoint:NSMakePoint(10.0, 377.0) withAttributes:textAttribute];
}

- (void)updateGraphics
{
    circleRadius = 0.0;
    oldColor = newColor;
    //Convert to color
    double emotionRatio = (double)emotionCount / (double)wordCount;
    double positiveRatio = (double)positiveCount / (double)wordCount;
    double negativeRatio = (double)negativeCount / (double)wordCount;
    double luminance = emotionRatio * 10.0;
    if(luminance > 1.0){
        luminance = 1.0;
    }
    double rVal = luminance * positiveRatio * 15.0;
    if(rVal > 1.0){
        rVal = 1.0;
    }
    double bVal = luminance * negativeRatio * 15.0;
    if(bVal > 1.0){
        bVal = 1.0;
    }
    newColor.rVal = rVal;
    newColor.bVal = bVal;
    //Update strings
    wordCountString = [NSString stringWithFormat:@"Total words: %d", wordCount];
    double emotionPercent = round((double)emotionCount / (double)wordCount * 10000.0) / 100.0;
    double positivePercent = round((double)positiveCount / (double)wordCount * 10000.0) / 100.0;
    double negativePercent = round((double)negativeCount / (double)wordCount * 10000.0) / 100.0;
    emotionCountString = [NSString stringWithFormat:@"%% emotion: %.2f", emotionPercent];
    positiveCountString = [NSString stringWithFormat:@"%% positive: %.2f", positivePercent];
    negativeCountString = [NSString stringWithFormat:@"%% negative: %.2f", negativePercent];    
    [self setNeedsDisplay:YES];
    [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(fireTimer:) userInfo:nil repeats:YES];
}

- (void)fireTimer:(NSTimer *)timer
{
    circleRadius += 7.0;
    if(circleRadius > 320.0){
        [timer invalidate];
    }
    [self setNeedsDisplay:YES];
}

@end
