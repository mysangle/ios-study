//
//  Queue.swift
//  ios-study
//
//  Created by soonhyung-imac on 26/04/2017.
//  Copyright © 2017 twentyhours. All rights reserved.
//

/// 내부의 array에 아이템을 저장하고, enqueue/dequeue로 넣고 뺀다.
///
/// 스토리지를 circular queue의 형태로 사용하다 꽉 차면 크기를 늘린다.
///
/// makeIterator()가 Queue와 상관없이 동작하도록 하기 위해 Queue는 struct여야한다.
/// 만약 Queue가 class라면 iterator가 동작하는 동안 Queue가 변경되면 iterator의 내용도
/// 같이 변경된다.
struct Queue<T> : Sequence {
    typealias Generator = AnyIterator<T>
    private let _resizeFactor = 2
    // ContiguousArray는 T가 class이거나 @objc protocol인 경우에 효율적이다.
    private var _storage: ContiguousArray<T?>
    private var _count = 0
    // 아이템을 넣을 위치
    private var _pushNextIndex = 0
    private let _initialCapacity: Int
    
    init(capacity: Int) {
        _initialCapacity = capacity
        
        _storage = ContiguousArray<T?>(repeating: nil, count: capacity)
    }
    
    // dequeue할 아이템의 위치
    private var dequeueIndex: Int {
        let index = _pushNextIndex - count
        return index < 0 ? index + _storage.count : index
    }
    
    // 큐가 비어있는가?
    var isEmpty: Bool {
        return count == 0
    }
    
    // 큐에 있는 아이템의 수
    var count: Int {
        return _count
    }
    
    // 새 스토리지를 만들고 이전 것을 새 것에 복사한다.
    mutating private func resizeTo(_ size: Int) {
        var newStorage = ContiguousArray<T?>(repeating: nil, count: size)
        
        let count = _count
        
        let dequeueIndex = self.dequeueIndex
        let spaceToEndOfQueue = _storage.count - dequeueIndex
        
        // first batch is from dequeue index to end of array
        let countElementsInFirstBatch = Swift.min(count, spaceToEndOfQueue)
        // second batch is wrapped from start of array to end of queue
        let numberOfElementsInSecondBatch = count - countElementsInFirstBatch
        
        newStorage[0 ..< countElementsInFirstBatch] = _storage[dequeueIndex ..< (dequeueIndex + countElementsInFirstBatch)]
        newStorage[countElementsInFirstBatch ..< (countElementsInFirstBatch + numberOfElementsInSecondBatch)] = _storage[0 ..< numberOfElementsInSecondBatch]
        
        _count = count
        _pushNextIndex = count
        _storage = newStorage
    }
    
    mutating func enqueue(_ element: T) {
        if count == _storage.count {
            resizeTo(Swift.max(_storage.count, 1) * _resizeFactor)
        }
        
        _storage[_pushNextIndex] = element
        _pushNextIndex += 1
        _count += 1
        
        if _pushNextIndex >= _storage.count {
            // 스토리지가 다 찬 경우 0으로 간다.
            _pushNextIndex -= _storage.count
        }
    }
    
    private mutating func dequeueElementOnly() -> T {
        precondition(count > 0)
        
        let index = dequeueIndex
        
        defer {
            _storage[index] = nil
            _count -= 1
        }
        
        return _storage[index]!
    }
    
    mutating func dequeue() -> T? {
        if self.count == 0 {
            return nil
        }
        
        defer {
            let downsizeLimit = _storage.count / (_resizeFactor * _resizeFactor)
            if _count < downsizeLimit && downsizeLimit >= _initialCapacity {
                // 스토리지 크기를 줄인다.
                resizeTo(_storage.count / _resizeFactor)
            }
        }
        
        return dequeueElementOnly()
    }
    
    func makeIterator() -> AnyIterator<T> {
        var i = dequeueIndex
        var count = _count
        
        return AnyIterator {
            if count == 0 {
                return nil
            }
            
            defer {
                count -= 1
                i += 1
            }
            
            if i >= self._storage.count {
                i -= self._storage.count
            }
            
            return self._storage[i]
        }
    }
}
