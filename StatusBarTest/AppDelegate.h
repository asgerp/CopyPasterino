//
//  AppDelegate.h
//  StatusBarTest
//
//  Created by Asger Pedersen on 26/06/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class MASShortcutView;
@interface AppDelegate : NSObject <NSApplicationDelegate>
extern const int MAX_NUMBER_OF_ITEMS;


- (void) updateMenuItem;

@property (assign) IBOutlet NSWindow *window;
@property NSPasteboard *pBoard;
@property NSInteger count;


@property (strong, nonatomic) IBOutlet NSMenu *statusMenu;
@property (strong, nonatomic) NSStatusItem *statusItem;



@property (nonatomic, weak) IBOutlet MASShortcutView *shortcutView;

@end
