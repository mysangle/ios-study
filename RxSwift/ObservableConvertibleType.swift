//
//  ObservableConvertibleType.swift
//  ios-study
//
//  Created by soonhyung-imac on 19/04/2017.
//  Copyright © 2017 twentyhours. All rights reserved.
//

public protocol ObservableConvertibleType {
    associatedtype E
    
    // observable sequence로 변경한다.
    func asObservable() -> Observable<E>
}
