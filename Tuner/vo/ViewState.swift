//
//  ViewState.swift
//  Tuner
//
//  Created by yoonbumtae on 2021/08/06.
//

import Foundation

struct TunerViewState: Codable {
    var isShouldReplay: Bool = false
    var replayRow: Int = -1
    var baseFreq: Float = 440
    var baseAmplitude: Double = 1
    var currentTuningSystem: TuningSystem = .equalTemperament
    var baseNote: Scale = Scale.A
    var currentJIScale: Scale = Scale.C
    
    // tableview 최근 선택 행
    var lastSelectedRow: Int?
    
    // Tuner Only
    var transposeScale: Scale? = nil
}
