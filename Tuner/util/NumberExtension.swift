//
//  NumberExtension.swift
//  Tuner
//
//  Created by yoonbumtae on 2021/08/04.
//

import Foundation

extension Float {
    var cleanFixTwo: String {
       return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(format: "%.2f", self)
    }
}
