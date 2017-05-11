//
//  Observable+MergeTest.swift
//  ios-study
//
//  Created by soonhyung-imac on 11/05/2017.
//  Copyright © 2017 twentyhours. All rights reserved.
//

import RxSwift
import XCTest

class ObservableMergeTest: RxTest {
    
}

extension ObservableMergeTest {
    func testMerge_DeadlockSimple() {
        var nEvents = 0
        
        let observable = Observable.of(
            Observable.of(0, 1, 2),
            Observable.of(0, 1, 2),
            Observable.of(0, 1, 2)
            ).merge()
        
        _ = observable.subscribe(onNext: { n in
            nEvents += 1
        })
        
        XCTAssertEqual(nEvents, 9)
    }

}
