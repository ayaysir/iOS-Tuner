//
//  AdSupporter.swift
//  Tuner
//
//  Created by yoonbumtae on 2021/08/20.
//

import Foundation

struct AdSupporter {
    static let shared = AdSupporter()
    let TEST_CODE = ""
    let TUNER_AD_CODE = ""
    let FREQTABLE_AD_CODE = ""
    let STATS_AD_CODE = ""
    let HELP_AD_CODE = ""
    
    let showAd = false
    
    func randomBox() -> Bool {
        let range = 1...150
        let ticket = Int.random(in: range)
        return ticket == 50
    }
}
