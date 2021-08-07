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

extension BinaryInteger {
    func degreesToRadians<F: FloatingPoint>() -> F {  F(self) * .pi / 180 }
}

extension FloatingPoint {
    var degreesToRadians: Self { self * .pi / 180 }
    var radiansToDegrees: Self { self * 180 / .pi }
}
