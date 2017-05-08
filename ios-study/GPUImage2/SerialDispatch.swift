//
//  SerialDispatch.swift
//  ios-study
//
//  Created by soonhyung-imac on 3/9/17.
//  Copyright © 2017 twentyhours. All rights reserved.
//

import Foundation

public protocol SerialDispatch {
    var serialDispatchQueue:DispatchQueue { get }
    var dispatchQueueKey:DispatchSpecificKey<Int> { get }
    func makeCurrentContext()
}

public extension SerialDispatch {
    public func runOperationAsynchronously(_ operation:@escaping () -> ()) {
        self.serialDispatchQueue.async {
            self.makeCurrentContext()
            operation()
        }
    }
    
    public func runOperationSynchronously(_ operation:() -> ()) {
        // TODO: Verify this works as intended
        if (DispatchQueue.getSpecific(key:self.dispatchQueueKey) == 81) {
            operation()
        } else {
            self.serialDispatchQueue.sync {
                self.makeCurrentContext()
                operation()
            }
        }
    }
    
    public func runOperationSynchronously(_ operation:() throws -> ()) throws {
        var caughtError:Error? = nil
        runOperationSynchronously {
            do {
                try operation()
            } catch {
                caughtError = error
            }
        }
        if (caughtError != nil) {
            throw caughtError!
        }
    }
    
    public func runOperationSynchronously<T>(_ operation:() throws -> T) throws -> T {
        var returnedValue: T!
        try runOperationSynchronously {
            returnedValue = try operation()
        }
        return returnedValue
    }
}
