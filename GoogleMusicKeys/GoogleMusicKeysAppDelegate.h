//
//  GoogleMusicKeysAppDelegate.h
//  GoogleMusicKeys
//
//  Created by Joshua Halickman on 7/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GoogleMusicController.h"
#import "MAAttachedWindow.h"

@interface GoogleMusicKeysAppDelegate : NSObject <NSApplicationDelegate> {
    NSStatusItem *statusItem;
	IBOutlet NSMenu *statusMenu;
	IBOutlet NSMenuItem *mi_showGrooveshark;
	IBOutlet NSMenuItem *mi_startAtLogin;
	IBOutlet NSMenuItem *mi_mediaKeys;
	IBOutlet NSMenuItem *mi_globalKeys;
	IBOutlet NSWindow *mi_firstLaunch;
	IBOutlet NSWindow *mi_preferenceWindow;
	BOOL hotKeyRegistered;
	BOOL mediaKeyRegistered;
	BOOL loadAtLogin;
	BOOL firstLaunch;
	NSString *bundlePath;
	CFMachPortRef eventTap;
    
    GoogleMusicController *controller;
    
    MAAttachedWindow *attachedWindow;
    IBOutlet NSView *view;
    IBOutlet NSTextField *textField;
}

- (IBAction)showGoogleMusic:(id)sender;
- (IBAction)openPreferencesWindow:(id)sender;
- (IBAction)startAtLogin:(id)sender;
- (IBAction)mediaKeys:(id)sender;
- (IBAction)globalKeys:(id)sender;
- (IBAction)showAbout:(id)sender;
- (void)registerHotKeys:(BOOL)registerKeys;
- (CGEventRef) processEvent:(CGEventRef)event withType:(CGEventType)type;
- (void) showMesage:(NSString *) message;
@end
