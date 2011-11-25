//
//  MusicControllerBase.m
//  MusicKeys
//
//  Created by Joshua Halickman on 10/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MusicControllerBase.h"
#import "Chrome.h"
#import "Safari.h"
#import "FireFox.h"

@implementation MusicControllerBase
@synthesize error;

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
    if(![safari isRunning]) {
        return NO;
    }
    
    for(SafariWindow *window in safari.windows) {
        for (SafariTab *tab in window.tabs) {
            //NSLog(@"%@ ::: %@", tab.name, tab.text);
            if([tab.name hasSuffix:[self getTabName]]) {
                [safari doJavaScript:command in:tab];
                return YES;
            }
        }
    }
    return NO;
}

-(BOOL) executeInChrome:(NSString *) command {
    ChromeApplication *chrome = [SBApplication applicationWithBundleIdentifier:@"com.google.Chrome"];
    
    if(![chrome isRunning]) {
        return NO;
    }
    
    for(ChromeWindow *window in chrome.windows) {
        for (ChromeTab *tab in window.tabs) {
            if([tab.title hasSuffix:[self getTabName]]) {
                [tab executeJavascript:[NSString stringWithFormat:@"SJBpost('%@');", command]];
                return YES;
            }
        }
    }
    return NO;
}

-(BOOL) showInSafari {
    SafariApplication *safari = [SBApplication applicationWithBundleIdentifier:@"com.apple.safari"];
    if(![safari isRunning]) {
        return NO;
    }
    
    for(SafariWindow *window in safari.windows) {
        for (SafariTab *tab in window.tabs) {
            //NSLog(@"%@ ::: %@", tab.name, tab.text);
            if([tab.name hasSuffix:[self getTabName]]) {
				[safari activate];
				[window setCurrentTab:tab];
                return YES;
            }
        }
    }
    return NO;
}

-(BOOL) showInChrome {
    ChromeApplication *chrome = [SBApplication applicationWithBundleIdentifier:@"com.google.Chrome"];
    
    if(![chrome isRunning]) {
        return NO;
    }
    
    for(ChromeWindow *window in chrome.windows) {
		int i = 1;
        for (ChromeTab *tab in window.tabs) {
            if([tab.title hasSuffix:[self getTabName]]) {
                [chrome activate];
				[window setActiveTabIndex:i];
                return YES;
            }
			i++;
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
            self.error([NSString stringWithFormat:@"%@ was not found to be playing in either Chrome or Safari", [self getTabName]]);
        }
    }
}

-(void) playPause {}

-(void) next {}

-(void) previous {}

-(void) shuffle {}

-(void) show {
	if(![self showInChrome]) {
		if(![self showInSafari]){
			self.error([NSString stringWithFormat:@"%@ was not found to be playing in either Chrome or Safari", [self getTabName]]);
		}
	}
}

-(NSString *)getTabName {
	return nil;
}
	
@end
