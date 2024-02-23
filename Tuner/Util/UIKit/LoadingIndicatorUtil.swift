//
//  LoadingIndicatorUtil.swift
//  Tuner
//
//  Created by 윤범태 on 2/24/24.
//

import UIKit

struct LoadingIndicatorUtil {
    static let `default` = LoadingIndicatorUtil()
    private init() {}
    
    private let TAG = 95834114
    
    enum Style {
        case clear, blur
    }
    
    func show(_ viewController: UIViewController, style: Style = .clear, text: String = "") {
        let container: UIView = UIView()
        container.frame = CGRect(x: 0, y: 0, width: 80, height: 80) // Set X and Y whatever you want
        container.backgroundColor = .clear
        container.tag = TAG
        
        if text.isNotEmpty {
            let label = UILabel(frame: .init(x: 0, y: 0, width: 200, height: 30))
            label.numberOfLines = 0
            label.text = text
            label.sizeToFit()
            label.center = viewController.view.center
            label.frame.origin.y += 50
            container.addSubview(label)
            label.textColor = style == .blur ? .white : nil
        }

        let activityView = UIActivityIndicatorView(style: .large)
        activityView.center = viewController.view.center
        container.addSubview(activityView)
        
        switch style {
        case .clear:
            break
        case .blur:
            activityView.color = .white
            
            let blurEffect = UIBlurEffect(style: .dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = viewController.view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            blurEffectView.tag = TAG
            viewController.view.addSubview(blurEffectView)
        }
        
        viewController.view.addSubview(container)
        
        activityView.startAnimating()
    }
    
    func hide(_ viewController: UIViewController) {
        viewController.view.subviews.forEach {
            if $0.tag == TAG {
                $0.removeFromSuperview()
            }
        }
    }
}




