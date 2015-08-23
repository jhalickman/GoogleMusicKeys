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
#define THUMBS_UP_COMMAND @"var btn = document.querySelectorAll('[aria-label=\"Thumb-up\"]')[0]; if (btn) btn.click();"
#define THUMBS_DOWN_COMMAND @"var btn = document.querySelectorAll('[aria-label=\"Thumb-down\"]')[0]; if (btn) btn.click();"

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

- (void)thumbsUp {
    [self tryChromeThenSafari:THUMBS_UP_COMMAND];
}

- (void)thumbsDown {
    [self tryChromeThenSafari:THUMBS_DOWN_COMMAND];
}

@end
