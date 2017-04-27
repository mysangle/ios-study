//
//  AnyObserver.swift
//  ios-study
//
//  Created by soonhyung-imac on 19/04/2017.
//  Copyright © 2017 twentyhours. All rights reserved.
//

/// observable에 연결된 observer
/// 이벤트 발생시 이를 실제 이벤트를 받아야 하는 observer.on에 연결한다.
/// 실제 이벤트를 받아야 하는 observer는 생성시 인자로 받는다(실제로는 이의 on 함수를 가지고 있는다.).
public struct AnyObserver<Element> : ObserverType {
    public typealias E = Element
    
    // ObserverType의 on함수의 signature
    public typealias EventHandler = (Event<Element>) -> Void
    
    private let observer: EventHandler
    
    public init<O : ObserverType>(_ observer: O) where O.E == Element {
        self.observer = observer.on
    }
    
    public func on(_ event: Event<Element>) {
        return self.observer(event)
    }
}
