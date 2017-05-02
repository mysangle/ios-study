//
//  RecursiveScheduler.swift
//  ios-study
//
//  Created by soonhyung-imac on 02/05/2017.
//  Copyright © 2017 twentyhours. All rights reserved.
//

fileprivate enum ScheduleState {
    case initial
    case added(CompositeDisposable.DisposeKey)
    case done
}

final class RecursiveImmediateScheduler<State> {
    typealias Action =  (_ state: State, _ recurse: (State) -> Void) -> Void
    
    private var _lock = SpinLock()
    private let _group = CompositeDisposable()
    
    private var _action: Action?
    private let _scheduler: ImmediateSchedulerType
    
    init(action: @escaping Action, scheduler: ImmediateSchedulerType) {
        _action = action
        _scheduler = scheduler
    }
    
    func schedule(_ state: State) {
        var scheduleState: ScheduleState = .initial
        
        let d = _scheduler.schedule(state) { (state) -> Disposable in
            // best effort
            if self._group.isDisposed {
                return Disposables.create()
            }
            
            let action = self._lock.calculateLocked { () -> Action? in
                switch scheduleState {
                case let .added(removeKey):
                    self._group.remove(for: removeKey)
                case .initial:
                    break
                case .done:
                    break
                }
                
                scheduleState = .done
                
                return self._action
            }
            
            if let action = action {
                action(state, self.schedule)
            }
            
            return Disposables.create()
        }
        
        _lock.performLocked {
            switch scheduleState {
            case .added:
                rxFatalError("Invalid state")
                break
            case .initial:
                if let removeKey = _group.insert(d) {
                    scheduleState = .added(removeKey)
                }
                else {
                    scheduleState = .done
                }
                break
            case .done:
                break
            }
        }
    }
    
    func dispose() {
        _lock.performLocked {
            _action = nil
        }
        _group.dispose()
    }
}
