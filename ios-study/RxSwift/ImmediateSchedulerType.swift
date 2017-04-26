//
//  ImmediateSchedulerType.swift
//  ios-study
//
//  Created by soonhyung-imac on 26/04/2017.
//  Copyright © 2017 twentyhours. All rights reserved.
//

public protocol ImmediateSchedulerType {
    // Schedules an action to be executed immediatelly.
    func schedule<StateType>(_ state: StateType, action: @escaping (StateType) -> Disposable) -> Disposable
}
