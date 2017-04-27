//
//  BinaryDisposable.swift
//  ios-study
//
//  Created by soonhyung-imac on 27/04/2017.
//  Copyright © 2017 twentyhours. All rights reserved.
//

/// 두개의 disposal이 함께 호출되도록 하는 disposal
private final class BinaryDisposable : DisposeBase, Cancelable {
    private var _isDisposed: AtomicInt = 0
    
    private var _disposable1: Disposable?
    private var _disposable2: Disposable?
    
    var isDisposed: Bool {
        return _isDisposed > 0
    }
    
    init(_ disposable1: Disposable, _ disposable2: Disposable) {
        _disposable1 = disposable1
        _disposable2 = disposable2
        super.init()
    }
    
    func dispose() {
        if AtomicCompareAndSwap(0, 1, &_isDisposed) {
            _disposable1?.dispose()
            _disposable2?.dispose()
            _disposable1 = nil
            _disposable2 = nil
        }
    }
}

extension Disposables {
    public static func create(_ disposable1: Disposable, _ disposable2: Disposable) -> Cancelable {
        return BinaryDisposable(disposable1, disposable2)
    }
}
