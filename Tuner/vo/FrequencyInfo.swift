//
//  FrequencyInfo.swift
//  Tuner
//
//  Created by yoonbumtae on 2021/08/01.
//

import Foundation

struct FrequencyInfo {
    var note: String
    var octave: Int
    var distanceFromBaseFreq: Int
    var eachFreq: Float
    var speedOfSound: Double
    
    init(note: String, octave: Int, distanceFromBaseFreq: Int, eachFreq: Float, speedOfSound: Double) {
        self.note = note
        self.octave = octave
        self.distanceFromBaseFreq = distanceFromBaseFreq
        self.eachFreq = eachFreq
        self.speedOfSound = speedOfSound
    }
}
