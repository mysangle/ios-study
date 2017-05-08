//
//  Position.swift
//  ios-study
//
//  Created by soonhyung-imac on 3/23/17.
//  Copyright © 2017 twentyhours. All rights reserved.
//

import Foundation
import UIKit

public struct Position {
    public let x:Float
    public let y:Float
    public let z:Float?
    
    public init (_ x: Float, _ y: Float, _ z: Float? = nil) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    #if !os(Linux)
    public init(point: CGPoint) {
        self.x = Float(point.x)
        self.y = Float(point.y)
        self.z = nil
    }
    #endif
    
    public static let center = Position(0.5, 0.5)
    public static let zero = Position(0.0, 0.0)
}
