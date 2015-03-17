//
//  PasteBoardObserver.swift
//  CopyPasterino
//
//  Created by Asger Pedersen on 17/02/15.
//  Copyright (c) 2015 Asger Pedersen. All rights reserved.
//

import Foundation
import Cocoa

enum PasteBoardObserverState {
    case Started
    case Stopped
    case Paused
}

class PasteBoardObserver: NSObject {
    var pasteBoard : NSPasteboard = NSPasteboard.generalPasteboard()
    var subscribers : NSMutableArray = NSMutableArray()
    var change : Int = 0
    var state : PasteBoardObserverState = PasteBoardObserverState.Stopped
    
    override init() {
        
    }
    
    func startObserving(){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            self.start()
            self.observe()
        })
    }
    
    // observe loop.
    // check for changes in the pasteboard
    func observe(){
        while(self.isStarted()){
            usleep(20000)
            var lastChange = self.change
            self.change = self.pasteBoard.changeCount
            if( self.change == lastChange) {
                continue
            }
            self.notifySubscribers()
            
        }
    }
    
    // notify subscribers when there are changes
    func notifySubscribers(){
        dispatch_sync(dispatch_get_main_queue(), {() -> Void in
            for item in self.subscribers {
                if let subscriber = item as? protocol<PasteBoardSubscriber> {
                    subscriber.pasteBoardChanged(self.pasteBoard)
                }
            }
        })
        
    }
    
    // Subscribers
    func addSubscriber(pasteBoardSubscriber: PasteBoardSubscriber){
        self.subscribers.addObject(pasteBoardSubscriber)
    }
    
    func removeSubscriber(pasteBoardSubscriber: PasteBoardSubscriber){
        self.subscribers.removeObject(pasteBoardSubscriber)
    }
    
    //State
    func isStarted() -> Bool {
        return self.state == .Started
    }
    
    func start(){
        self.state = .Started
    }

    func pause(){
        self.state = .Paused
    }

    func stop(){
        self.state = .Stopped
    }

    
}
