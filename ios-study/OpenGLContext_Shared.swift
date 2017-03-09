//
//  OpenGLContext_Shared.swift
//  ios-study
//
//  Created by soonhyung-imac on 3/9/17.
//  Copyright © 2017 twentyhours. All rights reserved.
//

import Foundation

public let sharedImageProcessingContext = OpenGLContext()

extension OpenGLContext {
    public func programForVertexShader(_ vertexShader:String, fragmentShader:String) throws -> ShaderProgram {
        let lookupKeyForShaderProgram = "V: \(vertexShader) - F: \(fragmentShader)"
        if let shaderFromCache = shaderCache[lookupKeyForShaderProgram] {
            return shaderFromCache
        } else {
            return try sharedImageProcessingContext.runOperationSynchronously {
                let program = try ShaderProgram(vertexShader:vertexShader, fragmentShader:fragmentShader)
                self.shaderCache[lookupKeyForShaderProgram] = program
                return program
            }
        }
    }
}
