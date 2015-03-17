//
//  PasteBoardTextSubscriber.swift
//  CopyPasterino
//
//  Created by Asger Pedersen on 16/03/15.
//  Copyright (c) 2015 Asger Pedersen. All rights reserved.
//

import Foundation
import Cocoa

class PasteBoardTextSubscriber: NSObject, PasteBoardSubscriber {
 
    func pasteBoardChanged(pasteboard: NSPasteboard) {
        println("in da subs")
        
        let appDelegate = NSApplication.sharedApplication().delegate as AppDelegate
        
        let myString = pasteboard.stringForType(NSPasteboardTypeString)!
        var menu:NSMenu = appDelegate.statusItem!.menu!
        var numberOfItems = menu.numberOfItems + 1
        var menuItem:NSMenuItem = NSMenuItem(title: myString, action: Selector("setPasteBoardString:"),
            keyEquivalent: String(numberOfItems))
        menuItem.representedObject = menuItem
        menuItem.target = self
        menuItem.enabled = true
        menu.addItem(menuItem)
        
        let activeApp = NSWorkspace.sharedWorkspace().frontmostApplication
        
        let activeAppName = activeApp?.localizedName
        
        let image = activeApp?.icon?.copy() as NSImage
        
        var paste:Paste = Paste(paste: myString, name: activeAppName!, image: image)
        appDelegate._tableContents.insert(paste, atIndex: 0)
        appDelegate.tableView.reloadData()
        
    }
}
