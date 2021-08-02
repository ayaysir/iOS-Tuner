//
//  TextUtil.swift
//  Tuner
//
//  Created by yoonbumtae on 2021/08/01.
//

import Foundation

func makeSuperscriptOfNumber(_ num: Int) -> String {
    // ⁰ ¹ ² ³ ⁴ ⁵ ⁶ ⁷ ⁸ ⁹
    let array = "⁰ ¹ ² ³ ⁴ ⁵ ⁶ ⁷ ⁸ ⁹".split(separator: " ")
    return String(array[num])
}

func makeSubscriptOfNumber(_ num: Int) -> String {
    // ₀ ₁ ₂ ₃ ₄ ₅ ₆ ₇ ₈ ₉
    let array = "₀ ₁ ₂ ₃ ₄ ₅ ₆ ₇ ₈ ₉".split(separator: " ")
    return String(array[num])
}
