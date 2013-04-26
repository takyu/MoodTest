//
//  AppDelegate.h
//  MoodTest
//
//  Created by Yuichiro Takeuchi on 4/21/13.
//  Copyright (c) 2013 Yuichiro Takeuchi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MyView;

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic) IBOutlet MyView *view;
@property (nonatomic) IBOutlet NSSlider *numTweetsSlider;
@property (nonatomic) IBOutlet NSSlider *intervalSlider;
@property (nonatomic) IBOutlet NSTextField *numTweetsField;
@property (nonatomic) IBOutlet NSTextField *intervalField;
@property (nonatomic) IBOutlet NSButton *startStopButton;
@property (nonatomic) IBOutlet NSTextView *textView;

- (IBAction)startStopQueries:(id)sender;
- (IBAction)changeNumTweets:(id)sender;
- (IBAction)changeInterval:(id)sender;

@end
