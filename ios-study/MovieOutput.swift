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
