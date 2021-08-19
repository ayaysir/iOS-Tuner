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
    
    var localized: String {
        return NSLocalizedString(self, tableName: "Localizable", value: self, comment: "")
    }
    
    func localizedFormat(_ arguments: CVarArg...) -> String {
        let localizedValue = self.localized
        return String(format: localizedValue, arguments)
    }
}
