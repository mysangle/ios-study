//
//  CurrentThreadSchedulerTest.swift
//  ios-study
//
//  Created by soonhyung-imac on 11/05/2017.
//  Copyright © 2017 twentyhours. All rights reserved.
//

import RxSwift
import XCTest

class CurrentThreadSchedulerTest: RxTest {
    func testCurrentThreadScheduler_scheduleRequired() {
        
        XCTAssertTrue(CurrentThreadScheduler.isScheduleRequired)

        var executed = false
        // isScheduleRequired가 true이면 action은 바로 실행된다.
        _ = CurrentThreadScheduler.instance.schedule(()) { s in
            executed = true
            XCTAssertTrue(!CurrentThreadScheduler.isScheduleRequired)
            return Disposables.create()
        }
        
        XCTAssertTrue(executed)
    }
    
    func testCurrentThreadScheduler_basicScenario() {
        
        XCTAssertTrue(CurrentThreadScheduler.isScheduleRequired)
        
        var messages = [Int]()
        _ = CurrentThreadScheduler.instance.schedule(()) { s in
            messages.append(1)
            _ = CurrentThreadScheduler.instance.schedule(()) { s in
                // 첫번째 action이 끝나면 실행된다.
                messages.append(3)
                _ = CurrentThreadScheduler.instance.schedule(()) {
                    // 두번째 action이 끝나면 실행된다.
                    messages.append(5)
                    return Disposables.create()
                }
                messages.append(4)
                return Disposables.create()
            }
            messages.append(2)
            return Disposables.create()
        }
        
        XCTAssertEqual(messages, [1, 2, 3, 4, 5])
    }
    
    func testCurrentThreadScheduler_disposing1() {
        
        XCTAssertTrue(CurrentThreadScheduler.isScheduleRequired)
        
        var messages = [Int]()
        _ = CurrentThreadScheduler.instance.schedule(()) { s in
            messages.append(1)
            let disposable = CurrentThreadScheduler.instance.schedule(()) { s in
                messages.append(3)
                let disposable = CurrentThreadScheduler.instance.schedule(()) {
                    messages.append(5)
                    return Disposables.create()
                }
                // 여기서 dispose하므로 바로 위의 action은 불리지 않는다.
                disposable.dispose()
                messages.append(4)
                return disposable
            }
            messages.append(2)
            return disposable
        }
        
        XCTAssertEqual(messages, [1, 2, 3, 4])
    }
    
    func testCurrentThreadScheduler_disposing2() {
        
        XCTAssertTrue(CurrentThreadScheduler.isScheduleRequired)
        
        var messages = [Int]()
        _ = CurrentThreadScheduler.instance.schedule(()) { s in
            messages.append(1)
            let disposable = CurrentThreadScheduler.instance.schedule(()) { s in
                messages.append(3)
                let disposable = CurrentThreadScheduler.instance.schedule(()) {
                    messages.append(5)
                    return Disposables.create()
                }
                messages.append(4)
                return disposable
            }
            // 여기서 dispose하므로 바로 위의 action은 불리지 않는다.
            disposable.dispose()
            messages.append(2)
            return disposable
        }
        
        XCTAssertEqual(messages, [1, 2])
    }
}
