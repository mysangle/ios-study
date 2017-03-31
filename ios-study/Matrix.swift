//
//  Matrix.swift
//  ios-study
//
//  Created by soonhyung-imac on 3/23/17.
//  Copyright © 2017 twentyhours. All rights reserved.
//

import QuartzCore

public struct Matrix4x4 {
    public let m11:Float, m12:Float, m13:Float, m14:Float
    public let m21:Float, m22:Float, m23:Float, m24:Float
    public let m31:Float, m32:Float, m33:Float, m34:Float
    public let m41:Float, m42:Float, m43:Float, m44:Float
    
    public init(rowMajorValues:[Float]) {
        guard rowMajorValues.count > 15 else {
            fatalError("Tried to initialize a 4x4 matrix with fewer than 16 values")
        }
        
        self.m11 = rowMajorValues[0]
        self.m12 = rowMajorValues[1]
        self.m13 = rowMajorValues[2]
        self.m14 = rowMajorValues[3]
        
        self.m21 = rowMajorValues[4]
        self.m22 = rowMajorValues[5]
        self.m23 = rowMajorValues[6]
        self.m24 = rowMajorValues[7]
        
        self.m31 = rowMajorValues[8]
        self.m32 = rowMajorValues[9]
        self.m33 = rowMajorValues[10]
        self.m34 = rowMajorValues[11]
        
        self.m41 = rowMajorValues[12]
        self.m42 = rowMajorValues[13]
        self.m43 = rowMajorValues[14]
        self.m44 = rowMajorValues[15]
    }
    
    public static let identity = Matrix4x4(rowMajorValues:[1.0, 0.0, 0.0, 0.0,
                                                           0.0, 1.0, 0.0, 0.0,
                                                           0.0, 0.0, 1.0, 0.0,
                                                           0.0, 0.0, 0.0, 1.0])
}

public struct Matrix3x3 {
    public let m11: Float, m12: Float, m13: Float
    public let m21: Float, m22: Float, m23: Float
    public let m31: Float, m32: Float, m33: Float
    
    public init(rowMajorValues: [Float]) {
        guard rowMajorValues.count > 8 else {
            fatalError("Tried to initialize a 3x3 matrix with fewer than 9 values")
        }
        
        self.m11 = rowMajorValues[0]
        self.m12 = rowMajorValues[1]
        self.m13 = rowMajorValues[2]
        
        self.m21 = rowMajorValues[3]
        self.m22 = rowMajorValues[4]
        self.m23 = rowMajorValues[5]
        
        self.m31 = rowMajorValues[6]
        self.m32 = rowMajorValues[7]
        self.m33 = rowMajorValues[8]
    }
    
    public static let identity = Matrix3x3(rowMajorValues:[1.0, 0.0, 0.0,
                                                           0.0, 1.0, 0.0,
                                                           0.0, 0.0, 1.0])
    
    public static let centerOnly = Matrix3x3(rowMajorValues:[0.0, 0.0, 0.0,
                                                             0.0, 1.0, 0.0,
                                                             0.0, 0.0, 0.0])
}
