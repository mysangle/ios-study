//
//  CombineLatest.swift
//  ios-study
//
//  Created by soonhyung-imac on 28/04/2017.
//  Copyright © 2017 twentyhours. All rights reserved.
//

protocol CombineLatestProtocol : class {
    func next(_ index: Int)
    func fail(_ error: Swift.Error)
    func done(_ index: Int)
}

class CombineLatestSink<O: ObserverType>
    : Sink<O>
, CombineLatestProtocol {
    typealias Element = O.E
    
    let _lock = RecursiveLock()
    
    private let _arity: Int // observable의 개수
    private var _numberOfValues = 0
    private var _numberOfDone = 0
    // 개개의 observable이 값을 가지고 있는지 여부
    private var _hasValue: [Bool]
    // 개개의 observable이 completed되었는지 여부
    private var _isDone: [Bool]

    init(arity: Int, observer: O, cancel: Cancelable) {
        _arity = arity
        _hasValue = [Bool](repeating: false, count: arity)
        _isDone = [Bool](repeating: false, count: arity)
        
        super.init(observer: observer, cancel: cancel)
    }
    
    /// abstract
    func getResult() throws -> Element {
        rxAbstractMethod()
    }
    
    func next(_ index: Int) {
        if !_hasValue[index] {
            _hasValue[index] = true
            _numberOfValues += 1
        }
        
        if _numberOfValues == _arity {
            // 모든 observable이 값을 가지고 있다.
            do {
                // ResultSelector의 사용
                let result = try getResult()
                forwardOn(.next(result))
            } catch let e {
                forwardOn(.error(e))
                dispose()
            }
        } else {
            // index의 observable을 제외한 모든 observable이 completed이면
            // 끝낸다. -> 다른 observable로부터 더이상 값이 오지 않을 것이기 때문에
            // (_numberOfValues == _arity) 가 불가능해지므로...
            
            var allOthersDone = true
            
            for i in 0 ..< _arity {
                if i != index && !_isDone[i] {
                    // 아직 안끝난 observable이 있다.
                    allOthersDone = false
                    break
                }
            }
            
            if allOthersDone {
                forwardOn(.completed)
                dispose()
            }
        }
    }
    
    func fail(_ error: Swift.Error) {
        forwardOn(.error(error))
        dispose()
    }
    
    /// index: 몇번째 observable로부터 온 값인가
    func done(_ index: Int) {
        if _isDone[index] {
            return
        }
        
        _isDone[index] = true
        _numberOfDone += 1
        
        if _numberOfDone == _arity {
            // 모든 observable이 completed이면 끝낸다.
            forwardOn(.completed)
            dispose()
        }
    }
}

final class CombineLatestObserver<ElementType>
    : ObserverType
    , LockOwnerType
    , SynchronizedOnType {
    typealias Element = ElementType
    typealias ValueSetter = (Element) -> Void
    
    private let _parent: CombineLatestProtocol
    
    let _lock: RecursiveLock
    private let _index: Int
    private let _this: Disposable
    private let _setLatestValue: ValueSetter
    
    init(lock: RecursiveLock, parent: CombineLatestProtocol, index: Int, setLatestValue: @escaping ValueSetter, this: Disposable) {
        _lock = lock
        _parent = parent
        _index = index
        _this = this
        _setLatestValue = setLatestValue
    }
    
    func on(_ event: Event<Element>) {
        synchronizedOn(event)
    }
    
    /// lock에 의해 보호된다: 여러 observable로부터 이벤트가 발생할 때
    /// 한번에 하나씩만 실행되도록 한다.
    func _synchronized_on(_ event: Event<Element>) {
        switch event {
        case .next(let value):
            _setLatestValue(value)
            _parent.next(_index)
        case .error(let error):
            _this.dispose()
            _parent.fail(error)
        case .completed:
            _this.dispose()
            _parent.done(_index)
        }
    }
}
