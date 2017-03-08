//
//  Camera.swift
//  ios-study
//
//  Created by soonhyung-imac on 3/7/17.
//  Copyright © 2017 twentyhours. All rights reserved.
//

import Foundation
import AVFoundation

public enum PhysicalCameraLocation {
    case backFacing
    case frontFacing
    
    func imageOrientation() -> ImageOrientation {
        switch self {
        case .backFacing: return .landscapeRight
        case .frontFacing: return .landscapeLeft
        }
    }
    
    func captureDevicePosition() -> AVCaptureDevicePosition {
        switch self {
        case .backFacing: return .back
        case .frontFacing: return .front
        }
    }
    
    func device() -> AVCaptureDevice? {
        if let deviceDiscoverySession = AVCaptureDeviceDiscoverySession(deviceTypes: [AVCaptureDeviceType.builtInWideAngleCamera], mediaType: AVMediaTypeVideo, position: self.captureDevicePosition()) {
            return deviceDiscoverySession.devices[0]
        }
        return AVCaptureDevice.defaultDevice(withMediaType:AVMediaTypeVideo)
    }
}

struct CameraError: Error {
}

public class Camera : NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate {
    public var location: PhysicalCameraLocation {
        didSet {
            // TODO: Swap the camera locations, framebuffers as needed
        }
    }
    
    public let captureSession:AVCaptureSession
    
    var supportsFullYUVRange:Bool = false
    let captureAsYUV:Bool
    let inputCamera:AVCaptureDevice!
    let videoInput:AVCaptureDeviceInput!
    let videoOutput:AVCaptureVideoDataOutput!
    let yuvConversionShader:ShaderProgram?
    let cameraProcessingQueue = DispatchQueue.global(qos: .default)
    let audioProcessingQueue = DispatchQueue.global(qos: .default)
    
    public init(sessionPreset: String, cameraDevice: AVCaptureDevice? = nil, location: PhysicalCameraLocation = .backFacing, captureAsYUV: Bool = true) throws {
        self.location = location
        self.captureAsYUV = captureAsYUV
        
        self.captureSession = AVCaptureSession()
        self.captureSession.beginConfiguration()
        
        if let cameraDevice = cameraDevice {
            self.inputCamera = cameraDevice
        } else {
            if let device = location.device() {
                self.inputCamera = device
            } else {
                self.videoInput = nil
                self.videoOutput = nil
                self.yuvConversionShader = nil
                self.inputCamera = nil
                super.init()
                throw CameraError()
            }
        }
        do {
            self.videoInput = try AVCaptureDeviceInput(device:inputCamera)
        } catch {
            self.videoInput = nil
            self.videoOutput = nil
            self.yuvConversionShader = nil
            super.init()
            throw error
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        }
        
        videoOutput = AVCaptureVideoDataOutput()
        videoOutput.alwaysDiscardsLateVideoFrames = false
        
        if captureAsYUV {
            supportsFullYUVRange = false
            let supportedPixelFormats = videoOutput.availableVideoCVPixelFormatTypes
            for currentPixelFormat in supportedPixelFormats! {
                if ((currentPixelFormat as! NSNumber).int32Value == Int32(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)) {
                    supportsFullYUVRange = true
                }
            }
            
            if (supportsFullYUVRange) {
                yuvConversionShader = crashOnShaderCompileFailure("Camera"){try sharedImageProcessingContext.programForVertexShader(defaultVertexShaderForInputs(2), fragmentShader:YUVConversionFullRangeFragmentShader)}
                videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable:NSNumber(value:Int32(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange))]
            } else {
                yuvConversionShader = crashOnShaderCompileFailure("Camera"){try sharedImageProcessingContext.programForVertexShader(defaultVertexShaderForInputs(2), fragmentShader:YUVConversionVideoRangeFragmentShader)}
                videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable:NSNumber(value:Int32(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange))]
            }
        } else {
            yuvConversionShader = nil
            videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable:NSNumber(value:Int32(kCVPixelFormatType_32BGRA))]
        }

        if (captureSession.canAddOutput(videoOutput)) {
            captureSession.addOutput(videoOutput)
        }
        
        captureSession.commitConfiguration()
        
        super.init()
        
        videoOutput.setSampleBufferDelegate(self, queue:cameraProcessingQueue)
    }
    
    public func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        
    }
}
