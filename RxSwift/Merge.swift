//
//  Merge.swift
//  ios-study
//
//  Created by soonhyung-imac on 11/05/2017.
//  Copyright © 2017 twentyhours. All rights reserved.
//

extension ObservableType where E : ObservableConvertibleType {
    /// Observable의 Element가 Observable이어야 한다.
    public func merge() -> Observable<E.E> {
        return Merge(source: asObservable())
    }
}

fileprivate final class MergeSinkIter<SourceType, S: ObservableConvertibleType, O: ObserverType> : ObserverType where O.E == S.E {
    typealias Parent = MergeSink<SourceType, S, O>
    typealias DisposeKey = CompositeDisposable.DisposeKey
    typealias E = O.E
    
    private let _parent: Parent
    private let _disposeKey: DisposeKey
    
    init(parent: Parent, disposeKey: DisposeKey) {
        _parent = parent
        _disposeKey = disposeKey
    }
    
    /// 원본 source의 element인 Observable에서 발생하는 이벤트를 받는다.
    func on(_ event: Event<E>) {
        _parent._lock.lock(); defer { _parent._lock.unlock() } // lock {
        switch event {
        case .next(let value):
            _parent.forwardOn(.next(value))
        case .error(let error):
            _parent.forwardOn(.error(error))
            _parent.dispose()
        case .completed:
            _parent._group.remove(for: _disposeKey)
            _parent._activeCount -= 1
            _parent.checkCompleted()
        }
        // }
    }
}

fileprivate class MergeSink<SourceType, S: ObservableConvertibleType, O: ObserverType>
    : Sink<O>
, ObserverType where O.E == S.E {
    typealias ResultType = O.E
    typealias Element = SourceType
    
    let _lock = RecursiveLock()
    
    var subscribeNext: Bool {
        return true
    }
    
    // state
    // 원본 source의 element를 등록하고, 이 element가 completed되면 빼준다.
    // 완료가 되지 않은 것들만 dispose가 되게 한다.
    let _group = CompositeDisposable()
    let _sourceSubscription = SingleAssignmentDisposable()
    
    var _activeCount = 0
    var _stopped = false
    
    override init(observer: O, cancel: Cancelable) {
        super.init(observer: observer, cancel: cancel)
    }
    
    func performMap(_ element: SourceType) throws -> S {
        rxAbstractMethod()
    }
    
    /// 이벤트가 발생하면 이를 element로부터 다시 이벤트를 받을 수 있도록 한다.
    func on(_ event: Event<SourceType>) {
        _lock.lock(); defer { _lock.unlock() } // lock {
        switch event {
        case .next(let element):
            if !subscribeNext {
                return
            }
            do {
                // element를 ovservable로 변환하여 subscribe한다.
                let value = try performMap(element)
                subscribeInner(value.asObservable())
            }
            catch let e {
                forwardOn(.error(e))
                dispose()
            }
        case .error(let error):
            forwardOn(.error(error))
            dispose()
        case .completed:
            _stopped = true
            _sourceSubscription.dispose()
            checkCompleted()
        }
        //}
    }
    
    func subscribeInner(_ source: Observable<O.E>) {
        let iterDisposable = SingleAssignmentDisposable()
        if let disposeKey = _group.insert(iterDisposable) {
            _activeCount += 1
            let iter = MergeSinkIter(parent: self, disposeKey: disposeKey)
            let subscription = source.subscribe(iter)
            iterDisposable.setDisposable(subscription)
        }
    }
    
    func run(_ sources: [SourceType]) -> Disposable {
        let _ = _group.insert(_sourceSubscription)
        
        for source in sources {
            self.on(.next(source))
        }
        
        _stopped = true
        
        checkCompleted()
        
        return _group
    }
    
    @inline(__always)
    func checkCompleted() {
        if _stopped && _activeCount == 0 {
            self.forwardOn(.completed)
            self.dispose()
        }
    }
    
    func run(_ source: Observable<SourceType>) -> Disposable {
        let _ = _group.insert(_sourceSubscription)
        
        // 원래 source에서 발생한 이벤트를 받는다.
        let subscription = source.subscribe(self)
        _sourceSubscription.setDisposable(subscription)
        
        return _group
    }
}

fileprivate final class MergeBasicSink<S: ObservableConvertibleType, O: ObserverType> : MergeSink<S, S, O> where O.E == S.E {
    override init(observer: O, cancel: Cancelable) {
        super.init(observer: observer, cancel: cancel)
    }
    
    override func performMap(_ element: S) throws -> S {
        return element
    }
}

final fileprivate class Merge<S: ObservableConvertibleType> : Producer<S.E> {
    private let _source: Observable<S>
    
    init(source: Observable<S>) {
        _source = source
    }
    
    override func run<O: ObserverType>(_ observer: O, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where O.E == S.E {
        let sink = MergeBasicSink<S, O>(observer: observer, cancel: cancel)
        let subscription = sink.run(_source)
        return (sink: sink, subscription: subscription)
    }
}
