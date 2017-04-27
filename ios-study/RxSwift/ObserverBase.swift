//
//  ObserverBase.swift
//  ios-study
//
//  Created by soonhyung-imac on 27/04/2017.
//  Copyright © 2017 twentyhours. All rights reserved.
//

/// 이 클래스를 상속받은 클래스는 onCore를 구현해야 한다.
/// 이벤트 발생시 onCore를 호출해준다.
class ObserverBase<ElementType> : Disposable, ObserverType {
    typealias E = ElementType
    
    // dispose시 1로 설정하여 next 이벤트가 발생하지 않도록 한다.
    private var _isStopped: AtomicInt = 0
    
    func on(_ event: Event<E>) {
        switch event {
        case .next:
            if _isStopped == 0 {
                onCore(event)
            }
        case .error, .completed:
            if AtomicCompareAndSwap(0, 1, &_isStopped) {
                onCore(event)
            }
        }
    }
    
    func onCore(_ event: Event<E>) {
        rxAbstractMethod()
    }
    
    func dispose() {
        _ = AtomicCompareAndSwap(0, 1, &_isStopped)
    }
}
