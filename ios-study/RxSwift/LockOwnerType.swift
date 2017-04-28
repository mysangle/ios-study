//
//  LockOwnerType.swift
//  ios-study
//
//  Created by soonhyung-imac on 28/04/2017.
//  Copyright © 2017 twentyhours. All rights reserved.
//

protocol LockOwnerType : class, Lock {
    var _lock: RecursiveLock { get }
}

extension LockOwnerType {
    func lock() {
        _lock.lock()
    }
    
    func unlock() {
        _lock.unlock()
    }
}
