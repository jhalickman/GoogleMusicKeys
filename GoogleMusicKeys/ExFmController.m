//
//  ExFmController.m
//  MusicKeys
//
//  Created by Joshua Halickman on 11/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ExFmController.h"


#define PLAY_PAUSE_COMMAND @"AudioPlayer.PlayPause();"
#define NEXT_COMMAND @"AudioPlayer.Next();"
#define PREVIOUS_COMMAND @"AudioPlayer.Previous();"
#define SHUFFLE_COMMAND @""

@implementation ExFmController

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
	return @"exfm";
}
@end
