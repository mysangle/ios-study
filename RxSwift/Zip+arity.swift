//
//  Zip+arity.swift
//  ios-study
//
//  Created by soonhyung-imac on 08/05/2017.
//  Copyright © 2017 twentyhours. All rights reserved.
//

/// zip과 combineLatest를 비교해보자.
/// zip은 두 소스에서 같은 순서에 발생한 이벤트끼리에 resultSelector를 적용하고,
/// combineLatest는 두 소스에서 가장 최근에 발생한 이벤트끼리에 resultSelector를 적용한다.
extension Observable {
    public static func zip<O1: ObservableType, O2: ObservableType>
        (_ source1: O1, _ source2: O2, resultSelector: @escaping (O1.E, O2.E) throws -> E)
        -> Observable<E> {
            return Zip2(
                source1: source1.asObservable(), source2: source2.asObservable(),
                resultSelector: resultSelector
            )
    }
}

final class ZipSink2_<E1, E2, O: ObserverType> : ZipSink<O> {
    typealias R = O.E
    typealias Parent = Zip2<E1, E2, R>
    
    let _parent: Parent
    
    var _values1: Queue<E1> = Queue(capacity: 2)
    var _values2: Queue<E2> = Queue(capacity: 2)
    
    init(parent: Parent, observer: O, cancel: Cancelable) {
        _parent = parent
        super.init(arity: 2, observer: observer, cancel: cancel)
    }
    
    /// _values1과 _values2가 값을 가지고 있는지 확인한다.
    override func hasElements(_ index: Int) -> Bool {
        switch (index) {
        case 0: return _values1.count > 0
        case 1: return _values2.count > 0
            
        default:
            rxFatalError("Unhandled case (Function)")
        }
        
        return false
    }
    
    func run() -> Disposable {
        let subscription1 = SingleAssignmentDisposable()
        let subscription2 = SingleAssignmentDisposable()
        
        let observer1 = ZipObserver(lock: _lock, parent: self, index: 0, setNextValue: { self._values1.enqueue($0) }, this: subscription1)
        let observer2 = ZipObserver(lock: _lock, parent: self, index: 1, setNextValue: { self._values2.enqueue($0) }, this: subscription2)
        
        subscription1.setDisposable(_parent.source1.subscribe(observer1))
        subscription2.setDisposable(_parent.source2.subscribe(observer2))
        
        return Disposables.create([
            subscription1,
            subscription2
            ])
    }
    
    /// observer에 내보내는 값
    override func getResult() throws -> R {
        return try _parent._resultSelector(_values1.dequeue()!, _values2.dequeue()!)
    }
}

final class Zip2<E1, E2, R> : Producer<R> {
    typealias ResultSelector = (E1, E2) throws -> R
    
    let source1: Observable<E1>
    let source2: Observable<E2>
    
    let _resultSelector: ResultSelector
    
    init(source1: Observable<E1>, source2: Observable<E2>, resultSelector: @escaping ResultSelector) {
        self.source1 = source1
        self.source2 = source2
        
        _resultSelector = resultSelector
    }
    
    override func run<O: ObserverType>(_ observer: O, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where O.E == R {
        let sink = ZipSink2_(parent: self, observer: observer, cancel: cancel)
        let subscription = sink.run()
        return (sink: sink, subscription: subscription)
    }
}
