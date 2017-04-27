//
//  Sink.swift
//  ios-study
//
//  Created by soonhyung-imac on 27/04/2017.
//  Copyright © 2017 twentyhours. All rights reserved.
//

class Sink<O : ObserverType> : Disposable {
    fileprivate let _observer: O
    fileprivate let _cancel: Cancelable
    // observer가 종료되었는지를 확인하기 위한 flag
    fileprivate var _disposed: Bool
    
#if DEBUG
    fileprivate var _numberOfConcurrentCalls: AtomicInt = 0
#endif
    
    init(observer: O, cancel: Cancelable) {
#if TRACE_RESOURCES
        let _ = Resources.incrementTotal()
#endif
        _observer = observer
        _cancel = cancel
        _disposed = false
    }
    
    final func forwardOn(_ event: Event<O.E>) {
#if DEBUG
        if AtomicIncrement(&_numberOfConcurrentCalls) > 1 {
            rxFatalError("Warning: Recursive call or synchronization error!")
        }
            
        defer {
            _ = AtomicDecrement(&_numberOfConcurrentCalls)
        }
#endif
        if _disposed {
            return
        }
        _observer.on(event)
    }
    
    final var disposed: Bool {
        return _disposed
    }
    
    func dispose() {
        _disposed = true
        _cancel.dispose()
    }
    
    deinit {
#if TRACE_RESOURCES
        let _ =  Resources.decrementTotal()
#endif
    }
}
