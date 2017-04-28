//
//  Bag+Rx.swift
//  ios-study
//
//  Created by soonhyung-imac on 28/04/2017.
//  Copyright © 2017 twentyhours. All rights reserved.
//

/// Bag안의 모든 아이템에 대해 dispose() 적용
func disposeAll(in bag: Bag<Disposable>) {
    if bag._onlyFastPath {
        bag._value0?.dispose()
        return
    }
    
    let value0 = bag._value0
    let dictionary = bag._dictionary
    
    if let value0 = value0 {
        value0.dispose()
    }
    
    let pairs = bag._pairs
    for i in 0 ..< pairs.count {
        pairs[i].value.dispose()
    }
    
    if let dictionary = dictionary {
        for element in dictionary.values {
            element.dispose()
        }
    }
}
