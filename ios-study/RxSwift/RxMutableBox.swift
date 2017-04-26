//
//  RxMutableBox.swift
//  ios-study
//
//  Created by soonhyung-imac on 26/04/2017.
//  Copyright © 2017 twentyhours. All rights reserved.
//

/// create mutable reference wrapper for any type.
final class RxMutableBox<T> : CustomDebugStringConvertible {
    /// wrapped value
    var value : T
    
    /// create reference wrapper for `value`.
    init (_ value: T) {
        self.value = value
    }
}

extension RxMutableBox {
    /// - returns: Box description.
    var debugDescription: String {
        return "MutatingBox(\(self.value))"
    }
}

