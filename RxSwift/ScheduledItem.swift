//
//  ScheduledItem.swift
//  ios-study
//
//  Created by soonhyung-imac on 26/04/2017.
//  Copyright © 2017 twentyhours. All rights reserved.
//

/// 내부에 action을 들고 있다가 invoke시 action을 실행한다.
/// dispose()가 호출되면 action의 리턴인 disposable의 dispose()가 호출되게 된다.
struct ScheduledItem<T> : ScheduledItemType {
    typealias Action = (T) -> Disposable
    
    private let _action: Action
    private let _state: T
    
    private let _disposable = SingleAssignmentDisposable()
    
    // Cancelable
    var isDisposed: Bool {
        return _disposable.isDisposed
    }
    
    init(action: @escaping Action, state: T) {
        _action = action
        _state = state
    }
    
    // InvocableType
    func invoke() {
        _disposable.setDisposable(_action(_state))
    }
    
    // Disposable
    func dispose() {
        _disposable.dispose()
    }
}
