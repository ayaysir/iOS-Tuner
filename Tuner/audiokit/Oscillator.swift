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
    var amplitude: AUValue = 5
    var rampDuration: AUValue = 1
}

class DynamicOscillatorConductor: ObservableObject {
    let engine = AudioEngine()
    var data = DynamicOscillatorData()
    var osc = DynamicOscillator()
    var mixer = Mixer()
    

    func noteOn(note: MIDINoteNumber) {
        data.isPlaying = true
        data.frequency = note.midiNoteToFrequency()
    }

    func noteOff(note: MIDINoteNumber) {
        data.isPlaying = false
    }

    init() {
        mixer.addInput(osc)
        engine.output = mixer
    }

    func start() {
        osc.amplitude = 1
        mixer.volume = 25
        osc.setWaveform(Table(.triangle))
//        mixer.start()
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
    
    func noteOn(frequency: Float) {
        data.isPlaying = true
        osc.start()
        data.frequency = frequency
        osc.$frequency.ramp(to: data.frequency, duration: 0)
        osc.$amplitude.ramp(to: 0.5, duration: 0)
    }
    
    func noteOff() {
        data.isPlaying = false
        data.frequency = 0.0
        osc.$amplitude.ramp(to: 0, duration: 0)
    }
}
