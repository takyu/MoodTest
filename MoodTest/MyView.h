//
//  MyView.h
//  MoodTest
//
//  Created by Yuichiro Takeuchi on 4/21/13.
//  Copyright (c) 2013 Yuichiro Takeuchi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MyView : NSView

@property (assign) int wordCount;
@property (assign) int emotionCount;
@property (assign) int positiveCount;
@property (assign) int negativeCount;

- (void)updateGraphics;

@end
