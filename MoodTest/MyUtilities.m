//
//  MyUtilities.m
//  MoodTest
//
//  Created by Yuichiro Takeuchi on 4/21/13.
//  Copyright (c) 2013 Yuichiro Takeuchi. All rights reserved.
//

#import "MyUtilities.h"

@implementation MyUtilities

+ (NSArray *)componentsOfJSONObjectString:(NSString *)string
{
    NSMutableArray *parsedArray = [[NSMutableArray alloc] init];
    if([string length] > 0){
        int i = 0;
        while(true){
            unichar c = [string characterAtIndex:i];
            //Find first unescaped opening bracket
            int b = 0;
            for(int j = (i - 1); j >= 0; j--){
                if([string characterAtIndex:j] == '\\'){
                    b = (b + 1) % 2;
                }
                else{
                    break;
                }
            }
            if((c == '{') && (b == 0)){
                BOOL closed = NO;
                int bracketCount = 1;
                int quoteCount = 0;
                int l = i + 1;
                for(int j = (i + 1); j < [string length]; j++){
                    unichar e = [string characterAtIndex:j];
                    //Look for escape character
                    int d = 0;
                    for(int k = (j - 1); k >= 0; k--){
                        if([string characterAtIndex:k] == '\\'){
                            d = (d + 1) % 2;
                        }
                        else{
                            break;
                        }
                    }
                    if(((e == '{') || (e == '[')) && (d == 0) && (quoteCount == 0)){ //Opening bracket, unescaped, outside of quotations
                        bracketCount++;
                    }
                    else if(((e == '}') || (e == ']')) && (d == 0) && (quoteCount == 0)){ //Closing bracket, unescaped, outside of quotations
                        bracketCount--;
                    }
                    else if((e == '"') && (d == 0)){ //Quotation mark, unescaped
                        quoteCount = (quoteCount + 1) % 2;
                    }
                    else if((bracketCount == 1) && (e == ',') && (d == 0) && (quoteCount == 0)){ //Comma within bracket, unescaped, outside of quotations
                        unichar f = [string characterAtIndex:(j + 1)];
                        if((f == '"') || (f == '{') || (f == '[')){
                            if(j > l){
                                NSString *item = [string substringWithRange:NSMakeRange(l, (j - l))];
                                if([item length] > 0){
                                    [parsedArray addObject:item];
                                }
                            }
                            l = j + 1;
                        }
                    }
                    if(bracketCount == 0){ //The initial opening bracket has been closed, add last item
                        if(j > l){
                            NSString *item = [string substringWithRange:NSMakeRange(l, (j - l))];
                            if([item length] > 0){
                                [parsedArray addObject:item];
                            }
                        }
                        closed = YES;
                        break;
                    }
                }
                if(closed == NO){ //The initial opening bracket is not closed, broken string
                    [parsedArray removeAllObjects];
                }
                break;
            }
            i++;
            if(i >= [string length]){
                break;
            }
        }
    }
    return parsedArray;
}

+ (NSArray *)componentsOfJSONArrayString:(NSString *)string
{
    NSMutableArray *parsedArray = [[NSMutableArray alloc] init];
    if([string length] > 0){
        int i = 0;
        while(true){
            //Find first unescaped opening bracket
            unichar c = [string characterAtIndex:i];
            int b = 0;
            for(int j = (i - 1); j >= 0; j--){
                if([string characterAtIndex:j] == '\\'){
                    b = (b + 1) % 2;
                }
                else{
                    break;
                }
            }
            if((c == '[') && (b == 0)){
                BOOL closed = NO;
                int bracketCount = 1;
                int quoteCount = 0;
                int l = i + 1;
                for(int j = (i + 1); j < [string length]; j++){
                    unichar e = [string characterAtIndex:j];
                    //Look for escape character
                    int d = 0;
                    for(int k = (j - 1); k >= 0; k--){
                        if([string characterAtIndex:k] == '\\'){
                            d = (d + 1) % 2;
                        }
                        else{
                            break;
                        }
                    }
                    if(((e == '{') || (e == '[')) && (d == 0) && (quoteCount == 0)){ //Opening bracket, unescaped, outside of quotations
                        bracketCount++;
                    }
                    else if(((e == '}') || (e == ']')) && (d == 0) && (quoteCount == 0)){ //Closing bracket, unescaped, outside of quotations
                        bracketCount--;
                    }
                    else if((e == '"') && (d == 0)){ //Quotation mark, unescaped
                        quoteCount = (quoteCount + 1) % 2;
                    }
                    else if((bracketCount == 1) && (e == ',') && (d == 0)){ //Comma within bracket, unescaped, outside of quotations
                        unichar f = [string characterAtIndex:(j + 1)];                            
                        if((f == '"') || (f == '{') || (f == '[')){
                            if(j > l){
                                NSString *item = [string substringWithRange:NSMakeRange(l, (j - l))];
                                if([item length] > 0){
                                    [parsedArray addObject:item];
                                }
                            }
                            l = j + 1;
                        }
                    }
                    if(bracketCount == 0){ //The initial opening bracket has been closed, add last item
                        if(j > l){
                            NSString *item = [string substringWithRange:NSMakeRange(l, (j - l))];
                            if([item length] > 0){
                                [parsedArray addObject:item];
                            }
                        }
                        closed = YES;
                        break;
                    }
                }
                if(closed == NO){ //The initial opening bracket is not closed, broken string
                    [parsedArray removeAllObjects];
                }
                break;
            }
            i++;
            if(i >= [string length]){
                break;
            }
        }
    }
    return parsedArray;
}

+ (NSArray *)componentsOfJSONKeyValuePairString:(NSString *)string
{
    NSMutableArray *parsedArray = [[NSMutableArray alloc] init];
    if([string length] > 2){
        for(int i = 1; i < ([string length] - 1); i++){
            int bracketCount = 0;
            int quoteCount = 0;
            unichar c = [string characterAtIndex:i];
            //Look for escape character
            int b = 0;
            for(int j = (i - 1); j >= 0; j--){
                if([string characterAtIndex:j] == '\\'){
                    b = (b + 1) % 2;
                }
                else{
                    break;
                }
            }
            if(((c == '{') || (c == '[')) && (b == 0) && (quoteCount == 0)){ //Opening bracket, unescaped, outside of quotations
                bracketCount++;
            }
            else if(((c == '}') || (c == ']')) && (b == 0) && (quoteCount == 0)){ //Closing bracket, unescaped, outside of quotations
                bracketCount--;
            }
            else if((c == '"') && (b == 0)){ //Quotation mark, unescaped
                quoteCount = (quoteCount + 1) % 2;
            }
            else if((c == ':') && (b == 0) && (bracketCount == 0) && (quoteCount == 0)){ //Colon, unescaped, outside of brackets/quotations
                NSString *key = [string substringToIndex:i];
                NSString *value = [string substringFromIndex:(i + 1)];
                [parsedArray addObject:key];
                [parsedArray addObject:value];
                break;
            }
        }
    }
    return parsedArray;
}

+ (NSString *)stringByDecodingEscapedString:(NSString *)string
{
    NSMutableString *muString = [NSMutableString stringWithString:string];
    CFMutableStringRef cfString = (__bridge CFMutableStringRef)muString;
    CFStringTransform(cfString, NULL, CFSTR("Hex-Any"), false);
    NSString *decodedString = (__bridge NSString *)cfString;
    return decodedString;
}

+ (long)secondFromTime:(long *)time
{
    long months = ((time[0] - 2000) * 12) + time[1];
    long days = (months * 365) + time[2];
    long hours = (days * 24) + time[3];
    long minutes = (hours * 60) + time[4];
    long seconds = (minutes * 60) + time[5];
    return seconds;
}

+ (int)intFromMonthString:(NSString *)string
{
    if([string isEqualToString:@"Jan"] == YES){ return 1; }
    else if([string isEqualToString:@"Feb"] == YES){ return 2; }
    else if([string isEqualToString:@"Mar"] == YES){ return 3; }
    else if([string isEqualToString:@"Apr"] == YES){ return 4; }
    else if([string isEqualToString:@"May"] == YES){ return 5; }
    else if([string isEqualToString:@"Jun"] == YES){ return 6; }
    else if([string isEqualToString:@"Jul"] == YES){ return 7; }
    else if([string isEqualToString:@"Aug"] == YES){ return 8; }
    else if([string isEqualToString:@"Sep"] == YES){ return 9; }
    else if([string isEqualToString:@"Oct"] == YES){ return 10; }
    else if([string isEqualToString:@"Nov"] == YES){ return 11; }
    else if([string isEqualToString:@"Dec"] == YES){ return 12; }
    return 0;
}

+ (BOOL)existsInArray:(NSArray *)array startIndex:(int)si endIndex:(int)ei string:(NSString *)str
{
    //Get midpoint index
    int mi = si + ((ei - si) / 2);
    NSString *midStr = [array objectAtIndex:mi];
    //If we have found the string, return
    BOOL foundString = NO;
    if([midStr characterAtIndex:([midStr length] - 1)] == '*'){
        NSString *midStrPrefix = [midStr substringToIndex:([midStr length] - 1)];
        if([str hasPrefix:midStrPrefix] == YES){
            foundString = YES;
        }
    }
    else{
        if([str isEqualToString:midStr] == YES){
            foundString = YES;
        }
    }
    if(foundString == YES){
        return YES;
    }
    else{
        int result = 0;
        int index = 0;
        while(true){
            unichar c1 = [str characterAtIndex:index];
            unichar c2 = [midStr characterAtIndex:index];
            if(c1 > c2){ //c1 comes after c2
                result = 2;
                break;
            }
            else if(c1 < c2){ //c1 comes before c2
                result = 1;
                break;
            }
            else{
                index++;
                if((index >= [str length]) && (index >= [midStr length])){
                    return NO;
                }
                else if(index >= [str length]){ //c1 comes before c2
                    result = 1;
                    break;
                }
                else if(index >= [midStr length]){ //c1 comes after c2
                    result = 2;
                    break;
                }
            }
        }
        if(result == 1){ //Search in first half
            if((mi - 1) < si){
                return NO;
            }
            return [MyUtilities existsInArray:array startIndex:si endIndex:(mi - 1) string:str];
        }
        else if(result == 2){ //Search in second half
            if((mi + 1) > ei){
                return NO;
            }
            return [MyUtilities existsInArray:array startIndex:(mi + 1) endIndex:ei string:str];
        }
    }
    return NO;
}

+ (void)getRGB:(double[3])rgbVal fromHSV:(double[3])hsvVal
{
    double c = hsvVal[1] * hsvVal[2];
    double h = (int)round(hsvVal[0] * 360.0);
    double h2 = h / 60.0;
    double h3 = h2;
    while(h3 >= 2.0){
        h3 -= 2.0;
    }
    double h4 = h3 - 1.0;
    if(h4 < 0.0){
        h4 = -h4;
    }
    double x = c * (1.0 - h4);
    if(h2 < 1.0){
        rgbVal[0] = c;
        rgbVal[1] = x;
        rgbVal[2] = 0.0;
    }
    else if(h2 < 2.0){
        rgbVal[0] = x;
        rgbVal[1] = c;
        rgbVal[2] = 0.0;
    }
    else if(h2 < 3.0){
        rgbVal[0] = 0.0;
        rgbVal[1] = c;
        rgbVal[2] = x;
    }
    else if(h2 < 4.0){
        rgbVal[0] = 0.0;
        rgbVal[1] = x;
        rgbVal[2] = c;
    }
    else if(h2 < 5.0){
        rgbVal[0] = x;
        rgbVal[1] = 0.0;
        rgbVal[2] = c;
    }
    else{
        rgbVal[0] = c;
        rgbVal[1] = 0.0;
        rgbVal[2] = x;
    }
    double m = hsvVal[2] - c;
    rgbVal[0] += m;
    rgbVal[1] += m;
    rgbVal[2] += m;
}

@end
