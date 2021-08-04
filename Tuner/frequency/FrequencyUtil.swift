//
//  FrequencyUtil.swift
//  Tuner
//
//  Created by yoonbumtae on 2021/08/04.
//

import Foundation

enum TuningSystem: Int, CaseIterable {
    case equalTemperament, justIntonationMajor
    
    var textValue: String {
        switch self {
        case .equalTemperament: return "평균율"
        case .justIntonationMajor: return "순정율"
        }
    }
}

let NOTE_NAMES = ["C", "C♯", "D", "D♯", "E", "F", "F♯", "G", "G♯", "A", "A♯", "B"]
let ALT_NOTE_NAMES: [String: String] = [
    "C♯": "D♭",
    "D♯": "E♭",
    "F♯": "G♭",
    "G♯": "A♭",
    "A♯": "B♭"
]
let BASE_NOTE = "A"
let BASE_OCTAVE = 4
let SPEED_OF_SOUND = 34500
let EXP = pow(2, (1 / 12) as Float)
let OCTAVE_START = 1
let OCTAVE_END = 7

let JUST_RATIO: [Float] = [1, 25/24, 9/8, 6/5, 5/4, 4/3, 45/32, 3/2, 8/5, 5/3, 9/5, 15/8]

func makeFreqArray(tuningSystem: TuningSystem, baseFreq: Int = 440) -> [FrequencyInfo] {
    switch tuningSystem {
    case .equalTemperament:
        return makeFreqArrayEqualTemperament(baseFreq: baseFreq)
    case .justIntonationMajor:
        return makeFreqArrayJustIntonationMajor(baseFreq: baseFreq)
    }
}

func makeFreqArrayEqualTemperament(baseFreq: Int = 440) -> [FrequencyInfo] {
    var freqArray: [FrequencyInfo] = []
    let indexOfA = NOTE_NAMES.firstIndex {$0 == "A"}!
    let distanceFromBaseToLowest = NOTE_NAMES.count * (BASE_OCTAVE - OCTAVE_START) + indexOfA
    var distIndex = 0
    
    // draw initial table
    for octave in OCTAVE_START...OCTAVE_END {
        for note in NOTE_NAMES {
            // 노트 옆에 옥타브를 아래 첨자로 표시
            // 이명동음의 경우 / 로 구분해 표시
            
            let dist = distanceFromBaseToLowest * -1 + distIndex
            distIndex += 1
            let eachFreq = Float(baseFreq) * pow(EXP, Float(dist))
            
            let speedOfSound = Float(SPEED_OF_SOUND) / eachFreq
//                print(note, octave, dist, distIndex)
            let altNote: String = ALT_NOTE_NAMES[note] ?? ""
            let appendedNote: String = altNote != "" ? "\(note) / \(altNote)" : note
            freqArray.append(FrequencyInfo(note: appendedNote, octave: octave, eachFreq: eachFreq, speedOfSound: speedOfSound))
            
            // Base note (440)의 경우 하이라이트
        }
    }
    return freqArray
}

func makeFreqArrayJustIntonationMajor(baseFreq: Int = 440) -> [FrequencyInfo] {
    var freqArray: [FrequencyInfo] = []
    let indexOfA = NOTE_NAMES.firstIndex {$0 == "A"}!
    
    // A4로부터 A1 계산하기
    // 4     3  2  1
    // 440  /2 /2 /2 = 55
    // A4를 비율을 나누기로 하면 C1이 나옴?
    let powered = pow(2, BASE_OCTAVE - OCTAVE_START)
    let c4FreqJI = Float(baseFreq) / JUST_RATIO[indexOfA]
    let cLowestOctaveFreq: Float = c4FreqJI / Float(truncating: powered as NSNumber)

    var rootFreq = cLowestOctaveFreq
    for octave in OCTAVE_START...OCTAVE_END {
        for (index, note) in NOTE_NAMES.enumerated() {
            let eachFreq = rootFreq * JUST_RATIO[index]
            let speedOfSound = Float(SPEED_OF_SOUND) / eachFreq
            let altNote: String = ALT_NOTE_NAMES[note] ?? ""
            let appendedNote: String = altNote != "" ? "\(note) / \(altNote)" : note
            freqArray.append(FrequencyInfo(note: appendedNote, octave: octave, eachFreq: eachFreq, speedOfSound: speedOfSound))
//            print(note, octave, eachFreq, index)
            // 2배가 되었을 때
            if index >= NOTE_NAMES.count - 1 {
                rootFreq *= 2
                print("aaa:", rootFreq)
            }
        }
    }
    
    return freqArray
}
