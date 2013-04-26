//
//  MyUtilities.h
//  MoodTest
//
//  Created by Yuichiro Takeuchi on 4/21/13.
//  Copyright (c) 2013 Yuichiro Takeuchi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MyUtilities : NSView

+ (NSArray *)componentsOfJSONObjectString:(NSString *)string;
+ (NSArray *)componentsOfJSONArrayString:(NSString *)string;
+ (NSArray *)componentsOfJSONKeyValuePairString:(NSString *)string;
+ (NSString *)stringByDecodingEscapedString:(NSString *)string;
+ (long)secondFromTime:(long *)time;
+ (int)intFromMonthString:(NSString *)string;
+ (BOOL)existsInArray:(NSArray *)array startIndex:(int)si endIndex:(int)ei string:(NSString *)str;
+ (void)getRGB:(double[3])rgbVal fromHSV:(double[3])hsvVal;

@end
