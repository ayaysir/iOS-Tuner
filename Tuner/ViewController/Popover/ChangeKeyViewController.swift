//
//  ChangeKeyViewController.swift
//  Tuner
//
//  Created by 윤범태 on 2/6/24.
//

import UIKit

class ChangeKeyViewController: UIViewController {
    @IBOutlet weak var pkvKeyList: UIPickerView!
    
    override func viewDidLoad() {
        pkvKeyList.delegate = self
        pkvKeyList.dataSource = self
    }
    
    var array = ["1", "2", "3"]
    var array2 = ["a", "b"]
}

extension ChangeKeyViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        5
    }
}
