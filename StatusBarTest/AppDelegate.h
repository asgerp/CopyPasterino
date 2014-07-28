//
//  AppDelegate.h
//  StatusBarTest
//
//  Created by Asger Pedersen on 26/06/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MASShortcutView;
@interface AppDelegate : NSObject <NSApplicationDelegate,NSMenuDelegate>
extern const int MAX_NUMBER_OF_ITEMS;


- (void) updateMenuItem;

- (void)menuWillOpen:(NSMenu *)menu;

- (void)menuDidClose:(NSMenu *)menu;


@property NSPasteboard *pBoard;
@property NSInteger count;
@property BOOL isOpen;

@property (strong, nonatomic) IBOutlet NSWindow *window;
@property (strong, nonatomic) IBOutlet NSMenu *statusMenu;
@property (strong, nonatomic) NSStatusItem *statusItem;



@property (nonatomic, weak) IBOutlet MASShortcutView *shortcutView;

@end
