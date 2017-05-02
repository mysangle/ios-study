//
//  DispatchQueueConfiguration.swift
//  ios-study
//
//  Created by soonhyung-imac on 02/05/2017.
//  Copyright © 2017 twentyhours. All rights reserved.
//

import Dispatch

struct DispatchQueueConfiguration {
    let queue: DispatchQueue
    let leeway: DispatchTimeInterval
}

extension DispatchQueueConfiguration {
    func schedule<StateType>(_ state: StateType, action: @escaping (StateType) -> Disposable) -> Disposable {
        let cancel = SingleAssignmentDisposable()
        
        // 지정한 queue에서 async로 action을 동작한다.
        queue.async {
            if cancel.isDisposed {
                return
            }
            
            
            cancel.setDisposable(action(state))
        }
        
        return cancel
    }
}
