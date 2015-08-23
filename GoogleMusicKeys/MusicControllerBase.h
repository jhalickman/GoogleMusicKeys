//
//  MusicControllerBase.h
//  MusicKeys
//
//  Created by Joshua Halickman on 10/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef void (^MusicControllerError)(NSString *error);

@interface MusicControllerBase : NSObject {
	MusicControllerError			error;
}
	
@property(nonatomic, copy) MusicControllerError error;

-(void) playPause;
-(void) next;
-(void) previous;
-(void) shuffle;
-(void) show;
-(void) tryChromeThenSafari:(NSString *)command;
-(NSString *)getTabName;
- (void)thumbsUp;
- (void)thumbsDown;
@end
