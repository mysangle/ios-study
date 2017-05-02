//
//  ImmediateSchedulerType.swift
//  ios-study
//
//  Created by soonhyung-imac on 26/04/2017.
//  Copyright © 2017 twentyhours. All rights reserved.
//

public protocol ImmediateSchedulerType {
    // schedule an action to be executed immediatelly.
    func schedule<StateType>(_ state: StateType, action: @escaping (StateType) -> Disposable) -> Disposable
}

extension ImmediateSchedulerType {
    // schedule an action to be executed recursively.
    public func scheduleRecursive<State>(_ state: State, action: @escaping (_ state: State, _ recurse: (State) -> ()) -> ()) -> Disposable {
        let recursiveScheduler = RecursiveImmediateScheduler(action: action, scheduler: self)
        
        recursiveScheduler.schedule(state)
        
        return Disposables.create(with: recursiveScheduler.dispose)
    }
}
