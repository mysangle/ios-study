//
//  OpenGLContext.swift
//  ios-study
//
//  Created by soonhyung-imac on 3/9/17.
//  Copyright © 2017 twentyhours. All rights reserved.
//

import OpenGLES
import UIKit

var imageProcessingShareGroup:EAGLSharegroup? = nil

public class OpenGLContext : SerialDispatch {
    var shaderCache: [String:ShaderProgram] = [:]
    
    let context: EAGLContext
    
    public let serialDispatchQueue: DispatchQueue = DispatchQueue(label:"com.sunsetlakesoftware.GPUImage.processingQueue", attributes: [])
    public let dispatchQueueKey = DispatchSpecificKey<Int>()
    
    init() {
        serialDispatchQueue.setSpecific(key:dispatchQueueKey, value:81)
        
        guard let generatedContext = EAGLContext(api: .openGLES2, sharegroup: imageProcessingShareGroup) else {
            fatalError("Unable to create an OpenGL ES 2.0 context. The GPUImage framework requires OpenGL ES 2.0 support to work.")
        }
        
        self.context = generatedContext
        self.makeCurrentContext()
        
        glDisable(GLenum(GL_DEPTH_TEST))
        glEnable(GLenum(GL_TEXTURE_2D))
    }
    
    public func makeCurrentContext() {
        if (EAGLContext.current() != self.context)
        {
            EAGLContext.setCurrent(self.context)
        }
    }
}
