//
//  AnonymousDisposable.swift
//  ios-study
//
//  Created by soonhyung-imac on 27/04/2017.
//  Copyright © 2017 twentyhours. All rights reserved.
//

fileprivate final class AnonymousDisposable : DisposeBase, Cancelable {
    public typealias DisposeAction = () -> Void
    
    // dispose될 때 1로 설정하여 dispose되었음을 알려주는 값
    private var _isDisposed: AtomicInt = 0
    // dispose시 실행될 함수
    private var _disposeAction: DisposeAction?
    
    public var isDisposed: Bool {
        return _isDisposed == 1
    }
    
    fileprivate init(disposeAction: @escaping DisposeAction) {
        _disposeAction = disposeAction
        super.init()
    }
    
    fileprivate func dispose() {
        if AtomicCompareAndSwap(0, 1, &_isDisposed) {
            assert(_isDisposed == 1)
            
            if let action = _disposeAction {
                _disposeAction = nil
                action()
            }
        }
    }
}

extension Disposables {
    public static func create(with dispose: @escaping () -> ()) -> Cancelable {
        return AnonymousDisposable(disposeAction: dispose)
    }
}
