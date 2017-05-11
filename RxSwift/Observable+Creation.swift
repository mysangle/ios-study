//
//  Observable+Creation.swift
//  ios-study
//
//  Created by soonhyung-imac on 19/04/2017.
//  Copyright © 2017 twentyhours. All rights reserved.
//

extension Observable {
    public static func create(_ subscribe: @escaping (AnyObserver<E>) -> Disposable) -> Observable<E> {
        return AnonymousObservable(subscribe)
    }
}
