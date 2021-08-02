//
//  StringExtension.swift
//  Tuner
//
//  Created by yoonbumtae on 2021/08/02.
//

import Foundation

extension String  {
    var isNumber: Bool {
        return !isEmpty && rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
}
