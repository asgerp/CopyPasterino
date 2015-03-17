//
//  PasteBoardSubscriber.swift
//  CopyPasterino
//
//  Created by Asger Pedersen on 16/03/15.
//  Copyright (c) 2015 Asger Pedersen. All rights reserved.
//

import Foundation
import Cocoa

@objc protocol PasteBoardSubscriber: NSObjectProtocol {
    func pasteBoardChanged(pasteboard: NSPasteboard)
}
