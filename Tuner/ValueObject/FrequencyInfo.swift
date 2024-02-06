//
//  FrequencyInfo.swift
//  Tuner
//
//  Created by yoonbumtae on 2021/08/01.
//

import Foundation

struct FrequencyInfo {
    var note: Scale
    var octave: Int
    var eachFreq: Float
    var speedOfSound: Float
    
    init(note: Scale, octave: Int, eachFreq: Float, speedOfSound: Float) {
        self.note = note
        self.octave = octave
        self.eachFreq = eachFreq
        self.speedOfSound = speedOfSound
    }
}
