//
//  GoogleMusicController.m
//  GoogleMusicKeys
//
//  Created by Joshua Halickman on 7/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GoogleMusicController.h"
#import "Chrome.h"
#import "Safari.h"
#import "FireFox.h"

#define PLAY_PAUSE_COMMAND @"playPause"
#define NEXT_COMMAND @"nextSong"
#define PREVIOUS_COMMAND @"prevSong"
#define SHUFFLE_COMMAND @"toggleShuffle"


@implementation GoogleMusicController

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(BOOL) executeInSafari:(NSString *) command {
    SafariApplication *safari = [SBApplication applicationWithBundleIdentifier:@"com.apple.safari"];
    for(SafariWindow *window in safari.windows) {
        for (SafariTab *tab in window.tabs) {
            //NSLog(@"%@ ::: %@", tab.name, tab.text);
            if([tab.name hasSuffix:@"Music Beta"]) {
                [safari doJavaScript:[NSString stringWithFormat:@"SJBpost('%@');", command] in:tab];
                return YES;
            }
        }
    }
    return NO;
}

-(BOOL) executeInChrome:(NSString *) command {
    ChromeApplication *chrome = [SBApplication applicationWithBundleIdentifier:@"com.google.Chrome"];
    
    for(ChromeWindow *window in chrome.windows) {
        for (ChromeTab *tab in window.tabs) {
            if([tab.title hasSuffix:@"Music Beta"]) {
                [tab executeJavascript:[NSString stringWithFormat:@"SJBpost('%@');", command]];
                return YES;
            }
        }
    }
    return NO;
}

/*-(BOOL) executeInFirefox:(NSString *)command {
    FireFoxApplication *firefox = [SBApplication applicationWithBundleIdentifier:@"org.mozilla.firefox"];
    
    for(FireFoxWindow *window in firefox.windows) {
        window.
    }
}*/

-(void) tryChromeThenSafari:(NSString *)command {
    if(![self executeInChrome:command]) {
        if(![self executeInSafari:command]){
            NSLog(@"Music Beta was not found to be playing in either Chrome or Safari");
        }
    }
}

-(void) playPause {
    [self tryChromeThenSafari:PLAY_PAUSE_COMMAND];
}

-(void) next {
    [self tryChromeThenSafari:NEXT_COMMAND];
}

-(void) previous {
    [self tryChromeThenSafari:PREVIOUS_COMMAND];
}

-(void) shuffle {
    [self tryChromeThenSafari:SHUFFLE_COMMAND];
}

    

@end
