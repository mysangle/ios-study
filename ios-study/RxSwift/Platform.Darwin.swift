//
//  Platform.Darwin.swift
//  ios-study
//
//  Created by soonhyung-imac on 26/04/2017.
//  Copyright © 2017 twentyhours. All rights reserved.
//

import class Foundation.Thread
import protocol Foundation.NSCopying

/// Any can represent an instance of any type at all, including function types.
/// AnyObject can represent an instance of any class type.
extension Thread {
    // 현재 쓰레드에 key:value 설정
    static func setThreadLocalStorageValue<T: AnyObject>(_ value: T?, forKey key: NSCopying
        ) {
        let currentThread = Thread.current
        let threadDictionary = currentThread.threadDictionary
        
        if let newValue = value {
            threadDictionary[key] = newValue
        }
        else {
            threadDictionary[key] = nil
        }
        
    }
    
    // 현재 쓰레드에서 key에 맞는 값을 가져온다.
    static func getThreadLocalStorageValueForKey<T>(_ key: NSCopying) -> T? {
        let currentThread = Thread.current
        let threadDictionary = currentThread.threadDictionary
        
        return threadDictionary[key] as? T
    }
}
