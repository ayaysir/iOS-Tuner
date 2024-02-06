//
//  NoteRangeConfig.swift
//  Tuner
//
//  Created by yoonbumtae on 2021/08/15.
//

import Foundation

struct NoteRangeConfig: Codable {
    var note: Scale
    var octave: Int
    var noteNum: Int {
        return (octave * 12) + note.rawValue
    }
}
