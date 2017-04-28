//
//  CombineLatest+arity.swift
//  ios-study
//
//  Created by soonhyung-imac on 28/04/2017.
//  Copyright © 2017 twentyhours. All rights reserved.
//

extension Observable {
    public static func combineLatest<O1: ObservableType, O2: ObservableType>
        (_ source1: O1, _ source2: O2, resultSelector: @escaping (O1.E, O2.E) throws -> E)
        -> Observable<E> {
            return CombineLatest2(
                source1: source1.asObservable(), source2: source2.asObservable(),
                resultSelector: resultSelector
            )
    }
}

final class CombineLatestSink2_<E1, E2, O: ObserverType> : CombineLatestSink<O> {
    typealias R = O.E
    typealias Parent = CombineLatest2<E1, E2, R>
    
    let _parent: Parent
    
    var _latestElement1: E1! = nil
    var _latestElement2: E2! = nil
    
    init(parent: Parent, observer: O, cancel: Cancelable) {
        _parent = parent
        super.init(arity: 2, observer: observer, cancel: cancel)
    }
    
    /// _lock은 CombineLatestSink에 선언되어 있음.
    func run() -> Disposable {
        let subscription1 = SingleAssignmentDisposable()
        let subscription2 = SingleAssignmentDisposable()
        
        // 원래의 observable로부터 온 값을 _latestElement1에 저장한다.
        let observer1 = CombineLatestObserver(lock: _lock, parent: self, index: 0, setLatestValue: { (e: E1) -> Void in self._latestElement1 = e }, this: subscription1)
        // 원래의 observable로부터 온 값을 _latestElement2에 저장한다.
        let observer2 = CombineLatestObserver(lock: _lock, parent: self, index: 1, setLatestValue: { (e: E2) -> Void in self._latestElement2 = e }, this: subscription2)
        
        subscription1.setDisposable(_parent._source1.subscribe(observer1))
        subscription2.setDisposable(_parent._source2.subscribe(observer2))
        
        return Disposables.create([
            subscription1,
            subscription2
            ])
    }
    
    override func getResult() throws -> R {
        return try _parent._resultSelector(_latestElement1, _latestElement2)
    }
}

/// observable 두개로부터 최신 아이템을 뽑아낸다.
final class CombineLatest2<E1, E2, R> : Producer<R> {
    typealias ResultSelector = (E1, E2) throws -> R
    
    let _source1: Observable<E1>
    let _source2: Observable<E2>
    
    let _resultSelector: ResultSelector
    
    init(source1: Observable<E1>, source2: Observable<E2>, resultSelector: @escaping ResultSelector) {
        _source1 = source1
        _source2 = source2
        
        _resultSelector = resultSelector
    }
    
    override func run<O: ObserverType>(_ observer: O, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where O.E == R {
        let sink = CombineLatestSink2_(parent: self, observer: observer, cancel: cancel)
        let subscription = sink.run()
        return (sink: sink, subscription: subscription)
    }
}
