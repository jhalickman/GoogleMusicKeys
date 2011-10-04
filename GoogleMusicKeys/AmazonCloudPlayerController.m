//
//  AmazonCloudPlayerController.m
//  GoogleMusicKeys
//
//  Created by Joshua Halickman on 10/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AmazonCloudPlayerController.h"

#define PLAY_PAUSE_COMMAND @"if (window.amznMusic.widgets.player.getCurrent() == null){ window.amznMusic.widgets.player.playHash(\"play/each\"); }else{ if (window.document.getElementsByClassName(\"paused\").length){ window.amznMusic.widgets.player.resume(); }else{ window.amznMusic.widgets.player.pause(); }}"
#define NEXT_COMMAND @"window.amznMusic.widgets.player.playHash('next', null, null);"
#define PREVIOUS_COMMAND @"window.amznMusic.widgets.player.playHash('previous', null, null);"
#define SHUFFLE_COMMAND @"window.amznMusic.widgets.queueManager.toggleShuffle();"
@implementation AmazonCloudPlayerController

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
	return @"Amazon Cloud Player";
}

@end
