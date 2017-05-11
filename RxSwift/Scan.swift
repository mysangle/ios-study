//
//  Scan.swift
//  ios-study
//
//  Created by soonhyung-imac on 08/05/2017.
//  Copyright © 2017 twentyhours. All rights reserved.
//

extension ObservableType {
    /// 이벤트가 발생하면 accumulator에 이벤트의 element와 _accumulate를 적용하여 나온 값을
    /// 발생시킨다. 발생시킨 값이 다음번 이벤트 발생시의 _accumulate값이 된다.
    /// 제일 처음의 _accumulate값은 seed이다.
    public func scan<A>(_ seed: A, accumulator: @escaping (A, E) throws -> A)
        -> Observable<A> {
            return Scan(source: self.asObservable(), seed: seed, accumulator: accumulator)
    }
}

final fileprivate class ScanSink<ElementType, O: ObserverType> : Sink<O>, ObserverType {
    typealias Accumulate = O.E
    typealias Parent = Scan<ElementType, Accumulate>
    typealias E = ElementType
    
    fileprivate let _parent: Parent
    fileprivate var _accumulate: Accumulate
    
    init(parent: Parent, observer: O, cancel: Cancelable) {
        _parent = parent
        _accumulate = parent._seed
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(_ event: Event<ElementType>) {
        switch event {
        case .next(let element):
            do {
                _accumulate = try _parent._accumulator(_accumulate, element)
                forwardOn(.next(_accumulate))
            }
            catch let error {
                forwardOn(.error(error))
                dispose()
            }
        case .error(let error):
            forwardOn(.error(error))
            dispose()
        case .completed:
            forwardOn(.completed)
            dispose()
        }
    }
}

final fileprivate class Scan<Element, Accumulate>: Producer<Accumulate> {
    typealias Accumulator = (Accumulate, Element) throws -> Accumulate
    
    fileprivate let _source: Observable<Element>
    fileprivate let _seed: Accumulate
    fileprivate let _accumulator: Accumulator
    
    init(source: Observable<Element>, seed: Accumulate, accumulator: @escaping Accumulator) {
        _source = source
        _seed = seed
        _accumulator = accumulator
    }
    
    override func run<O : ObserverType>(_ observer: O, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where O.E == Accumulate {
        let sink = ScanSink(parent: self, observer: observer, cancel: cancel)
        let subscription = _source.subscribe(sink)
        return (sink: sink, subscription: subscription)
    }
}
