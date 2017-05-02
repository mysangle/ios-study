//
//  ObserveOn.swift
//  ios-study
//
//  Created by soonhyung-imac on 02/05/2017.
//  Copyright © 2017 twentyhours. All rights reserved.
//

extension ObservableType {
    public func observeOn(_ scheduler: ImmediateSchedulerType)
        -> Observable<E> {
            if let scheduler = scheduler as? SerialDispatchQueueScheduler {
                // 이벤트가 발생하면 바로바로 실행한다.
                return ObserveOnSerialDispatchQueue(source: self.asObservable(), scheduler: scheduler)
            }
            else {
                return ObserveOn(source: self.asObservable(), scheduler: scheduler)
            }
    }
}

enum ObserveOnState : Int32 {
    // pump is not running
    case stopped = 0
    // pump is running
    case running = 1
}

/// 이벤트가 발생하면 큐에 넣고 큐에 이벤트가 있으면 스케줄을 계속 반복한다.
final fileprivate class ObserveOn<E> : Producer<E> {
    let scheduler: ImmediateSchedulerType
    let source: Observable<E>
    
    init(source: Observable<E>, scheduler: ImmediateSchedulerType) {
        self.scheduler = scheduler
        self.source = source
        
#if TRACE_RESOURCES
        let _ = Resources.incrementTotal()
#endif
    }
    
    override func run<O : ObserverType>(_ observer: O, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where O.E == E {
        let sink = ObserveOnSink(scheduler: scheduler, observer: observer, cancel: cancel)
        let subscription = source.subscribe(sink)
        return (sink: sink, subscription: subscription)
    }
    
#if TRACE_RESOURCES
    deinit {
        let _ = Resources.decrementTotal()
    }
#endif
}

final fileprivate class ObserveOnSink<O: ObserverType> : ObserverBase<O.E> {
    typealias E = O.E
    
    let _scheduler: ImmediateSchedulerType
    
    var _lock = SpinLock()
    let _observer: O
    
    // 스케줄러가 동작중인지 아닌지를 파악한다.
    var _state = ObserveOnState.stopped
    // 이벤트를 저장하는 큐
    var _queue = Queue<Event<E>>(capacity: 10)
    
    let _scheduleDisposable = SerialDisposable()
    let _cancel: Cancelable
    
    init(scheduler: ImmediateSchedulerType, observer: O, cancel: Cancelable) {
        _scheduler = scheduler
        _observer = observer
        _cancel = cancel
    }
    
    override func onCore(_ event: Event<E>) {
        let shouldStart = _lock.calculateLocked { () -> Bool in
            self._queue.enqueue(event)
            
            switch self._state {
            case .stopped:
                self._state = .running
                return true
            case .running:
                return false
            }
        }
        
        if shouldStart {
            _scheduleDisposable.disposable = self._scheduler.scheduleRecursive((), action: self.run)
        }
    }
    
    /// 스케줄러에 의해 실행되는 함수
    func run(_ state: Void, recurse: (Void) -> Void) {
        let (nextEvent, observer) = self._lock.calculateLocked { () -> (Event<E>?, O) in
            if self._queue.count > 0 {
                return (self._queue.dequeue(), self._observer)
            }
            else {
                self._state = .stopped
                return (nil, self._observer)
            }
        }
        
        if let nextEvent = nextEvent, !_cancel.isDisposed {
            observer.on(nextEvent)
            if nextEvent.isStopEvent {
                dispose()
            }
        }
        else {
            return
        }
        
        let shouldContinue = _shouldContinue_synchronized()
        
        if shouldContinue {
            // 큐에 이벤트가 있으면 다시 스케줄을 실행한다.
            recurse()
        }
    }
    
    func _shouldContinue_synchronized() -> Bool {
        _lock.lock(); defer { _lock.unlock() } // {
        if self._queue.count > 0 {
            return true
        }
        else {
            self._state = .stopped
            return false
        }
        // }
    }
    
    override func dispose() {
        super.dispose()
        
        _cancel.dispose()
        _scheduleDisposable.dispose()
    }
}

#if TRACE_RESOURCES
    fileprivate var _numberOfSerialDispatchQueueObservables: AtomicInt = 0
    extension Resources {
        /**
         Counts number of `SerialDispatchQueueObservables`.
         
         Purposed for unit tests.
         */
        public static var numberOfSerialDispatchQueueObservables: Int32 {
            return _numberOfSerialDispatchQueueObservables.valueSnapshot()
        }
    }
#endif

final fileprivate class ObserveOnSerialDispatchQueueSink<O: ObserverType> : ObserverBase<O.E> {
    let scheduler: SerialDispatchQueueScheduler
    let observer: O
    
    let cancel: Cancelable
    
    var cachedScheduleLambda: ((ObserveOnSerialDispatchQueueSink<O>, Event<E>) -> Disposable)!
    
    init(scheduler: SerialDispatchQueueScheduler, observer: O, cancel: Cancelable) {
        self.scheduler = scheduler
        self.observer = observer
        self.cancel = cancel
        super.init()
        
        // 스케줄시 호출되는 closure
        cachedScheduleLambda = { sink, event in
            sink.observer.on(event)
            
            if event.isStopEvent {
                sink.dispose()
            }
            
            return Disposables.create()
        }
    }
    
    override func onCore(_ event: Event<E>) {
        let _ = self.scheduler.schedule((self, event), action: cachedScheduleLambda)
    }
    
    override func dispose() {
        super.dispose()
        
        cancel.dispose()
    }
}

final fileprivate class ObserveOnSerialDispatchQueue<E> : Producer<E> {
    let scheduler: SerialDispatchQueueScheduler
    let source: Observable<E>
    
    init(source: Observable<E>, scheduler: SerialDispatchQueueScheduler) {
        self.scheduler = scheduler
        self.source = source
        
#if TRACE_RESOURCES
        let _ = Resources.incrementTotal()
        let _ = AtomicIncrement(&_numberOfSerialDispatchQueueObservables)
#endif
    }
    
    override func run<O : ObserverType>(_ observer: O, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where O.E == E {
        let sink = ObserveOnSerialDispatchQueueSink(scheduler: scheduler, observer: observer, cancel: cancel)
        let subscription = source.subscribe(sink)
        return (sink: sink, subscription: subscription)
    }
    
#if TRACE_RESOURCES
    deinit {
        let _ = Resources.decrementTotal()
        let _ = AtomicDecrement(&_numberOfSerialDispatchQueueObservables)
    }
#endif
}
