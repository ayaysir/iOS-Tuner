//
//  FrequencyUtil.swift
//  Tuner
//
//  Created by yoonbumtae on 2021/08/04.
//

import Foundation

enum TuningSystem: Int, CaseIterable, Codable {
    case equalTemperament, justIntonationMajor
    
    var textValue: String {
        switch self {
        case .equalTemperament: return "평균율"
        case .justIntonationMajor: return "순정율"
        }
    }
}

enum Scale: Int, CaseIterable, Codable {
    case C, C_sharp, D, D_sharp, E, F, F_sharp, G, G_sharp, A, A_sharp, B
    
    var textValueForSharp: String {
        switch self {
        case .C: return "C"
        case .C_sharp: return "C#"
        case .D: return "D"
        case .D_sharp: return "D♯"
        case .E: return "E"
        case .F: return "F"
        case .F_sharp: return "F♯"
        case .G: return "G"
        case .G_sharp: return "G♯"
        case .A: return "A"
        case .A_sharp: return "A♯"
        case .B: return "B"
        }
    }
    
    var textValueForFlat: String {
        switch self {
        case .C: return "C"
        case .C_sharp: return "D♭"
        case .D: return "D"
        case .D_sharp: return "E♭"
        case .E: return "E"
        case .F: return "F"
        case .F_sharp: return "G♭"
        case .G: return "G"
        case .G_sharp: return "A♭"
        case .A: return "A"
        case .A_sharp: return "B♭"
        case .B: return "B"
        }
    }
    
    var textValueMixed: String {
        switch self {
        case .C: return "C"
        case .C_sharp: return "C# / D♭"
        case .D: return "D"
        case .D_sharp: return "D♯ / E♭"
        case .E: return "E"
        case .F: return "F"
        case .F_sharp: return "F♯ / G♭"
        case .G: return "G"
        case .G_sharp: return "G♯ / A♭"
        case .A: return "A"
        case .A_sharp: return "A♯ / B♭"
        case .B: return "B"
        }
    }
    
    
    
    var justIntonationRatio: [Float] {
        switch self {
        case .C: return [1, 25/24, 9/8, 6/5, 5/4, 4/3, 45/32, 3/2, 8/5, 5/3, 9/5, 15/8]
        case .C_sharp: return [15/8/2, 1, 25/24, 9/8, 6/5, 5/4, 4/3, 45/32, 3/2, 8/5, 5/3, 9/5]
        case .D: return [9/5/2, 15/8/2, 1, 25/24, 9/8, 6/5, 5/4, 4/3, 45/32, 3/2, 8/5, 5/3]
        case .D_sharp: return [5/3/2, 9/5/2, 15/8/2, 1, 25/24, 9/8, 6/5, 5/4, 4/3, 45/32, 3/2, 8/5]
        case .E: return [8/5/2, 5/3/2, 9/5/2, 15/8/2, 1, 25/24, 9/8, 6/5, 5/4, 4/3, 45/32, 3/2]
        case .F: return [3/2/2, 8/5/2, 5/3/2, 9/5/2, 15/8/2, 1, 25/24, 9/8, 6/5, 5/4, 4/3, 45/32]
        case .F_sharp: return [45/32/2, 3/2/2, 8/5/2, 5/3/2, 9/5/2, 15/8/2, 1, 25/24, 9/8, 6/5, 5/4, 4/3]
        case .G: return [4/3/2, 45/32/2, 3/2/2, 8/5/2, 5/3/2, 9/5/2, 15/8/2, 1, 25/24, 9/8, 6/5, 5/4]
        case .G_sharp: return [5/4/2, 4/3/2, 45/32/2, 3/2/2, 8/5/2, 5/3/2, 9/5/2, 15/8/2, 1, 25/24, 9/8, 6/5]
        case .A: return [6/5/2, 5/4/2, 4/3/2, 45/32/2, 3/2/2, 8/5/2, 5/3/2, 9/5/2, 15/8/2, 1, 25/24, 9/8]
        case .A_sharp: return [9/8/2, 6/5/2, 5/4/2, 4/3/2, 45/32/2, 3/2/2, 8/5/2, 5/3/2, 9/5/2, 15/8/2, 1, (25/24)]
        case .B: return [25/24/2, 9/8/2, 6/5/2, 5/4/2, 4/3/2, 45/32/2, 3/2/2, 8/5/2, 5/3/2, 9/5/2, 15/8/2, 1]
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
let NOTE_START = Scale.C.rawValue
let NOTE_END = Scale.B.rawValue

let JUST_RATIO: [Float] = [1, 25/24, 9/8, 6/5, 5/4, 4/3, 45/32, 3/2, 8/5, 5/3, 9/5, 15/8]

func makeFreqArray(tuningSystem: TuningSystem, baseFreq: Float = 440.0, scale: Scale, baseNote: Scale) -> [FrequencyInfo] {
    switch tuningSystem {
    case .equalTemperament:
        return makeFreqArrayEqualTemperament(baseFreq: baseFreq, baseNote: baseNote)
    case .justIntonationMajor:
        return makeFreqArrayJustIntonation(baseFreq: baseFreq, scale: scale, baseNote: baseNote)
    }
}

private func makeFreqArrayEqualTemperament(baseFreq: Float = 440.0, baseNote: Scale) -> [FrequencyInfo] {
    var freqArray: [FrequencyInfo] = []
    let indexOfBaseNote = baseNote.rawValue
    let distanceFromBaseToLowest = NOTE_NAMES.count * (BASE_OCTAVE - OCTAVE_START) + indexOfBaseNote
    var distIndex = 0
    
    // draw initial table
    for octave in OCTAVE_START...OCTAVE_END {
        for noteIndex in NOTE_START...NOTE_END {
            // 노트 옆에 옥타브를 아래 첨자로 표시
            // 이명동음의 경우 / 로 구분해 표시
            
            let dist = distanceFromBaseToLowest * -1 + distIndex
            distIndex += 1
            let eachFreq = baseFreq * pow(EXP, Float(dist))
            
            let speedOfSound = Float(SPEED_OF_SOUND) / eachFreq
//            let altNote: String = ALT_NOTE_NAMES[note] ?? ""
//            let appendedNote: String = altNote != "" ? "\(note) / \(altNote)" : note
            
            freqArray.append(FrequencyInfo(note: Scale(rawValue: noteIndex)!, octave: octave, eachFreq: eachFreq, speedOfSound: speedOfSound))
            
            // Base note (440)의 경우 하이라이트
        }
    }
    return freqArray
}

private func makeFreqArrayJustIntonation(baseFreq: Float = 440.0, scale: Scale, baseNote: Scale) -> [FrequencyInfo] {
    var freqArray: [FrequencyInfo] = []
    var indexOfBaseNote: Int {
        if scale.rawValue <= baseNote.rawValue {
            return baseNote.rawValue - scale.rawValue
        } else {
            return 12 + (baseNote.rawValue - scale.rawValue)
        }
     }
    
    // A4로부터 A1 계산하기
    // 4     3  2  1
    // 440  /2 /2 /2
    let powered = pow(2, BASE_OCTAVE - OCTAVE_START)
    let c4FreqJI = baseFreq / JUST_RATIO[indexOfBaseNote]
    let cLowestOctaveFreq: Float = c4FreqJI / Float(truncating: powered as NSNumber)

    var rootFreq = cLowestOctaveFreq
    for octave in OCTAVE_START...OCTAVE_END {
        for noteIndex in NOTE_START...NOTE_END {
            
            var intonationRatioArray: [Float] {
                if scale.rawValue > baseNote.rawValue {
                    return scale.justIntonationRatio.map { $0 * 2 }
                }
                return scale.justIntonationRatio
            }
            
            let eachFreq = rootFreq * intonationRatioArray[noteIndex]
            let speedOfSound = Float(SPEED_OF_SOUND) / eachFreq
//            let altNote: String = ALT_NOTE_NAMES[note] ?? ""
//            let appendedNote: String = altNote != "" ? "\(note) / \(altNote)" : note
            freqArray.append(FrequencyInfo(note: Scale(rawValue: noteIndex)!, octave: octave, eachFreq: eachFreq, speedOfSound: speedOfSound))
            // 2배가 되었을 때
            if noteIndex >= NOTE_END {
                rootFreq *= 2
                print("2x rootFreq:", rootFreq)
            }
        }
    }
    
    return freqArray
}

func getOctave4Frequency_ET(targetNote4: Scale, prevNote4: Scale, prev4frequency: Float) -> Float {
    let dist = (prevNote4.rawValue - targetNote4.rawValue) * -1
    return prev4frequency * pow(EXP, Float(dist))
}

func getA4Frequency_ET(baseNote4: Scale, frequency: Float) -> Float {
    var distFromA4: Int {
        return baseNote4.rawValue <= Scale.A.rawValue
            ? Scale.A.rawValue - baseNote4.rawValue
            : (baseNote4.rawValue - Scale.A.rawValue) * -1
    }
    return frequency * pow(EXP, Float(distFromA4))
}

func getNote(frequency: Float, semitone: Int = 69, a4Frequency: Float = 440) -> Float {
    let note = 12 * (log(frequency / a4Frequency) / log(2))
    return roundf(note) + Float(semitone)
}

func getStandardFrequency(noteNum: Float, semitone: Int = 69, a4Frequency: Float = 440) -> Float {
    let exponent = (noteNum - Float(semitone)) / 12
    return a4Frequency * Float(truncating: pow(2, exponent) as NSNumber)
}

func getCents(frequency: Float, noteNum: Float) -> Float {
    return floor((1200 * log(frequency / getStandardFrequency(noteNum: noteNum))) / log(2.0))
}
