//
//  ScheduledItemType.swift
//  ios-study
//
//  Created by soonhyung-imac on 26/04/2017.
//  Copyright © 2017 twentyhours. All rights reserved.
//

protocol ScheduledItemType
    : Cancelable
    , InvocableType {
    func invoke()
}
