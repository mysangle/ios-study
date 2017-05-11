//
//  CompositeDisposable.swift
//  ios-study
//
//  Created by soonhyung-imac on 28/04/2017.
//  Copyright © 2017 twentyhours. All rights reserved.
//

public final class CompositeDisposable : DisposeBase, Disposable, Cancelable {
    public struct DisposeKey {
        fileprivate let key: BagKey
        fileprivate init(key: BagKey) {
            self.key = key
        }
    }
    
    private var _lock = SpinLock()
    
    private var _disposables: Bag<Disposable>? = Bag()
    
    public var isDisposed: Bool {
        _lock.lock(); defer { _lock.unlock() }
        return _disposables == nil
    }
    
    public override init() {
    }
    
    public init(disposables: [Disposable]) {
        for disposable in disposables {
            let _ = _disposables!.insert(disposable)
        }
    }
    
    public func insert(_ disposable: Disposable) -> DisposeKey? {
        let key = _insert(disposable)
        
        if key == nil {
            disposable.dispose()
        }
        
        return key
    }
    
    private func _insert(_ disposable: Disposable) -> DisposeKey? {
        _lock.lock(); defer { _lock.unlock() }
        
        let bagKey = _disposables?.insert(disposable)
        return bagKey.map(DisposeKey.init)
    }
    
    public func remove(for disposeKey: DisposeKey) {
        _remove(for: disposeKey)?.dispose()
    }
    
    private func _remove(for disposeKey: DisposeKey) -> Disposable? {
        _lock.lock(); defer { _lock.unlock() }
        return _disposables?.removeKey(disposeKey.key)
    }
    
    public func dispose() {
        if let disposables = _dispose() {
            // 복사한 disposable들을 dispose한다.
            disposeAll(in: disposables)
        }
    }
    
    private func _dispose() -> Bag<Disposable>? {
        _lock.lock(); defer { _lock.unlock() }
        
        // disposable들을 복사한 후 기존것은 nil로 설정한다.
        let disposeBag = _disposables
        _disposables = nil
        
        return disposeBag
    }
}

extension Disposables {
    public static func create(_ disposables: [Disposable]) -> Cancelable {
        switch disposables.count {
        case 2:
            return Disposables.create(disposables[0], disposables[1])
        default:
            return CompositeDisposable(disposables: disposables)
        }
    }
}
