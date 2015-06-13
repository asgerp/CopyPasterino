//
//  Paste.swift
//  CopyPasterino
//
//  Created by Asger Pedersen on 15/02/15.
//  Copyright (c) 2015 Asger Pedersen. All rights reserved.
//

import Foundation

class Paste {
    var paste:String
    var name:String
    var image:NSImage
    var dateSet:String
    
    init(paste: String, name: String, image: NSImage){
        self.paste = paste
        self.name = name
        self.image = image
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd 'at' h:mm a" // superset of OP's format
        self.dateSet = dateFormatter.stringFromDate(NSDate())
    }
    
}
