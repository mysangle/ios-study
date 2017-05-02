//
//  SerialDispatchQueueScheduler.swift
//  ios-study
//
//  Created by soonhyung-imac on 02/05/2017.
//  Copyright © 2017 twentyhours. All rights reserved.
//

import Dispatch

public class SerialDispatchQueueScheduler : SchedulerType {
    // 스케줄을 delegate한다.
    let configuration: DispatchQueueConfiguration
    
    init(serialQueue: DispatchQueue, leeway: DispatchTimeInterval = DispatchTimeInterval.nanoseconds(0)) {
        configuration = DispatchQueueConfiguration(queue: serialQueue, leeway: leeway)
    }
    
    public convenience init(internalSerialQueueName: String, serialQueueConfiguration: ((DispatchQueue) -> Void)? = nil, leeway: DispatchTimeInterval = DispatchTimeInterval.nanoseconds(0)) {
        let queue = DispatchQueue(label: internalSerialQueueName, attributes: [])
        serialQueueConfiguration?(queue)
        self.init(serialQueue: queue, leeway: leeway)
    }
    
    public final func schedule<StateType>(_ state: StateType, action: @escaping (StateType) -> Disposable) -> Disposable {
        return self.scheduleInternal(state, action: action)
    }
    
    func scheduleInternal<StateType>(_ state: StateType, action: @escaping (StateType) -> Disposable) -> Disposable {
        return self.configuration.schedule(state, action: action)
    }
}
