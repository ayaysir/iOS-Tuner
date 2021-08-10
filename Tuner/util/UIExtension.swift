//
//  UIExtension.swift
//  Tuner
//
//  Created by yoonbumtae on 2021/08/02.
//

import UIKit

// 넘버 패드에 리턴 기능 추가
// https://stackoverflow.com/questions/28338981
extension UITextField {
    @IBInspectable var doneAccesory: Bool{
        get {
            return self.doneAccesory
        }
        set(hasDone) {
            if hasDone {
                addDoneButtonOnKeyboard()
            }
        }
    }

    func addDoneButtonOnKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(self.doneButtonAction))
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()

        self.inputAccessoryView = doneToolbar
    }

    @objc func doneButtonAction() {
        self.resignFirstResponder()
    }
}

// https://stackoverflow.com/questions/50012606
extension UIBezierPath
{
    func rotateAroundCenter(angle: CGFloat)
    {
        let center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        var transform = CGAffineTransform.identity
        transform = transform.translatedBy(x: center.x, y: center.y)
        transform = transform.rotated(by: angle)
        transform = transform.translatedBy(x: -center.x, y: -center.y)
        self.apply(transform)
    }
}
