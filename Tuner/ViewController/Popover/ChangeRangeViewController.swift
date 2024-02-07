//
//  ChangeRangeViewController.swift
//  Tuner
//
//  Created by 윤범태 on 2/8/24.
//

import UIKit

protocol ChangeRangeVCDelegate: AnyObject {
    func didSelectedNote(_ controller: ChangeRangeViewController, key: Scale, octave: Int, isLeft: Bool)
}

class ChangeRangeViewController: UIViewController {
    @IBOutlet weak var pkvKeyList: UIPickerView!
    @IBOutlet weak var btnSubmit: UIButton!
    
    var isLeft = true
    var key: Scale!
    var octave: Int!
    weak var delegate: ChangeRangeVCDelegate?
    
    let keys = Scale.allCases
    
    override func viewDidLoad() {
        pkvKeyList.delegate = self
        pkvKeyList.dataSource = self
        pkvKeyList.selectRow(key.rawValue, inComponent: 0, animated: false)
        pkvKeyList.selectRow(octave, inComponent: 1, animated: false)
    }
    
    @IBAction func btnActSubmit(_ sender: UIButton) {
        dismiss(animated: true) { [unowned self] in
            delegate?.didSelectedNote(self, key: key, octave: octave, isLeft: isLeft)
        }
    }
    
    static func show(_ viewController: UIViewController, displayKey: Scale, displayOctave: Int, buttonFrame: CGRect, isLeft: Bool = true) {
        /* 2 */
        //Configure the presentation controller
        guard let changeRangeVC = viewController.storyboard?.instantiateViewController(withIdentifier: "ChangeRangeVC") as? ChangeRangeViewController else {
            return
        }
        
        changeRangeVC.isLeft = isLeft
        changeRangeVC.key = displayKey
        changeRangeVC.octave = displayOctave
        changeRangeVC.modalPresentationStyle = .popover
        changeRangeVC.preferredContentSize = .init(width: 200, height: 200)
        changeRangeVC.delegate = viewController as? any ChangeRangeVCDelegate
        
        /* 3 */
        // Present popover
        if let popoverPresentationController = changeRangeVC.popoverPresentationController {
            popoverPresentationController.permittedArrowDirections = .up
            popoverPresentationController.sourceView = viewController.view
            popoverPresentationController.sourceRect = buttonFrame
            popoverPresentationController.delegate = viewController as? any UIPopoverPresentationControllerDelegate
            
            viewController.present(changeRangeVC, animated: true, completion: nil)
        }
    }
}

extension ChangeRangeViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0: keys.count
        case 1: 8
        default: 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0: keys[row].textValueMixed
        case 1: "\(row)"
        default: ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            key = Scale(rawValue: row)
        case 1:
            octave = row
        default:
            break
        }
    }
}
