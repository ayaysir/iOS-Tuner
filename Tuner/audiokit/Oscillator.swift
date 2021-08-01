//
//  Oscillator.swift
//  Tuner
//
//  Created by yoonbumtae on 2021/08/01.
//

import Foundation
import AudioKit
import SoundpipeAudioKit

struct DynamicOscillatorData {
    var isPlaying: Bool = false
    var frequency: AUValue = 440
    var amplitude: AUValue = 0.1
    var rampDuration: AUValue = 1
}

class DynamicOscillatorConductor: ObservableObject {
    let engine = AudioEngine()
    var data = DynamicOscillatorData()
    var osc = DynamicOscillator()

    func noteOn(note: MIDINoteNumber) {
        data.isPlaying = true
        data.frequency = note.midiNoteToFrequency()
    }

    func noteOff(note: MIDINoteNumber) {
        data.isPlaying = false
    }

    init() {
        engine.output = osc
    }

    func start() {
        osc.amplitude = 0.2
        osc.setWaveform(Table(.triangle))
        do {
            try engine.start()
        } catch let err {
            Log(err)
        }
    }

    func stop() {
        data.isPlaying = false
        osc.stop()
        engine.stop()
    }
    
    func noteOn(frequency: Double) {
        osc.start()
        data.frequency = Float(frequency)
        osc.$frequency.ramp(to: data.frequency, duration: 0)
        osc.$amplitude.ramp(to: 0.2, duration: 0)
    }
    
    func noteOff() {
        osc.$amplitude.ramp(to: 0, duration: 0)
    }
}
