//
//  NopDisposable.swift
//  ios-study
//
//  Created by soonhyung-imac on 27/04/2017.
//  Copyright © 2017 twentyhours. All rights reserved.
//

/// 아무것도 하지 않는 disposable
fileprivate struct NopDisposable : Disposable {
    
    fileprivate static let noOp: Disposable = NopDisposable()
    
    fileprivate init() {
        
    }
    
    /// do nothing.
    public func dispose() {
    }
}

extension Disposables {
    static public func create() -> Disposable {
        return NopDisposable.noOp
    }
}
