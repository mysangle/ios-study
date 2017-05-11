//
//  AnonymousObserver.swift
//  ios-study
//
//  Created by soonhyung-imac on 27/04/2017.
//  Copyright © 2017 twentyhours. All rights reserved.
//

final class AnonymousObserver<ElementType> : ObserverBase<ElementType> {
    typealias Element = ElementType
    
    typealias EventHandler = (Event<Element>) -> Void
    
    private let _eventHandler : EventHandler
    
    init(_ eventHandler: @escaping EventHandler) {
#if TRACE_RESOURCES
        let _ = Resources.incrementTotal()
#endif
        _eventHandler = eventHandler
    }
    
    override func onCore(_ event: Event<Element>) {
        return _eventHandler(event)
    }
    
#if TRACE_RESOURCES
    deinit {
        let _ = Resources.decrementTotal()
    }
#endif
}
