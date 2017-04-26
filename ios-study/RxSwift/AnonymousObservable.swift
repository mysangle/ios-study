//
//  AnonymousObservable.swift
//  ios-study
//
//  Created by soonhyung-imac on 19/04/2017.
//  Copyright © 2017 twentyhours. All rights reserved.
//

final class AnonymousObservable<Element> : Producer<Element> {
    typealias SubscribeHandler = (AnyObserver<Element>) -> Disposable
    
    let _subscribeHandler: SubscribeHandler
    
    init(_ subscribeHandler: @escaping SubscribeHandler) {
        _subscribeHandler = subscribeHandler
    }
}
