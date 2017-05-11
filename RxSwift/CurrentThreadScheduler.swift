//
//  CurrentThreadScheduler.swift
//  ios-study
//
//  Created by soonhyung-imac on 26/04/2017.
//  Copyright © 2017 twentyhours. All rights reserved.
//

import class Foundation.NSObject
import protocol Foundation.NSCopying
import class Foundation.Thread
import Dispatch

fileprivate class CurrentThreadSchedulerQueueKey: NSObject, NSCopying {
    static let instance = CurrentThreadSchedulerQueueKey()
    private override init() {
        super.init()
    }
    
    override var hash: Int {
        return 0
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        return self
    }
}

/// 현재 쓰레드에서 스케줄을 한다.
/// CurrentThreadScheduler의 스케줄: 큐에 등록되어 있는 action을 바로 실행하는 스케줄
/// 현재 action이 동작중이면 추가되는 action은 queue에 넣는다.
/// queue에 넣어진 action은 현재 실행중이던 action이 다 끝나면
/// queue로부터 꺼내서 동작시킨다.
///
/// pthread를 사용하여 thread local storage를 설정한다.
public class CurrentThreadScheduler : ImmediateSchedulerType {
    // RxMutableBox는 class이고 Queue는 struct이다.
    typealias ScheduleQueue = RxMutableBox<Queue<ScheduledItemType>>
    
    public static let instance = CurrentThreadScheduler()
    
    private static var isScheduleRequiredKey: pthread_key_t = { () -> pthread_key_t in
        let key = UnsafeMutablePointer<pthread_key_t>.allocate(capacity: 1)
        // thread-specific data key를 생성한다.
        if pthread_key_create(key, nil) != 0 {
            rxFatalError("isScheduleRequired key creation failed")
        }
        
        return key.pointee
    }()
    
    // 현재 스케줄이 진행중임을 알려주는 값.
    // isScheduleRequired를 false로 설정하면 이 값이 isScheduleRequiredKey의 값으로 설정된다.
    private static var scheduleInProgressSentinel: UnsafeRawPointer = { () -> UnsafeRawPointer in
        return UnsafeRawPointer(UnsafeMutablePointer<Int>.allocate(capacity: 1))
    }()
    
    // setter의 default name인 newValue를 사용한다.
    // 큐는 ScheduledItemType을 아이템으로 가지고 있는다.
    static var queue : ScheduleQueue? {
        get {
            return Thread.getThreadLocalStorageValueForKey(CurrentThreadSchedulerQueueKey.instance)
        }
        set {
            Thread.setThreadLocalStorageValue(newValue, forKey: CurrentThreadSchedulerQueueKey.instance)
        }
    }
    
    // set에 fileprivate의 access level을 제공한다.
    // true로 설정하면 value는 nil이 된다.
    public static fileprivate(set) var isScheduleRequired: Bool {
        get {
            return pthread_getspecific(CurrentThreadScheduler.isScheduleRequiredKey) == nil
        }
        set(isScheduleRequired) {
            if pthread_setspecific(CurrentThreadScheduler.isScheduleRequiredKey, isScheduleRequired ? nil : scheduleInProgressSentinel) != 0 {
                rxFatalError("pthread_setspecific failed")
            }
        }
    }
    
    // action을 현재 쓰레드에서 바로 실행하도록 한다.
    // action < ScheduledItemType < ScheduleQueue
    public func schedule<StateType>(_ state: StateType, action: @escaping (StateType) -> Disposable) -> Disposable {
        if CurrentThreadScheduler.isScheduleRequired {
            // 큐에 있는 action을 실행한다.
            
            // action을 실행하는 동안은 스케줄이 되지 않도록 막는다.
            CurrentThreadScheduler.isScheduleRequired = false
            
            let disposable = action(state)
            
            defer {
                // action의 실행이 완료되면 이제는 스케줄이 될 수 있도록 한다.
                CurrentThreadScheduler.isScheduleRequired = true
                // 큐를 삭제한다.
                CurrentThreadScheduler.queue = nil
            }
            
            guard let queue = CurrentThreadScheduler.queue else {
                // 큐가 비어있으므로 그냥 리턴
                return disposable
            }
            
            // 큐에 있는 action을 실행한다.
            while let latest = queue.value.dequeue() {
                if latest.isDisposed {
                    // dispose되었으면 실행하지 않는다.
                    continue
                }
                latest.invoke()
            }
            
            return disposable
        }
        
        // 스케줄중인 경우에는 큐에 action을 넣어둔다.
        
        let existingQueue = CurrentThreadScheduler.queue
        
        let queue: RxMutableBox<Queue<ScheduledItemType>>
        if let existingQueue = existingQueue {
            queue = existingQueue
        } else {
            // 큐가 없으면 새로 만든다.
            queue = RxMutableBox(Queue<ScheduledItemType>(capacity: 1))
            CurrentThreadScheduler.queue = queue
        }
        
        // 스케줄되어야 하는 action을 가지고 있는 ScheduledItem을 큐에 넣는다.
        let scheduledItem = ScheduledItem(action: action, state: state)
        queue.value.enqueue(scheduledItem)
        
        return scheduledItem
    }
}
