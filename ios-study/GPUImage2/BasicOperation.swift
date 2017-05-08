//
//  BasicOperation.swift
//  ios-study
//
//  Created by soonhyung-imac on 3/9/17.
//  Copyright © 2017 twentyhours. All rights reserved.
//

import Foundation

public func defaultVertexShaderForInputs(_ inputCount:UInt) -> String {
    switch inputCount {
    case 1: return OneInputVertexShader
    case 2: return TwoInputVertexShader
    case 3: return ThreeInputVertexShader
    case 4: return FourInputVertexShader
    case 5: return FiveInputVertexShader
    default: return OneInputVertexShader
    }
}
