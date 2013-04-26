//
//  AppDelegate.m
//  MoodTest
//
//  Created by Yuichiro Takeuchi on 4/21/13.
//  Copyright (c) 2013 Yuichiro Takeuchi. All rights reserved.
//

#import "AppDelegate.h"
#import "OAuthConsumer.h"
#import "MyView.h"
#import "MyUtilities.h"

//The following strings need to be obtained via dev.twitter.com
static const NSString *kConsumerKey = @"";
static const NSString *kConsumerSecret = @"";
static const NSString *kAccessToken = @"";
static const NSString *kAccessTokenSecret = @"";

@interface AppDelegate (Private)

- (void)sendQuery;
- (void)analyzeTweets:(NSString *)string;

@end

@implementation AppDelegate
{
    NSTimer *queryTimer;
    BOOL isRunning;
    BOOL queryInProgress; //Indicates if Twitter search is in progress
    int queryNumTweets;
    int queryInterval;
    NSMutableArray *positiveArray;
    NSMutableArray *negativeArray;
    NSCharacterSet *customCharacterSet;
    NSMutableArray *pronounsArray;
}

@synthesize view;
@synthesize numTweetsSlider;
@synthesize intervalSlider;
@synthesize numTweetsField;
@synthesize intervalField;
@synthesize startStopButton;
@synthesize textView;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    queryNumTweets = 30;
    queryInterval = 10;
    //Read words
    positiveArray = [[NSMutableArray alloc] init];
    negativeArray = [[NSMutableArray alloc] init];
    NSString *wordsFilePath = [[NSBundle mainBundle] pathForResource:@"liwc2007" ofType:@"txt"];
    if([[NSFileManager defaultManager] fileExistsAtPath:wordsFilePath] == YES){
        NSError *error;
        NSString *fileString = [NSString stringWithContentsOfFile:wordsFilePath encoding:NSUTF8StringEncoding error:&error];
        int percentCount = 0;
        int l = 0;
        for(int i = 0; i < [fileString length]; i++){
            unichar c = [fileString characterAtIndex:i];
            if(c == '\n'){
                if(i > l){
                    NSString *line = [fileString substringWithRange:NSMakeRange(l, (i - l))];
                    if(percentCount == 2){
                        NSArray *tokens = [line componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                        if([tokens count] > 1){
                            NSString *word = [tokens objectAtIndex:0];                        
                            for(int j = 1; j < [tokens count]; j++){
                                NSString *category = [tokens objectAtIndex:j];
                                if([category isEqualToString:@"126"] == YES){
                                    [positiveArray addObject:word];
                                }
                                else if([category isEqualToString:@"127"] == YES){
                                    [negativeArray addObject:word];
                                }
                            }
                        }
                    }
                    else{
                        if([line isEqualToString:@"%"] == YES){
                            percentCount++;
                        }
                    }
                }
                l = i + 1;
            }
        }
    }
    else{
        NSLog(@"Error: liwc2007.txt not found");
    }
    customCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyz'"] invertedSet];
    pronounsArray = [[NSMutableArray alloc] init];
    [pronounsArray addObject:@"i"];
    [pronounsArray addObject:@"you"];
    [pronounsArray addObject:@"he"];
    [pronounsArray addObject:@"she"];
    [pronounsArray addObject:@"we"];
    [pronounsArray addObject:@"they"];
}

- (void)searchTweetsTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data
{
    NSLog(@"Received data");
    //Convert string
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString *decodedDataString = [MyUtilities stringByDecodingEscapedString:dataString];
    [self analyzeTweets:decodedDataString];
    queryInProgress = NO;
}

- (void)searchTweetsTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error
{
    NSLog(@"Search failed: %@", [error localizedDescription]);
    queryInProgress = NO;
}

- (IBAction)startStopQueries:(id)sender
{
    [queryTimer invalidate];
    if(isRunning == NO){
        [self sendQuery];
        queryTimer = [NSTimer scheduledTimerWithTimeInterval:(double)queryInterval target:self selector:@selector(fireQueryTimer:) userInfo:nil repeats:YES];
        [numTweetsSlider setEnabled:NO];
        [intervalSlider setEnabled:NO];
        [startStopButton setTitle:@"Stop"];
        isRunning = YES;
    }
    else{
        [numTweetsSlider setEnabled:YES];
        [intervalSlider setEnabled:YES];
        [startStopButton setTitle:@"Start"];
        isRunning = NO;
    }
}

- (void)fireQueryTimer:(NSTimer *)timer
{
    [self sendQuery];
}

- (IBAction)changeNumTweets:(id)sender
{
    queryNumTweets = [sender intValue];
    [numTweetsField setIntValue:queryNumTweets];
}

- (IBAction)changeInterval:(id)sender
{
    queryInterval = [sender intValue];
    [intervalField setIntValue:queryInterval];
}

@end

@implementation AppDelegate (Private)

- (void)sendQuery
{
    NSLog(@"sendQuery");
    while(true){
        if(queryInProgress == NO){
            queryInProgress = YES;
            //Twitter search URL
            NSURL *twitterURL = [NSURL URLWithString:@"https://api.twitter.com/1.1/search/tweets.json"];
            //Set OAuth ID
            OAConsumer *oAuthConsumer = [[OAConsumer alloc] initWithKey:(NSString *)kConsumerKey secret:(NSString *)kConsumerSecret];
            OAToken *oAuthToken = [[OAToken alloc] initWithKey:(NSString *)kAccessToken secret:(NSString *)kAccessTokenSecret];
            OAMutableURLRequest *oAuthRequest = [[OAMutableURLRequest alloc] initWithURL:twitterURL consumer:oAuthConsumer token:oAuthToken realm:nil signatureProvider:nil];
            [oAuthRequest setHTTPMethod:@"GET"];
            //Set query
            OARequestParameter *oAuthGeocodeParam = [[OARequestParameter alloc] initWithName:@"geocode" value:[NSString stringWithFormat:@"%f,%f,%dmi", 44.9800, -93.2636, 15]];
            OARequestParameter *oAuthLangParam = [[OARequestParameter alloc] initWithName:@"lang" value:@"en"];
            OARequestParameter *oAuthCountParam = [[OARequestParameter alloc] initWithName:@"count" value:[NSString stringWithFormat:@"%d", queryNumTweets]];
            [oAuthRequest setParameters:[NSArray arrayWithObjects:oAuthGeocodeParam, oAuthLangParam, oAuthCountParam, nil]];
            //Fetch data
            OADataFetcher *oAuthFetcher = [[OADataFetcher alloc] init];
            [oAuthFetcher fetchDataWithRequest:oAuthRequest delegate:self didFinishSelector:@selector(searchTweetsTicket:didFinishWithData:) didFailSelector:@selector(searchTweetsTicket:didFailWithError:)];
            break;
        }
        else{
            NSLog(@"Restart timer");
            [queryTimer invalidate];
            queryTimer = [NSTimer scheduledTimerWithTimeInterval:(double)queryInterval target:self selector:@selector(fireQueryTimer:) userInfo:nil repeats:YES];
        }
    }
}

- (void)analyzeTweets:(NSString *)string
{
    NSLog(@"analyzeTweets");
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];

    //Parse string
    NSArray *chunkArray = [MyUtilities componentsOfJSONObjectString:string]; //Divide string into "statuses" and "search_metadata"
    if([chunkArray count] != 2){
        NSLog(@"Error: chunkArray %ld", [chunkArray count]);
        return;
    }
    NSString *firstChunkString = [chunkArray objectAtIndex:0];
    NSArray *statusesKeyValuePairArray = [MyUtilities componentsOfJSONKeyValuePairString:firstChunkString];
    if([statusesKeyValuePairArray count] != 2){
        NSLog(@"Error: statusesKeyValuePairArray %ld", [statusesKeyValuePairArray count]);
        return;
    }
    NSString *statusesValueString = [statusesKeyValuePairArray objectAtIndex:1]; //String of all tweets, concatenated
    NSArray *tweetsArray = [MyUtilities componentsOfJSONArrayString:statusesValueString]; //Array of all tweets
    for(int i = 0; i < [tweetsArray count]; i++){
        NSString *tweetNameString;
        NSString *tweetScreenNameString;
        NSString *tweetProfileString;
        NSString *tweetTimeString;
        NSString *tweetTextString;
        int parseSuccess = 0;
        NSString *tweetString = [tweetsArray objectAtIndex:i]; //A string containing data for a single tweet
        NSArray *paramsArray = [MyUtilities componentsOfJSONObjectString:tweetString];
        for(int j = 0; j < [paramsArray count]; j++){
            NSString *paramString = [paramsArray objectAtIndex:j]; //Parameter key-value combination
            NSArray *paramKeyValuePairArray = [MyUtilities componentsOfJSONKeyValuePairString:paramString];
            if([paramKeyValuePairArray count] != 2){
                NSLog(@"Error: paramKeyValuePairArray %ld", [paramKeyValuePairArray count]);
            }
            else{
                NSString *paramKey = [paramKeyValuePairArray objectAtIndex:0];
                if([paramKey isEqualToString:@"\"user\""] == YES){
                    NSString *userParamListString = [paramKeyValuePairArray objectAtIndex:1];
                    NSArray *userParamArray = [MyUtilities componentsOfJSONObjectString:userParamListString];
                    for(int k = 0; k < [userParamArray count]; k++){
                        NSString *userParamString = [userParamArray objectAtIndex:k];
                        NSArray *userParamKeyValuePairArray = [MyUtilities componentsOfJSONKeyValuePairString:userParamString];
                        if([userParamKeyValuePairArray count] != 2){
                            NSLog(@"Error: userParamKeyValuePairArray %ld", [userParamKeyValuePairArray count]);
                        }
                        else{
                            NSString *userParamKey = [userParamKeyValuePairArray objectAtIndex:0];
                            if([userParamKey isEqualToString:@"\"name\""] == YES){
                                tweetNameString = [userParamKeyValuePairArray objectAtIndex:1];
                                parseSuccess++;
                            }
                            else if([userParamKey isEqualToString:@"\"screen_name\""] == YES){
                                tweetScreenNameString = [userParamKeyValuePairArray objectAtIndex:1];
                                parseSuccess++;
                            }
                            else if([userParamKey isEqualToString:@"\"description\""] == YES){
                                tweetProfileString = [userParamKeyValuePairArray objectAtIndex:1];
                                parseSuccess++;
                            }
                        }
                    }
                }
                else if([paramKey isEqualToString:@"\"created_at\""] == YES){
                    NSString *dateString = [paramKeyValuePairArray objectAtIndex:1];
                    NSArray *dateTokens = [dateString componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    if([dateTokens count] != 6){
                        NSLog(@"Error: dateTokens %ld", [dateTokens count]);
                    }
                    else{
                        long tweetTime[6];
                        tweetTime[0] = [MyUtilities intFromMonthString:[dateTokens objectAtIndex:1]];
                        tweetTime[1] = [[dateTokens objectAtIndex:2] intValue];
                        tweetTime[2] = [[dateTokens objectAtIndex:5] intValue];
                        NSString *timeString = [dateTokens objectAtIndex:3];
                        NSArray *timeTokens = [timeString componentsSeparatedByString:@":"];
                        if([timeTokens count] != 3){
                            NSLog(@"Error: timeTokens %ld", [timeTokens count]);
                        }
                        else{
                            tweetTime[3] = [[timeTokens objectAtIndex:0] intValue];
                            tweetTime[4] = [[timeTokens objectAtIndex:1] intValue];
                            tweetTime[5] = [[timeTokens objectAtIndex:2] intValue];
                            tweetTimeString = [NSString stringWithFormat:@"\"%ld/%ld/%ld %ld:%ld:%ld GMT\"", tweetTime[0], tweetTime[1], tweetTime[2], tweetTime[3], tweetTime[4], tweetTime[5]];
                            parseSuccess++;
                        }
                    }
                }
                else if([paramKey isEqualToString:@"\"text\""] == YES){
                    tweetTextString = [paramKeyValuePairArray objectAtIndex:1];
                    parseSuccess++;
                }
                else if([paramKey isEqualToString:@"\"coordinates\""] == YES){
                    if([[paramKeyValuePairArray objectAtIndex:1] isEqualToString:@"null"] == NO){
                    }
                }
            }
        }
        if(parseSuccess == 5){
            [dataArray addObject:[NSArray arrayWithObjects:tweetNameString, tweetScreenNameString, tweetProfileString, tweetTimeString, tweetTextString, nil]];
        }
    }

    //Update textView & analyze tweets
    int wordCount = 0;
    int emotionCount = 0;
    int positiveCount = 0;
    int negativeCount = 0;
    NSMutableString *textString = [[NSMutableString alloc] init];
    for(int i = 0; i < [dataArray count]; i++){
        NSArray *dataPack = [dataArray objectAtIndex:i];
        [textString appendFormat:@"%d / %d\n", i + 1, (int)[dataArray count]];
        [textString appendFormat:@"Name: %@\n", [dataPack objectAtIndex:0]];
        [textString appendFormat:@"Screen Name: %@\n", [dataPack objectAtIndex:1]];
        [textString appendFormat:@"Profile: %@\n", [dataPack objectAtIndex:2]];
        [textString appendFormat:@"Time: %@\n", [dataPack objectAtIndex:3]];
        [textString appendFormat:@"Tweet: %@\n", [dataPack objectAtIndex:4]];
        //Analyze tweet
        NSMutableString *positiveString = [[NSMutableString alloc] init];
        NSMutableString *negativeString = [[NSMutableString alloc] init];
        NSString *escapedTweetString = [[dataPack objectAtIndex:4] stringByReplacingOccurrencesOfString:@"\\n" withString:@" "];        
        NSArray *wordChunks = [escapedTweetString componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSMutableArray *refinedWordsArray = [[NSMutableArray alloc] init];
        for(NSString *word in wordChunks){
            NSString *refinedWord = [[word lowercaseString] stringByTrimmingCharactersInSet:customCharacterSet];
            if([refinedWord length] > 0){
                [refinedWordsArray addObject:refinedWord];
            }
        }
        for(int j = 0; j < [refinedWordsArray count]; j++){
            NSString *word = [refinedWordsArray objectAtIndex:j];
            //We provide custom routines for "like" and "kind"
            if([word isEqualToString:@"like"] == YES){
                if(j > 0){
                    NSString *prevWord = [refinedWordsArray objectAtIndex:(j - 1)];
                    for(NSString *pronoun in pronounsArray){
                        if([prevWord isEqualToString:pronoun] == YES){
                            positiveCount++;
                            emotionCount++;
                            [positiveString appendFormat:@"%@ ", word];
                            break;
                        }
                    }
                }
            }
            else if([word isEqualToString:@"kind"] == YES){
                if(j < ((int)[refinedWordsArray count] - 1)){
                    NSString *nextWord = [refinedWordsArray objectAtIndex:(j + 1)];
                    if([nextWord isEqualToString:@"of"] == NO){
                        positiveCount++;
                        emotionCount++;
                        [positiveString appendFormat:@"%@ ", word];
                    }
                }
            }
            else{
                BOOL isPositive = [MyUtilities existsInArray:positiveArray startIndex:0 endIndex:((int)[positiveArray count] - 1) string:word];
                BOOL isNegative = [MyUtilities existsInArray:negativeArray startIndex:0 endIndex:((int)[negativeArray count] - 1) string:word];
                if(isPositive == YES){
                    positiveCount++;
                    emotionCount++;
                    [positiveString appendFormat:@"%@ ", word];
                }
                if(isNegative == YES){
                    negativeCount++;                    
                    emotionCount++;
                    [negativeString appendFormat:@"%@ ", word];
                }
            }
            wordCount++;
        }
        [textString appendFormat:@"Positive: %@\n", positiveString];
        [textString appendFormat:@"Negative: %@\n\n", negativeString];
    }
    [textView setString:textString];

    //Update view
    view.wordCount = wordCount;
    view.emotionCount = emotionCount;
    view.positiveCount = positiveCount;
    view.negativeCount = negativeCount;
    [view updateGraphics];
}

@end
