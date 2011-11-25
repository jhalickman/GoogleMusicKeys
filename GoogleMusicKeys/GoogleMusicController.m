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

#define PLAY_PAUSE_COMMAND @"SJBpost('playPause');"
#define NEXT_COMMAND @"SJBpost('nextSong');"
#define PREVIOUS_COMMAND @"SJBpost('prevSong');"
#define SHUFFLE_COMMAND @"SJBpost('toggleShuffle');"


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
	return @"Music Beta";
}

    

@end
