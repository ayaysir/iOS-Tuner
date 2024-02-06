//
//  FreqTextFieldDelegate.swift
//  Tuner
//
//  Created by yoonbumtae on 2021/08/07.
//

import UIKit

func freq_shouldChangeCharactersIn(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    // 백스페이스
    if string.isEmpty {
        return true
    }
    
    let charSetExceptNumber = CharacterSet(charactersIn: "0123456789.").inverted
    let strComponents = string.components(separatedBy: charSetExceptNumber)
    let numberFiltered = strComponents.joined(separator: "")

    return string == numberFiltered
}

