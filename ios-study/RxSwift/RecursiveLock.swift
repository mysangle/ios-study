//
//  RecursiveLock.swift
//  ios-study
//
//  Created by soonhyung-imac on 28/04/2017.
//  Copyright © 2017 twentyhours. All rights reserved.
//

import Foundation

#if TRACE_RESOURCES
    class RecursiveLock: NSRecursiveLock {
        override init() {
            _ = Resources.incrementTotal()
            super.init()
        }
        
        override func lock() {
            super.lock()
            _ = Resources.incrementTotal()
        }
        
        override func unlock() {
            super.unlock()
            _ = Resources.decrementTotal()
        }
        
        deinit {
            _ = Resources.decrementTotal()
        }
    }
#else
    typealias RecursiveLock = NSRecursiveLock
#endif
