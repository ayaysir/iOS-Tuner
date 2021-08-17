//
//  SettingViewController.swift
//  Tuner
//
//  Created by yoonbumtae on 2021/08/15.
//

import UIKit
import DropDown

class SettingViewController: UIViewController {
    
    @IBOutlet weak var segconMode: UISegmentedControl!
    @IBOutlet weak var segconNotation: UISegmentedControl!
    @IBOutlet weak var btnRange1: UIButton!
    @IBOutlet weak var btnRange2: UIButton!
    @IBOutlet weak var btnOctave1: UIButton!
    @IBOutlet weak var btnOctave2: UIButton!
    
    let noteDropDownLeft = DropDown()
    let octaveDropDownLeft = DropDown()
    let noteDropDownRight = DropDown()
    let octaveDropDownRight = DropDown()
    
    var leftRange = NoteRangeConfig(note: Scale.C, octave: 1)
    var rightRange = NoteRangeConfig(note: Scale.B, octave: 7)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setRange()
        loadRangeFromUserDefaults()
        loadAppearanceInfo()
    }
    
    func loadAppearanceInfo() {
        let key = "config-appearance"
        let mode = UserDefaults.standard.string(forKey: key) ?? "unspecified"
        switch mode {
        case "light":
            segconMode.selectedSegmentIndex = 1
        case "dark":
            segconMode.selectedSegmentIndex = 2
        default:
            segconMode.selectedSegmentIndex = 0
        }
    }
    
    func loadRangeFromUserDefaults() {
        do {
            leftRange = try UserDefaults.standard.getObject(forKey: "config-rangeLeft", castTo: NoteRangeConfig.self)
            rightRange = try UserDefaults.standard.getObject(forKey: "config-rangeRight", castTo: NoteRangeConfig.self)
            btnRange1.setTitle(leftRange.note.textValueMixed, for: .normal)
            btnOctave1.setTitle(String(leftRange.octave), for: .normal)
            btnRange2.setTitle(rightRange.note.textValueMixed, for: .normal)
            btnOctave2.setTitle(String(rightRange.octave), for: .normal)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func saveRangeToUserDefaults() {
        do {
            try UserDefaults.standard.setObject(leftRange, forKey: "config-rangeLeft")
            try UserDefaults.standard.setObject(rightRange, forKey: "config-rangeRight")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @IBAction func segconSelectAppearance(_ sender: UISegmentedControl) {
        let key = "config-appearance"
        switch sender.selectedSegmentIndex {
        case 0:
            UIApplication.shared.windows.forEach { window in
                window.overrideUserInterfaceStyle = .unspecified
            }
            UserDefaults.standard.setValue("unspecified", forKey: key)
        case 1:
            UIApplication.shared.windows.forEach { window in
                window.overrideUserInterfaceStyle = .light
            }
            UserDefaults.standard.setValue("light", forKey: key)
        case 2:
            UIApplication.shared.windows.forEach { window in
                window.overrideUserInterfaceStyle = .dark
            }
            UserDefaults.standard.setValue("dark", forKey: key)
        default:
            break
        }
    }
    
    @IBAction func segconNotationAct(_ sender: UISegmentedControl) {
        let key = "config-notation"
        switch sender.selectedSegmentIndex {
        case 0:
            UserDefaults.standard.setValue("sharp", forKey: key)
        case 1:
            UserDefaults.standard.setValue("flat", forKey: key)
        default:
            break
        }
    }
    
    @IBAction func btnRangeNoteLeftAct(_ sender: Any) {
        noteDropDownLeft.show()
    }
    
    @IBAction func btnRangeOctaveLeftAct(_ sender: Any) {
        octaveDropDownLeft.show()
    }
    
    @IBAction func btnRangeNoteRightAct(_ sender: Any) {
        noteDropDownRight.show()
    }
    
    @IBAction func btnRangeOctaveRightAct(_ sender: Any) {
        octaveDropDownRight.show()
    }
    
}

extension SettingViewController {
    
    func setRange() {
        setRangeLeftNote()
        setRangeLeftOctave()
        setRangeRightNote()
        setRangeRightOctave()
    }
    
    func validateRange() -> Bool {
        let leftNoteNum = leftRange.note.rawValue + (leftRange.octave * 12)
        let rightNoteNum = rightRange.note.rawValue + (rightRange.octave * 12)
        return leftNoteNum < rightNoteNum
    }
    
    func setRangeLeftNote() {
        noteDropDownLeft.dataSource = Scale.allCases.map { $0.textValueMixed }
        noteDropDownLeft.anchorView = btnRange1
        noteDropDownLeft.cornerRadius = 15
        noteDropDownLeft.selectRow(leftRange.note.rawValue)
        btnRange1.setTitle(noteDropDownLeft.dataSource[leftRange.note.rawValue], for: .normal)
        
        noteDropDownLeft.selectionAction = { [unowned self] (index: Int, item: String) in
            let oldItem = leftRange.note
            leftRange.note = Scale(rawValue: index) ?? Scale.C
            if validateRange() {
                saveRangeToUserDefaults()
                btnRange1.setTitle(item, for: .normal)
            } else {
                print(oldItem)
                simpleAlert(self, message: "범위는 왼쪽 노트보다 오른쪽 노트의 음높이가 높아야 합니다.", title: "범위 오류") { _ in
                    noteDropDownLeft.selectRow(oldItem.rawValue)
                    btnRange1.setTitle(oldItem.textValueMixed, for: .normal)
                    leftRange.note = oldItem
                }
            }
        }
    }
    
    func setRangeLeftOctave() {
        octaveDropDownLeft.dataSource = [0, 1, 2, 3, 4, 5, 6, 7].map { String($0) }
        octaveDropDownLeft.anchorView = btnOctave1
        octaveDropDownLeft.cornerRadius = 15
        octaveDropDownLeft.selectRow(leftRange.octave)
        btnOctave1.setTitle(String(leftRange.octave), for: .normal)
        
        octaveDropDownLeft.selectionAction = { [unowned self] (index: Int, item: String) in
            let oldItem = leftRange.octave
            leftRange.octave = index
            if validateRange() {
                saveRangeToUserDefaults()
                btnOctave1.setTitle(item, for: .normal)
            } else {
                print(oldItem)
                simpleAlert(self, message: "범위는 왼쪽 노트보다 오른쪽 노트의 음높이가 높아야 합니다.", title: "범위 오류") { _ in
                    octaveDropDownLeft.selectRow(oldItem)
                    btnOctave1.setTitle(String(oldItem), for: .normal)
                    leftRange.octave = oldItem
                }
            }
        }
    }
    
    func setRangeRightNote() {
        noteDropDownRight.dataSource = Scale.allCases.map { $0.textValueMixed }
        noteDropDownRight.anchorView = btnRange2
        noteDropDownRight.cornerRadius = 15
        noteDropDownRight.selectRow(rightRange.note.rawValue)
        btnRange2.setTitle(noteDropDownRight.dataSource[rightRange.note.rawValue], for: .normal)
        
        noteDropDownRight.selectionAction = { [unowned self] (index: Int, item: String) in
            let oldItem = rightRange.note
            rightRange.note = Scale(rawValue: index) ?? Scale.C
            if validateRange() {
                saveRangeToUserDefaults()
                btnRange2.setTitle(item, for: .normal)
            } else {
                simpleAlert(self, message: "범위는 왼쪽 노트보다 오른쪽 노트의 음높이가 높아야 합니다.", title: "범위 오류") { _ in
                    noteDropDownRight.selectRow(oldItem.rawValue)
                    btnRange2.setTitle(oldItem.textValueMixed, for: .normal)
                    rightRange.note = oldItem
                }
            }
        }
    }
    
    func setRangeRightOctave() {
        octaveDropDownRight.dataSource = [0, 1, 2, 3, 4, 5, 6, 7].map { String($0) }
        octaveDropDownRight.anchorView = btnOctave2
        octaveDropDownRight.cornerRadius = 15
        octaveDropDownRight.selectRow(rightRange.octave)
        btnOctave2.setTitle(String(rightRange.octave), for: .normal)
        
        octaveDropDownRight.selectionAction = { [unowned self] (index: Int, item: String) in
            let oldItem = rightRange.octave
            rightRange.octave = index
            if validateRange() {
                saveRangeToUserDefaults()
                btnOctave2.setTitle(item, for: .normal)
            } else {
                simpleAlert(self, message: "범위는 왼쪽 노트보다 오른쪽 노트의 음높이가 높아야 합니다.", title: "범위 오류") { _ in
                    octaveDropDownRight.selectRow(oldItem)
                    btnOctave2.setTitle(String(oldItem), for: .normal)
                    rightRange.octave = oldItem
                }
            }
        }
    }
}