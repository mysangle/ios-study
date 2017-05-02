//
//  Event.swift
//  ios-study
//
//  Created by soonhyung-imac on 19/04/2017.
//  Copyright © 2017 twentyhours. All rights reserved.
//

public enum Event<Element> {
    case next(Element)
    
    case error(Swift.Error)
    
    case completed
}

extension Event : CustomDebugStringConvertible {
    /// - returns: Description of event.
    public var debugDescription: String {
        switch self {
        case .next(let value):
            return "next(\(value))"
        case .error(let error):
            return "error(\(error))"
        case .completed:
            return "completed"
        }
    }
}

extension Event {
    /// Is `completed` or `error` event.
    public var isStopEvent: Bool {
        switch self {
        case .next: return false
        case .error, .completed: return true
        }
    }
    
    /// If `next` event, returns element value.
    public var element: Element? {
        if case .next(let value) = self {
            return value
        }
        return nil
    }
    
    /// If `error` event, returns error.
    public var error: Swift.Error? {
        if case .error(let error) = self {
            return error
        }
        return nil
    }
    
    /// If `completed` event, returns true.
    public var isCompleted: Bool {
        if case .completed = self {
            return true
        }
        return false
    }
}
