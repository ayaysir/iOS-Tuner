//
//  ChangeKeyViewController.swift
//  Tuner
//
//  Created by 윤범태 on 2/6/24.
//

import UIKit

protocol ChangeKeyVCDelegate: AnyObject {
    func didSelectedKey(_ controller: ChangeKeyViewController, key: Scale, isLimitedOctave: Bool)
}

class ChangeKeyViewController: UIViewController {
    @IBOutlet weak var pkvKeyList: UIPickerView!
    @IBOutlet weak var btnSubmit: UIButton!
    
    var isAddOctave = false
    var key: Scale!
    weak var delegate: ChangeKeyVCDelegate?
    
    let keys = Scale.allCases
    
    override func viewDidLoad() {
        pkvKeyList.delegate = self
        pkvKeyList.dataSource = self
        pkvKeyList.selectRow(key.rawValue, inComponent: 0, animated: false)
    }
    
    @IBAction func btnActSubmit(_ sender: UIButton) {
        dismiss(animated: true) { [unowned self] in
            delegate?.didSelectedKey(self, key: key, isLimitedOctave: isAddOctave)
        }
    }
    
    static func show(_ viewController: UIViewController, displayKey: Scale, buttonFrame: CGRect, isAddOctave: Bool = false) {
        /* 2 */
        //Configure the presentation controller
        guard let changeKeyVC = viewController.storyboard?.instantiateViewController(withIdentifier: "ChangeKeyVC") as? ChangeKeyViewController else {
            return
        }
        
        changeKeyVC.isAddOctave = isAddOctave
        changeKeyVC.key = displayKey
        changeKeyVC.modalPresentationStyle = .popover
        changeKeyVC.preferredContentSize = .init(width: 200, height: 300)
        changeKeyVC.delegate = viewController as? any ChangeKeyVCDelegate

        /* 3 */
        // Present popover
        if let popoverPresentationController = changeKeyVC.popoverPresentationController {
            popoverPresentationController.permittedArrowDirections = .up
            popoverPresentationController.sourceView = viewController.view
            popoverPresentationController.sourceRect = buttonFrame
            popoverPresentationController.delegate = viewController as? any UIPopoverPresentationControllerDelegate
            
            viewController.present(changeKeyVC, animated: true, completion: nil)
        }
    }
}

extension ChangeKeyViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        keys.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        isAddOctave ? keys[row].textValueMixedAttach4 : keys[row].textValueMixed
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        key = Scale(rawValue: row)
    }
}
