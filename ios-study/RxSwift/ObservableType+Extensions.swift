//
//  ObservableType+Extensions.swift
//  ios-study
//
//  Created by soonhyung-imac on 27/04/2017.
//  Copyright © 2017 twentyhours. All rights reserved.
//

extension ObservableType {
    public func subscribe(file: String = #file, line: UInt = #line, function: String = #function, onNext: ((E) -> Void)? = nil, onError: ((Swift.Error) -> Void)? = nil, onCompleted: (() -> Void)? = nil, onDisposed: (() -> Void)? = nil)
        -> Disposable {
            
            // 사용자가 지정해준 onDisposed를 dispose시 실행하기 위한 disposable
            let disposable: Disposable
            
            if let disposed = onDisposed {
                disposable = Disposables.create(with: disposed)
            }
            else {
                disposable = Disposables.create()
            }
            
            let observer = AnonymousObserver<E> { e in
                switch e {
                case .next(let value):
                    onNext?(value)
                case .error(let e):
                    if let onError = onError {
                        onError(e)
                    }
                    else {
                        print("Received unhandled error: \(file):\(line):\(function) -> \(e)")
                    }
                    disposable.dispose()
                case .completed:
                    onCompleted?()
                    disposable.dispose()
                }
            }
            // BinaryDisposable: dispose시 observer를 dispose하는 것과
            // 사용자가 넣어준 onDisposed를 실행하는 것 두개를 실행해준다.
            return Disposables.create(
                self.subscribeSafe(observer),
                disposable
            )
    }
}

extension ObservableType {
    fileprivate func subscribeSafe<O: ObserverType>(_ observer: O) -> Disposable where O.E == E {
        return self.asObservable().subscribe(observer)
    }
}
