//
//  GoogleMusicController.m
//  MusicKeys
//
//  Created by Joshua Halickman on 7/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GoogleMusicController.h"
#import "Chrome.h"
#import "Safari.h"
#import "FireFox.h"

#define PLAY_PAUSE_COMMAND @"document.querySelectorAll('[data-id=\"play-pause\"]')[0].click();"
#define NEXT_COMMAND @"document.querySelectorAll('[data-id=\"forward\"]')[0].click();"
#define PREVIOUS_COMMAND @"document.querySelectorAll('[data-id=\"rewind\"]')[0].click();"
#define SHUFFLE_COMMAND @"document.querySelectorAll('[data-id=\"shuffle\"]')[0].click();"

@implementation GoogleMusicController


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

-(NSString *)getTabName {
	return @"Google Play Music";
}

    

@end
