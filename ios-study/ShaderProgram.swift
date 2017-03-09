//
//  ShaderProgram.swift
//  ios-study
//
//  Created by soonhyung-imac on 3/7/17.
//  Copyright © 2017 twentyhours. All rights reserved.
//

import OpenGLES
import Foundation

struct ShaderCompileError : Error {
    let compileLog:String
}

enum ShaderType {
    case vertex
    case fragment
}

public class ShaderProgram {
    let program:GLuint
    var vertexShader:GLuint! // At some point, the Swift compiler will be able to deal with the early throw and we can convert these to lets
    var fragmentShader:GLuint!
    
    public init(vertexShader:String, fragmentShader:String) throws {
        program = glCreateProgram()
        
        self.vertexShader = try compileShader(vertexShader, type:.vertex)
        self.fragmentShader = try compileShader(fragmentShader, type:.fragment)
        
        glAttachShader(program, self.vertexShader)
        glAttachShader(program, self.fragmentShader)
        
        try link()
    }
    
    public convenience init(vertexShader:String, fragmentShaderFile:URL) throws {
        try self.init(vertexShader:vertexShader, fragmentShader:try shaderFromFile(fragmentShaderFile))
    }
    
    public convenience init(vertexShaderFile:URL, fragmentShaderFile:URL) throws {
        try self.init(vertexShader:try shaderFromFile(vertexShaderFile), fragmentShader:try shaderFromFile(fragmentShaderFile))
    }
    
    deinit {
        debugPrint("Shader deallocated")
        
        if (vertexShader != nil) {
            glDeleteShader(vertexShader)
        }
        if (fragmentShader != nil) {
            glDeleteShader(fragmentShader)
        }
        glDeleteProgram(program)
    }
    
    func link() throws {
        glLinkProgram(program)
        
        var linkStatus:GLint = 0
        glGetProgramiv(program, GLenum(GL_LINK_STATUS), &linkStatus)
        if (linkStatus == 0) {
            var logLength:GLint = 0
            glGetProgramiv(program, GLenum(GL_INFO_LOG_LENGTH), &logLength)
            if (logLength > 0) {
                var compileLog = [CChar](repeating:0, count:Int(logLength))
                
                glGetProgramInfoLog(program, logLength, &logLength, &compileLog)
                print("Link log: \(String(cString:compileLog))")
            }
            
            throw ShaderCompileError(compileLog:"Link error")
        }
    }
}

func compileShader(_ shaderString: String, type: ShaderType) throws -> GLuint {
    let shaderHandle:GLuint
    switch type {
    case .vertex: shaderHandle = glCreateShader(GLenum(GL_VERTEX_SHADER))
    case .fragment: shaderHandle = glCreateShader(GLenum(GL_FRAGMENT_SHADER))
    }
    
    shaderString.withGLChar { glString in
        var tempString: UnsafePointer<GLchar>? = glString
        glShaderSource(shaderHandle, 1, &tempString, nil)
        glCompileShader(shaderHandle)
    }
    
    var compileStatus:GLint = 1
    glGetShaderiv(shaderHandle, GLenum(GL_COMPILE_STATUS), &compileStatus)
    if (compileStatus != 1) {
        var logLength:GLint = 0
        glGetShaderiv(shaderHandle, GLenum(GL_INFO_LOG_LENGTH), &logLength)
        if (logLength > 0) {
            var compileLog = [CChar](repeating:0, count:Int(logLength))
            
            glGetShaderInfoLog(shaderHandle, logLength, &logLength, &compileLog)
            print("Compile log: \(String(cString:compileLog))")
            // let compileLogString = String(bytes:compileLog.map{UInt8($0)}, encoding:NSASCIIStringEncoding)
            
            switch type {
            case .vertex: throw ShaderCompileError(compileLog:"Vertex shader compile error:")
            case .fragment: throw ShaderCompileError(compileLog:"Fragment shader compile error:")
            }
        }
    }
    
    return shaderHandle
}

public func crashOnShaderCompileFailure<T>(_ shaderName:String, _ operation:() throws -> T) -> T {
    do {
        return try operation()
    } catch {
        print("ERROR: \(shaderName) compilation failed with error: \(error)")
        fatalError("Aborting execution.")
    }
}

public func shaderFromFile(_ file:URL) throws -> String {
    // Note: this is a hack until Foundation's String initializers are fully functional
    //        let fragmentShaderString = String(contentsOfURL:fragmentShaderFile, encoding:NSASCIIStringEncoding)
    guard (FileManager.default.fileExists(atPath: file.path)) else { throw ShaderCompileError(compileLog:"Shader file \(file) missing")}
    
    let fragmentShaderString = try NSString(contentsOfFile:file.path, encoding:String.Encoding.ascii.rawValue)
    
    return String(describing:fragmentShaderString)
}
