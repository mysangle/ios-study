//
//  Observable.swift
//  ios-study
//
//  Created by soonhyung-imac on 19/04/2017.
//  Copyright © 2017 twentyhours. All rights reserved.
//

public class Observable<Element> : ObservableType {
    public typealias E = Element
    
    public func subscribe<O: ObserverType>(_ observer: O) -> Disposable where O.E == E {
        rxAbstractMethod()
    }
    
    public func asObservable() -> Observable<E> {
        return self
    }
}
