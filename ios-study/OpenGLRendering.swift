//
//  OpenGLRendering.swift
//  ios-study
//
//  Created by soonhyung-imac on 3/9/17.
//  Copyright © 2017 twentyhours. All rights reserved.
//

import OpenGLES
import Foundation

extension String {
    func withGLChar(_ operation:(UnsafePointer<GLchar>) -> ()) {
        if let value = self.cString(using:String.Encoding.utf8) {
            operation(UnsafePointer<GLchar>(value))
        } else {
            fatalError("Could not convert this string to UTF8: \(self)")
        }
    }
}
