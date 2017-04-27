//
//  DisposeBase.swift
//  ios-study
//
//  Created by soonhyung-imac on 27/04/2017.
//  Copyright © 2017 twentyhours. All rights reserved.
//

public class DisposeBase {
    init() {
#if TRACE_RESOURCES
        let _ = Resources.incrementTotal()
#endif
    }
    
    deinit {
#if TRACE_RESOURCES
        let _ = Resources.decrementTotal()
#endif
    }
}
