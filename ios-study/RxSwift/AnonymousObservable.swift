//
//  AnonymousObservable.swift
//  ios-study
//
//  Created by soonhyung-imac on 19/04/2017.
//  Copyright © 2017 twentyhours. All rights reserved.
//

final class AnonymousObservableSink<O: ObserverType> : Sink<O>, ObserverType {
    typealias E = O.E
    // 이 sink에 연결된 observable
    typealias Parent = AnonymousObservable<E>
    
    // error나 completed의 이벤트 발생시 1로 설정하여 이후에 next 이벤트 발생을 막는다.
    private var _isStopped: AtomicInt = 0
    
#if DEBUG
    // 동시에 여러번 불리는지를 확인한다. on 함수는 동시에 여러번 불리면 안된다.
    fileprivate var _numberOfConcurrentCalls: AtomicInt = 0
#endif
    
    override init(observer: O, cancel: Cancelable) {
        super.init(observer: observer, cancel: cancel)
    }

    /// 이벤트 발생시 불리는 함수
    func on(_ event: Event<E>) {
#if DEBUG
        if AtomicIncrement(&_numberOfConcurrentCalls) > 1 {
            rxFatalError("Warning: Recursive call or synchronization error!")
        }
            
        defer {
            _ = AtomicDecrement(&_numberOfConcurrentCalls)
        }
#endif
        switch event {
        case .next:
            if _isStopped == 1 {
                return
            }
            forwardOn(event)
        case .error, .completed:
            if AtomicCompareAndSwap(0, 1, &_isStopped) {
                forwardOn(event)
                dispose()
            }
        }
    }
    
    /// observer를 subscribe시 observable로부터 호출되는 함수
    func run(_ parent: Parent) -> Disposable {
        return parent._subscribeHandler(AnyObserver(self))
    }
}

final class AnonymousObservable<Element> : Producer<Element> {
    typealias SubscribeHandler = (AnyObserver<Element>) -> Disposable
    
    // 이벤트를 발생시키는 handler
    let _subscribeHandler: SubscribeHandler
    
    init(_ subscribeHandler: @escaping SubscribeHandler) {
        _subscribeHandler = subscribeHandler
    }
    
    override func run<O: ObserverType>(_ observer: O, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where O.E == Element {
        let sink = AnonymousObservableSink(observer: observer, cancel: cancel)
        let subscription = sink.run(self)
        return (sink: sink, subscription: subscription)
    }
}
