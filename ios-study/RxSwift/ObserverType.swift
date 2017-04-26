//
//  ObserverType.swift
//  ios-study
//
//  Created by soonhyung-imac on 19/04/2017.
//  Copyright © 2017 twentyhours. All rights reserved.
//

public protocol ObserverType {
    associatedtype E
    
    func on(_ event: Event<E>)
}
