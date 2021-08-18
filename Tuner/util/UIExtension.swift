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

// https://stackoverflow.com/questions/59237515
extension UIView {
    enum GlowEffect: Float {
        case small = 0.4, normal = 2, big = 30
    }

    func doGlowAnimation(withColor color: UIColor, withEffect effect: GlowEffect = .normal) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowRadius = 0
        layer.shadowOpacity = 0.8
        layer.shadowOffset = .zero

        let glowAnimation = CABasicAnimation(keyPath: "shadowRadius")
        glowAnimation.fromValue = 0
        glowAnimation.toValue = effect.rawValue
        glowAnimation.fillMode = .removed
        glowAnimation.repeatCount = .infinity
        glowAnimation.duration = 2
        glowAnimation.autoreverses = true
        layer.add(glowAnimation, forKey: "shadowGlowingAnimation")
    }
    
    func doGlow(withColor color: UIColor) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowRadius = 0
        layer.shadowOpacity = 0.8
        layer.shadowOffset = .zero
    }
}

// https://gist.github.com/mathewsanders/94ed8212587d72684291483905132790
extension CGSize {
    
    typealias ContextClosure = (_ context: CGContext, _ frame: CGRect) -> ()
    func image(withContext context: ContextClosure) -> UIImage? {
        
        UIGraphicsBeginImageContext(self)
        let frame = CGRect(origin: .zero, size: self)
        context(UIGraphicsGetCurrentContext()!, frame)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

@IBDesignable extension UIButton {
    @IBInspectable var roundButton: Bool {
        set {
            if newValue {
                round()
            }
        } get {
            return self.roundButton
        }
    }
    
    @IBInspectable var circleButton: Bool {
        set {
            if newValue {
                circle()
            }
        } get {
            return self.roundButton
        }
    }
    
    
    func round() {
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
    }
    
    func circle() {
        self.layer.cornerRadius = 0.5 * self.bounds.size.width
        self.clipsToBounds = true
    }
}
