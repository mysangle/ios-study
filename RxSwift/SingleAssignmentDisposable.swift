//
//  SingleAssignmentDisposable.swift
//  ios-study
//
//  Created by soonhyung-imac on 27/04/2017.
//  Copyright © 2017 twentyhours. All rights reserved.
//

/// 내부의 Disposable을 한번만 설정이 가능하다.
public final class SingleAssignmentDisposable : DisposeBase, Disposable, Cancelable {
    fileprivate enum DisposeState: UInt32 {
        case disposed = 1
        case disposableSet = 2
    }
    
    fileprivate enum DisposeStateInt32: Int32 {
        case disposed = 1
        case disposableSet = 2
    }
    
    private var _state: AtomicInt = 0
    private var _disposable = nil as Disposable?
    
    public var isDisposed: Bool {
        return AtomicFlagSet(DisposeState.disposed.rawValue, &_state)
    }
    
    public override init() {
        super.init()
    }
    
    public func setDisposable(_ disposable: Disposable) {
        _disposable = disposable
        
        let previousState = AtomicOr(DisposeState.disposableSet.rawValue, &_state)
        
        if (previousState & DisposeStateInt32.disposableSet.rawValue) != 0 {
            // 이미 disposable을 설정한 적이 있으면 에러
            rxFatalError("oldState.disposable != nil")
        }
        
        if (previousState & DisposeStateInt32.disposed.rawValue) != 0 {
            // 이전에 dispose()가 불린적이 있으면 바로 지금 설정한 disposable의 dispose()를 호출한다.
            disposable.dispose()
            _disposable = nil
        }
    }
    
    public func dispose() {
        let previousState = AtomicOr(DisposeState.disposed.rawValue, &_state)
        
        if (previousState & DisposeStateInt32.disposed.rawValue) != 0 {
            // 이전에 dispose()가 불린적이 있으면 무시한다.
            return
        }
        
        if (previousState & DisposeStateInt32.disposableSet.rawValue) != 0 {
            // setDisposable()이후에 dispose()가 불리었으면 설정된 disposable의
            // dispose()를 호출한다.
            guard let disposable = _disposable else {
                rxFatalError("Disposable not set")
            }
            disposable.dispose()
            _disposable = nil
        }
    }
}
