//
//  FreqTableViewController.swift
//  Tuner
//
//  Created by yoonbumtae on 2021/07/31.
//

import UIKit
import DropDown

class GlobalOscillator {
    static let shared = GlobalOscillator()
    let conductor = DynamicOscillatorConductor()
    var isShoudReplay: Bool = false
    var replayRow: Int = -1
}

class FreqTableViewController: UIViewController {
    
    var freqArray: [FrequencyInfo]!
    
    var baseFreq: Int = 440
    var baseAmplitude: Double = 0.5
    
    let tuningDropDown = DropDown()
    let scaleDropDown = DropDown()
    var currentTuningSystem: TuningSystem = .equalTemperament
    
    @IBOutlet weak var textA4FreqOutlet: UITextField!
    @IBOutlet weak var tblFreqList: UITableView!
    @IBOutlet weak var selectBackgroundPlay: UISwitch!
    @IBOutlet var menuScale: UICommand!
    @IBOutlet weak var btnTuningSelect: UIButton!
    @IBOutlet weak var btnScaleSelect: UIButton!
    
    // tableview 최근 선택 행
    var lastSelectedRow: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function)
        setTuningDropDown()
        setScaleDropDown()
        
        print(EXP)
        freqArray = makeFreqArray(tuningSystem: .equalTemperament, baseFreq: baseFreq, scale: nil)
        textA4FreqOutlet.text = String(baseFreq)
        
        textA4FreqOutlet.addDoneButtonOnKeyboard()
        textA4FreqOutlet.delegate = self
        
        selectBackgroundPlay.isOn = UserDefaults.standard.bool(forKey: "freq-bg-play")
        
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(conductorDisappear), name: UIScene.willDeactivateNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(conductorAppear), name: UIScene.didActivateNotification, object: nil)
        
    }
    
    @objc func conductorDisappear() {
        let isOn = UserDefaults.standard.bool(forKey: "freq-bg-play")
        print(">> disappear")
        if !isOn {
            GlobalOscillator.shared.conductor.stop()
        }
    }
    
    @objc func conductorAppear() {
        print(">> active")
        let isOn = UserDefaults.standard.bool(forKey: "freq-bg-play")
        let isShoudReplay = GlobalOscillator.shared.isShoudReplay
        if !isOn && isShoudReplay {
            GlobalOscillator.shared.conductor.start()
            let lastFreq = GlobalOscillator.shared.conductor.data.frequency
            GlobalOscillator.shared.conductor.noteOn(frequency: lastFreq)
        }
    }
    
    func setTuningDropDown() {
        tuningDropDown.dataSource = TuningSystem.allCases.map { $0.textValue }
        tuningDropDown.anchorView = btnTuningSelect
        tuningDropDown.cornerRadius = 15
        btnTuningSelect.setTitle(currentTuningSystem.textValue, for: .normal)
        btnScaleSelect.isHidden = true
        tuningDropDown.selectRow(0)
        
        tuningDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("선택한 아이템 : \(item)")
            print("인덱스 : \(index)")
            
            if index == 0 {
                btnScaleSelect.isHidden = true
            } else {
                btnScaleSelect.isHidden = false
            }
            
            let tuningSystem: TuningSystem = TuningSystem(rawValue: index) ?? TuningSystem.equalTemperament
            reloadTable(freq: baseFreq, tuningSystem: tuningSystem)
            btnTuningSelect.setTitle(tuningSystem.textValue, for: .normal)
            GlobalOscillator.shared.conductor.stop()
            lastSelectedRow = nil
        }
    }
    
    func setScaleDropDown() {
        scaleDropDown.dataSource = Scale.allCases.map { key in
            if key.textValueForSharp == key.textValueForFlat {
                return key.textValueForSharp
            } else {
                return "\(key.textValueForSharp) / \(key.textValueForFlat)"
            }
        }
        scaleDropDown.anchorView = btnScaleSelect
        scaleDropDown.cornerRadius = 15
        
        scaleDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            let scale: Scale = Scale(rawValue: index) ?? Scale.C
            reloadTable(freq: baseFreq, tuningSystem: currentTuningSystem, scale: scale)
            btnScaleSelect.setTitle(item, for: .normal)
            GlobalOscillator.shared.conductor.stop()
            lastSelectedRow = nil
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print(#function)
        conductorAppear()
        let replayRow = GlobalOscillator.shared.replayRow
        if replayRow != -1 {
            tblFreqList.selectRow(at: IndexPath(row: replayRow, section: 0), animated: false, scrollPosition: UITableView.ScrollPosition.top)
            lastSelectedRow = replayRow
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print(#function)
        conductorDisappear()
    }
    
    func reloadTable(freq: Int, tuningSystem: TuningSystem, scale: Scale = Scale.C) {
        let oldBaseFreq = baseFreq
        freqArray = makeFreqArray(tuningSystem: tuningSystem, baseFreq: freq, scale: scale)
        tblFreqList.reloadData()
        if GlobalOscillator.shared.conductor.osc.amplitude != 0.0 {
            let lastFreq = GlobalOscillator.shared.conductor.data.frequency
            GlobalOscillator.shared.conductor.noteOn(frequency:  lastFreq + Float(freq - oldBaseFreq))
            GlobalOscillator.shared.isShoudReplay = true
        }
        baseFreq = freq
        currentTuningSystem = tuningSystem
    }
    
    @IBAction func btnPlusAct(_ sender: Any) {
        guard let text = textA4FreqOutlet.text else { return }
        guard let num = Int(text) else { return }
        textA4FreqOutlet.text = String(num + 1)
        reloadTable(freq: num + 1, tuningSystem: currentTuningSystem)
        if lastSelectedRow != nil {
            tblFreqList.selectRow(at: IndexPath(row: lastSelectedRow!, section: 0), animated: false, scrollPosition: UITableView.ScrollPosition.none)
        }
    }
    
    @IBAction func btnMinusAct(_ sender: Any) {
        guard let text = textA4FreqOutlet.text else { return }
        guard let num = Int(text) else { return }
        textA4FreqOutlet.text = String(num - 1)
        reloadTable(freq: num - 1, tuningSystem: currentTuningSystem)
        if lastSelectedRow != nil {
            tblFreqList.selectRow(at: IndexPath(row: lastSelectedRow!, section: 0), animated: false, scrollPosition: UITableView.ScrollPosition.none)
        }
    }
    
    @IBAction func selectBackgroundPlayAct(_ sender: Any) {
        print(selectBackgroundPlay.isOn)
        UserDefaults.standard.setValue(selectBackgroundPlay.isOn, forKey: "freq-bg-play")
    }
    
    @IBAction func btnTuningSelectAct(_ sender: Any) {
        tuningDropDown.show()
    }
    
    @IBAction func btnScaleSelectAct(_ sender: Any) {
        scaleDropDown.show()
    }
    
    
}

extension FreqTableViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return freqArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "freqCell", for: indexPath) as? FreqCell else {
            return UITableViewCell()
        }
        cell.update(freqInfo: freqArray[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if lastSelectedRow != nil && lastSelectedRow! == indexPath.row {
            tableView.deselectRow(at: indexPath, animated: true)
            GlobalOscillator.shared.conductor.noteOff()
            GlobalOscillator.shared.isShoudReplay = false
            GlobalOscillator.shared.replayRow = -1
            lastSelectedRow = nil
        } else {
            GlobalOscillator.shared.conductor.data.isPlaying = true
            GlobalOscillator.shared.conductor.start()
            GlobalOscillator.shared.conductor.noteOn(frequency: freqArray[indexPath.row].eachFreq)
            GlobalOscillator.shared.isShoudReplay = true
            GlobalOscillator.shared.replayRow = indexPath.row
            lastSelectedRow = indexPath.row
        }
    }
    
}

class FreqCell: UITableViewCell {
    @IBOutlet weak var lblNoteName: UILabel!
    @IBOutlet weak var lblFreq: UILabel!
    @IBOutlet weak var lblSpeedOfSound: UILabel!
    
    func update(freqInfo: FrequencyInfo) {
        lblNoteName.text = freqInfo.note + makeSubscriptOfNumber(freqInfo.octave)
        lblFreq.text = freqInfo.eachFreq.cleanFixTwo
        lblSpeedOfSound.text = freqInfo.speedOfSound.cleanFixTwo
    }
}

extension FreqTableViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // 백스페이스
        if string.isEmpty {
            return true
        }
        
        let charSetExceptNumber = CharacterSet.decimalDigits.inverted
        let strComponents = string.components(separatedBy: charSetExceptNumber)
        let numberFiltered = strComponents.joined(separator: "")
        
        let maxLength = 3
        let currentString  = textField.text! as NSString
        let newString = currentString.replacingCharacters(in: range, with: string)

        if newString.count == maxLength && string.isNumber {
            textField.text = newString
            textField.resignFirstResponder()
            return false
        }

        return string == numberFiltered
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else { return }
        guard let freq = Int(text) else {
            reloadTable(freq: 440, tuningSystem: currentTuningSystem)
            return
        }
        reloadTable(freq: freq, tuningSystem: currentTuningSystem)
    }
}
