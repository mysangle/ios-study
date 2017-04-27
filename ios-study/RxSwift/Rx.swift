//
//  Rx.swift
//  ios-study
//
//  Created by soonhyung-imac on 19/04/2017.
//  Copyright © 2017 twentyhours. All rights reserved.
//

#if TRACE_RESOURCES
    fileprivate var resourceCount: AtomicInt = 0
    
    /// Resource utilization information
    public struct Resources {
        /// Counts internal Rx resource allocations (Observables, Observers, Disposables, etc.). This provides a simple way to detect leaks during development.
        public static var total: Int32 {
            return resourceCount.valueSnapshot()
        }
        
        /// Increments `Resources.total` resource count.
        ///
        /// - returns: New resource count
        public static func incrementTotal() -> Int32 {
            return AtomicIncrement(&resourceCount)
        }
        
        /// Decrements `Resources.total` resource count
        ///
        /// - returns: New resource count
        public static func decrementTotal() -> Int32 {
            return AtomicDecrement(&resourceCount)
        }
    }
#endif

/// Swift는 abstract method를 지원하지 않는다.
/// 아래의 함수를 통해 서브클래스에서 구현해야 하는 함수의 런타임 체크를 한다.
/// 에러 메시지에 파일이름과 라인넘버를 표시한다.
func rxAbstractMethod(file: StaticString = #file, line: UInt = #line) -> Swift.Never {
    rxFatalError("Abstract method", file: file, line: line)
}

// autoclosure를 통해 lastMessage의 실제 실행이 delay되도록 한다.
func rxFatalError(_ lastMessage: @autoclosure () -> String, file: StaticString = #file, line: UInt = #line) -> Swift.Never  {
    // The temptation to comment this line is great, but please don't, it's for your own good. The choice is yours.
    fatalError(lastMessage(), file: file, line: line)
}
