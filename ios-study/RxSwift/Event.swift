//
//  Event.swift
//  ios-study
//
//  Created by soonhyung-imac on 19/04/2017.
//  Copyright © 2017 twentyhours. All rights reserved.
//

public enum Event<Element> {
    case next(Element)
    
    case error(Swift.Error)
    
    case completed
}
