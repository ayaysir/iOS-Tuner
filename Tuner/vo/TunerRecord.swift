//
//  TunerRecord.swift
//  Tuner
//
//  Created by yoonbumtae on 2021/08/12.
//

import Foundation

struct TunerRecord: Codable {
    let id: UUID
    let date: Date
    let avgFreq: Float
    let stdFreq: Float // 표준편차
    let standardFreq: Float // 원래 주파수
    let centDist: Float // 평균 거리
    let noteIndex: Int
    let octave: Int
    let tuningSystem: TuningSystem
}
