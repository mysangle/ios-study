//
//  Rx.swift
//  ios-study
//
//  Created by soonhyung-imac on 19/04/2017.
//  Copyright © 2017 twentyhours. All rights reserved.
//

/// Swift는 abstract method를 지원하지 않는다.
/// 아래의 함수를 통해 서브클래스에서 구현해야 하는 함수의 런타임 체크를 한다.
/// 에러 메시지에 파일이름과 라인넘버를 표시한다.
func rxAbstractMethod(file: StaticString = #file, line: UInt = #line) -> Swift.Never {
    rxFatalError("Abstract method", file: file, line: line)
}

// autoclosure를 통해 lastMessage의 실제 실행이 delay되도록 한다.
func rxFatalError(_ lastMessage: @autoclosure () -> String, file: StaticString = #file, line: UInt = #line) -> Swift.Never  {
    // The temptation to comment this line is great, but please don't, it's for your own good. The choice is yours.
    fatalError(lastMessage(), file: file, line: line)
}
