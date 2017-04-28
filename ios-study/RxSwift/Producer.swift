//
//  Producer.swift
//  ios-study
//
//  Created by soonhyung-imac on 19/04/2017.
//  Copyright © 2017 twentyhours. All rights reserved.
//

class Producer<Element> : Observable<Element> {
    override func subscribe<O: ObserverType>(_ observer: O) -> Disposable where O.E == Element {
        if !CurrentThreadScheduler.isScheduleRequired {
            let disposer = SinkDisposer()
            let sinkAndSubscription = run(observer, cancel: disposer)
            disposer.setSinkAndSubscription(sink: sinkAndSubscription.sink, subscription: sinkAndSubscription.subscription)
            
            return disposer
        } else {
            return CurrentThreadScheduler.instance.schedule(()) { _ in
                let disposer = SinkDisposer()
                let sinkAndSubscription = self.run(observer, cancel: disposer)
                disposer.setSinkAndSubscription(sink: sinkAndSubscription.sink, subscription: sinkAndSubscription.subscription)
                
                return disposer
            }
        }
    }
    
    /// abstract
    func run<O: ObserverType>(_ observer: O, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where O.E == Element {
        rxAbstractMethod()
    }
}

fileprivate final class SinkDisposer: Cancelable {
    fileprivate enum DisposeState: UInt32 {
        case disposed = 1
        case sinkAndSubscriptionSet = 2
    }
    
    fileprivate enum DisposeStateInt32: Int32 {
        case disposed = 1
        case sinkAndSubscriptionSet = 2
    }
    
    private var _state: AtomicInt = 0
    // observer를 dispose하기
    private var _sink: Disposable? = nil
    // _subscribeHandler를 dispose하기
    private var _subscription: Disposable? = nil
    
    var isDisposed: Bool {
        return AtomicFlagSet(DisposeState.disposed.rawValue, &_state)
    }
    
    func setSinkAndSubscription(sink: Disposable, subscription: Disposable) {
        _sink = sink
        _subscription = subscription
        
        // _state에 sinkAndSubscriptionSet을 설정하고 이전 값을 리턴한다.
        let previousState = AtomicOr(DisposeState.sinkAndSubscriptionSet.rawValue, &_state)
        if (previousState & DisposeStateInt32.sinkAndSubscriptionSet.rawValue) != 0 {
            rxFatalError("Sink and subscription were already set")
        }
        
        if (previousState & DisposeStateInt32.disposed.rawValue) != 0 {
            // 이미 disposed가 설정되어 있었으면 바로 dispose를 호출해준다.
            // setSinkAndSubscription()보다 dispose()가 먼저 불린 케이스이다.
            sink.dispose()
            subscription.dispose()
            _sink = nil
            _subscription = nil
        }
    }
    
    func dispose() {
        // _state에 disposed를 설정하고 이전 값을 리턴한다.
        let previousState = AtomicOr(DisposeState.disposed.rawValue, &_state)
        
        if (previousState & DisposeStateInt32.disposed.rawValue) != 0 {
            // 이미 dispose를 이전에 호출했다.
            return
        }
        
        if (previousState & DisposeStateInt32.sinkAndSubscriptionSet.rawValue) != 0 {
            // sink와 subscription이 설정되어 있으면 이들의 dispose를 호출해준다.
            guard let sink = _sink else {
                rxFatalError("Sink not set")
            }
            guard let subscription = _subscription else {
                rxFatalError("Subscription not set")
            }
            
            sink.dispose()
            subscription.dispose()
            
            _sink = nil
            _subscription = nil
        }
    }
}
