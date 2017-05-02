//
//  SerialDisposable.swift
//  ios-study
//
//  Created by soonhyung-imac on 02/05/2017.
//  Copyright © 2017 twentyhours. All rights reserved.
//

public final class SerialDisposable : DisposeBase, Cancelable {
    private var _lock = SpinLock()
    
    // state
    private var _current = nil as Disposable?
    private var _isDisposed = false
    
    /// - returns: Was resource disposed.
    public var isDisposed: Bool {
        return _isDisposed
    }
    
    /// initialize a new instance of the `SerialDisposable`.
    override public init() {
        super.init()
    }
    
    /// 새로 disposable을 설정하면 이전의 disposable을 dispose한다.
    public var disposable: Disposable {
        get {
            return _lock.calculateLocked {
                return self.disposable
            }
        }
        set (newDisposable) {
            let disposable: Disposable? = _lock.calculateLocked {
                if _isDisposed {
                    return newDisposable
                }
                else {
                    let toDispose = _current
                    _current = newDisposable
                    return toDispose
                }
            }
            
            if let disposable = disposable {
                disposable.dispose()
            }
        }
    }
    
    /// dispose the underlying disposable as well as all future replacements.
    public func dispose() {
        _dispose()?.dispose()
    }
    
    private func _dispose() -> Disposable? {
        _lock.lock(); defer { _lock.unlock() }
        if _isDisposed {
            return nil
        }
        else {
            _isDisposed = true
            let current = _current
            _current = nil
            return current
        }
    }
}
