//
//  GoogleMusicKeysAppDelegate.m
//  GoogleMusicKeys
//
//  Created by Joshua Halickman on 7/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GoogleMusicKeysAppDelegate.h"
#import <Carbon/Carbon.h>
#import "SRCommon.h"

@implementation GoogleMusicKeysAppDelegate

OSStatus MyHotKeyHandler(EventHandlerCallRef nextHandler, EventRef theEvent, void *userData) {
	EventHotKeyID hkCom;
	GetEventParameter(theEvent, kEventParamDirectObject, typeEventHotKeyID, NULL, sizeof(hkCom), NULL, &hkCom);
    GoogleMusicController *controller = (GoogleMusicController *)userData;
	int eventID = hkCom.id;
	switch (eventID) {
		case 1:
			[controller previous];
			break;
		case 2:
			[controller next];
			break;
		case 3:
			[controller playPause];
			break;
		case 4:
			[controller shuffle];
			break;
        default:
			NSLog(@"%@", @"Key registered, no action defined");
			break;
	}
	return noErr;
}

+ (void)initialize {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *file = [[NSBundle mainBundle] pathForResource:@"Defaults" ofType:@"plist"];
	NSDictionary *appDefaults = [NSDictionary dictionaryWithContentsOfFile:file];
	[defaults registerDefaults:appDefaults];
}

- (BOOL)isSetForLogin:(LSSharedFileListRef)loginItems ForPath:(NSString *)path {
	BOOL exists = NO;
	UInt32 seedValue;
	CFURLRef thePath;
	
	CFArrayRef loginItemsArray = LSSharedFileListCopySnapshot(loginItems, &seedValue);
	for (id item in (NSArray *)loginItemsArray) {
		LSSharedFileListItemRef itemRef = (LSSharedFileListItemRef)item;
		if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef *)&thePath, NULL) == noErr) {
			if ([[(NSURL *)thePath path] hasPrefix:path]) {
				exists = YES;
				break;
			}
		}
	}
    //	CFRelease(thePath);
	CFRelease(loginItemsArray);
	return exists;
}

- (void)enableLoginItem:(LSSharedFileListRef)loginItems ForPath:(NSString *)path {
	CFURLRef url = (CFURLRef)[NSURL fileURLWithPath:path];
	LSSharedFileListItemRef item = LSSharedFileListInsertItemURL(loginItems, kLSSharedFileListItemLast, NULL, NULL, url, NULL, NULL);
	if (item) {
		CFRelease(item);
	}
}

- (void)disableLoginItem:(LSSharedFileListRef)loginItems ForPath:(NSString *)path {
	UInt32 seedValue;
	CFURLRef thePath;
	CFArrayRef loginItemsArray = LSSharedFileListCopySnapshot(loginItems, &seedValue);
	for (id item in (NSArray *)loginItemsArray) {
		LSSharedFileListItemRef itemRef = (LSSharedFileListItemRef)item;
		if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef *)&thePath, NULL) == noErr) {
			if ([[(NSURL *)thePath path] hasPrefix:path]) {
				LSSharedFileListItemRemove(loginItems, itemRef);
			}
			CFRelease(thePath);
		}
	}
	CFRelease(loginItemsArray);
}

- (void)registerHotKeys:(BOOL)registerKeys {
	static EventHotKeyRef eventHotKeyRef[6];
	EventTypeSpec eventType;
	eventType.eventClass=kEventClassKeyboard;
	eventType.eventKind=kEventHotKeyPressed;
	InstallApplicationEventHandler(&MyHotKeyHandler,1,&eventType,controller,NULL);
	if (registerKeys == YES) {
		if (hotKeyRegistered == NO) {
			EventHotKeyID previousSong = {'gsur', 1};
			EventHotKeyID nextSong = {'gsur', 2};
			EventHotKeyID playPause = {'gsur', 3};
			EventHotKeyID toggleShuffle = {'gsur', 4};
			EventHotKeyID favoriteSong = {'gsur', 5};
			EventHotKeyID songToast = {'gsur', 6};
			
			RegisterEventHotKey([[[[NSUserDefaults standardUserDefaults] arrayForKey:@"PreviousKey"] objectAtIndex:0] intValue], SRCocoaToCarbonFlags([[[[NSUserDefaults standardUserDefaults] arrayForKey:@"PreviousKey"] objectAtIndex:1] intValue]), previousSong, GetApplicationEventTarget(), 0, &eventHotKeyRef[0]);
			RegisterEventHotKey([[[[NSUserDefaults standardUserDefaults] arrayForKey:@"NextKey"] objectAtIndex:0] intValue], SRCocoaToCarbonFlags([[[[NSUserDefaults standardUserDefaults] arrayForKey:@"NextKey"] objectAtIndex:1] intValue]), nextSong, GetApplicationEventTarget(), 0, &eventHotKeyRef[1]);
			RegisterEventHotKey([[[[NSUserDefaults standardUserDefaults] arrayForKey:@"PlayPauseKey"] objectAtIndex:0] intValue], SRCocoaToCarbonFlags([[[[NSUserDefaults standardUserDefaults] arrayForKey:@"PlayPauseKey"] objectAtIndex:1] intValue]), playPause, GetApplicationEventTarget(), 0, &eventHotKeyRef[2]);
			RegisterEventHotKey([[[[NSUserDefaults standardUserDefaults] arrayForKey:@"ShuffleKey"] objectAtIndex:0] intValue], SRCocoaToCarbonFlags([[[[NSUserDefaults standardUserDefaults] arrayForKey:@"ShuffleKey"] objectAtIndex:1] intValue]), toggleShuffle, GetApplicationEventTarget(), 0, &eventHotKeyRef[3]);
			hotKeyRegistered = YES;
			[[NSUserDefaults standardUserDefaults] setBool:1 forKey:@"EnableGlobalKeys"];
			[mi_globalKeys setState:NSOnState];
		}
	} else if (registerKeys == NO) {
		if (hotKeyRegistered == YES) {
			for (int i = 0; i < 8; i++) {
				UnregisterEventHotKey(eventHotKeyRef[i]);
			}
			[mi_globalKeys setState:NSOffState];
			[[NSUserDefaults standardUserDefaults] setBool:0 forKey:@"EnableGlobalKeys"];
			hotKeyRegistered = NO;
		}
	}
}

CGEventRef myCGEventCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *refcon) {
	GoogleMusicKeysAppDelegate *appDelegate = (GoogleMusicKeysAppDelegate *)refcon;
	return [appDelegate processEvent:event withType:type];
}

- (CGEventRef) processEvent:(CGEventRef)event withType:(CGEventType)type {
	//Paranoid sanity check.
	if (type == kCGEventTapDisabledByTimeout) {
		CGEventTapEnable(eventTap, YES);
		return event;
	} else if (type != NX_SYSDEFINED) {
		return event;
	}
	
	NSEvent *e = [NSEvent eventWithCGEvent:event];
	//We're getting a special event
	if ([e type] == NSSystemDefined && [e subtype] == 8) {
		if ([e data1] == 1051136) {
			[controller playPause];
			return NULL;
		} else if ([e data1] == 1313280) {
			[controller previous];
			return NULL;
		} else if ([e data1] == 1247744) {
			[controller next];
			return NULL;
		}
	}
	
	return event;
}

- (void) setupEvents {
	// Create an event tap. We are interested in system defined keys.
	eventTap = CGEventTapCreate(kCGSessionEventTap, kCGHeadInsertEventTap, 0, CGEventMaskBit(NX_SYSDEFINED), myCGEventCallback, self);
	// Create a run loop source
	CFRunLoopSourceRef runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0);
	//Add to the current run loop.
	CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopCommonModes);
}

- (void)registerMediaKeys:(BOOL)registerKeys {
	if (registerKeys == YES) {
		if (mediaKeyRegistered == NO) {
			mediaKeyRegistered = YES;
			CGEventTapEnable(eventTap, true);
			[[NSUserDefaults standardUserDefaults] setBool:1 forKey:@"EnableMediaKeys"];
			[mi_mediaKeys setState:NSOnState];
		}
	} else if (registerKeys == NO) {
		if (mediaKeyRegistered == YES) {
			mediaKeyRegistered = NO;
			CGEventTapEnable(eventTap, false);
			[[NSUserDefaults standardUserDefaults] setBool:0 forKey:@"EnableMediaKeys"];
			[mi_mediaKeys setState:NSOffState];
		}
	}
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    controller = [[GoogleMusicController alloc] init];
    
	bundlePath = [[NSBundle mainBundle] bundlePath];
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
	if ([self isSetForLogin:loginItems ForPath:bundlePath]) {
		loadAtLogin = YES;
		[mi_startAtLogin setState:NSOnState];
	}
	
	statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength] retain];
	NSImage *statusImage = [NSImage imageNamed:@"gs16.png"];
	[statusItem setTitle:@"GMK"];
	[statusItem setHighlightMode:YES];
	
	[statusItem setMenu:statusMenu];
	hotKeyRegistered = NO;
	mediaKeyRegistered = YES;
	[mi_mediaKeys setState:NSOnState];
	[self setupEvents];
	[self registerHotKeys:[[NSUserDefaults standardUserDefaults] boolForKey:@"EnableGlobalKeys"]];
	[self registerMediaKeys:[[NSUserDefaults standardUserDefaults]boolForKey:@"EnableMediaKeys"]];
	if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"]) {
		[mi_firstLaunch makeKeyAndOrderFront:self];
		[[NSUserDefaults standardUserDefaults] setBool:1 forKey:@"HasLaunchedOnce"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}

- (IBAction)showGrooveshark:(id)sender {
}

- (IBAction)startAtLogin:(id)sender {
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
	if (loginItems) {
		if ([sender state] == NSOnState) {
			[self disableLoginItem:loginItems ForPath:bundlePath];
			[sender setState:NSOffState];
		} else {
			[self enableLoginItem:loginItems ForPath:bundlePath];
			[sender setState:NSOnState];
		}
	}
	CFRelease(loginItems);
}

- (IBAction)mediaKeys:(id)sender {
	if ([mi_mediaKeys state] == NSOffState) {
		[self registerMediaKeys:YES];
	} else {
		[self registerMediaKeys:NO];
	}
	if ([[NSUserDefaults standardUserDefaults] synchronize]) {
	}
}

- (IBAction)globalKeys:(id)sender {
	if ([mi_globalKeys state] == NSOffState) {
		[self registerHotKeys:YES];
	} else {
		[self registerHotKeys:NO];
	}
	if ([[NSUserDefaults standardUserDefaults] synchronize]) {
	}
}

- (IBAction)appleRemote:(id)sender {
	//Not Yet Created
	//But probably simple to support.
	//TODO: Terin Stock
}

- (IBAction)openLink:(id)sender {
	[mi_firstLaunch close];
	NSURL *moreInfoURL = [[NSURL alloc] initWithString:@"http://threestrangedays.net/gsdesktophelper"];
	[[NSWorkspace sharedWorkspace] openURL:[moreInfoURL absoluteURL]];
	[moreInfoURL release];
}

- (IBAction)openPreferencesWindow:(id)sender {
	[NSBundle loadNibNamed:@"PreferencePane" owner:self];
}

@end
