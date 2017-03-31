//
//  MovieOutput.swift
//  ios-study
//
//  Created by soonhyung-imac on 3/15/17.
//  Copyright © 2017 twentyhours. All rights reserved.
//

import AVFoundation

public protocol AudioEncodingTarget {
    func activateAudioTrack()
    func processAudioBuffer(_ sampleBuffer:CMSampleBuffer)
}

public extension Timestamp {
    public init(_ time:CMTime) {
        self.value = time.value
        self.timescale = time.timescale
        self.flags = TimestampFlags(rawValue: time.flags.rawValue)
        self.epoch = time.epoch
    }
    
    public var asCMTime:CMTime {
        get {
            return CMTimeMakeWithEpoch(value, timescale, epoch)
        }
    }
}
