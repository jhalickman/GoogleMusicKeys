//
//  GoogleMusicController.h
//  GoogleMusicKeys
//
//  Created by Joshua Halickman on 7/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^GoogleMusicControllerError)(NSString *error);

@interface GoogleMusicController : NSObject
{
    GoogleMusicControllerError			error;
}

@property(nonatomic, copy) GoogleMusicControllerError error;

-(void) playPause;
-(void) next;
-(void) previous;
-(void) shuffle;
-(void) show;
@end
