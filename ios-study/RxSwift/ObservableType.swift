//
//  ObservableType.swift
//  ios-study
//
//  Created by soonhyung-imac on 19/04/2017.
//  Copyright © 2017 twentyhours. All rights reserved.
//

public protocol ObservableType : ObservableConvertibleType {
    associatedtype E
    
    // 이벤트를 받기 위한 observer를 등록한다.
    func subscribe<O: ObserverType>(_ observer: O) -> Disposable where O.E == E
}

// ObservableType에 ObservableConvertibleType의 함수를 구현해 넣는다.
extension ObservableType {
    public func asObservable() -> Observable<E> {
        // Observable+Creation.swift에 구현되어 있다.
        // AnonymousObservable을 리턴한다.
        // o의 타입은 AnyObserver<E>이다.
        return Observable.create { o in
            return self.subscribe(o)
        }
    }
}
