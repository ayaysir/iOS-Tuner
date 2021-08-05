//
//  FreqTableViewController.swift
//  Tuner
//
//  Created by yoonbumtae on 2021/07/31.
//

import UIKit
import DropDown

class GlobalOsc {
    static let shared = GlobalOsc()
    let conductor = DynamicOscillatorConductor()
    var isShoudReplay: Bool = false
    var replayRow: Int = -1
    var baseFreq: Float = 440
    var baseAmplitude: Double = 0.5
    var currentTuningSystem: TuningSystem = .equalTemperament
    var baseNote: Scale = Scale.A
    var currentJIScale: Scale = Scale.C
    
    // tableview 최근 선택 행
    var lastSelectedRow: Int?
}

class FreqTableViewController: UIViewController {
    
    var freqArray: [FrequencyInfo]!
    
    let tuningDropDown = DropDown()
    let scaleDropDown = DropDown()
    let baseNoteDropDown = DropDown()
    
    @IBOutlet weak var textA4FreqOutlet: UITextField!
    @IBOutlet weak var tblFreqList: UITableView!
    @IBOutlet weak var selectBackgroundPlay: UISwitch!
    @IBOutlet var menuScale: UICommand!
    @IBOutlet weak var btnTuningSelect: UIButton!
    @IBOutlet weak var btnScaleSelect: UIButton!
    @IBOutlet weak var btnBaseNoteSelect: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTuningDropDown()
        setScaleDropDown()
        setBaseNoteDropDown()
        
        print(EXP)
        freqArray = makeFreqArray(tuningSystem: GlobalOsc.shared.currentTuningSystem, baseFreq: GlobalOsc.shared.baseFreq, scale: nil, baseNote: GlobalOsc.shared.baseNote)
        textA4FreqOutlet.text = String(GlobalOsc.shared.baseFreq)
        
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
            GlobalOsc.shared.conductor.stop()
        }
    }
    
    @objc func conductorAppear() {
        print(">> active")
        let isOn = UserDefaults.standard.bool(forKey: "freq-bg-play")
        let isShoudReplay = GlobalOsc.shared.isShoudReplay
        if !isOn && isShoudReplay {
            GlobalOsc.shared.conductor.start()
            let lastFreq = GlobalOsc.shared.conductor.data.frequency
            GlobalOsc.shared.conductor.noteOn(frequency: lastFreq)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print(#function)
        conductorAppear()
        let replayRow = GlobalOsc.shared.replayRow
        if replayRow != -1 {
            tblFreqList.selectRow(at: IndexPath(row: replayRow, section: 0), animated: false, scrollPosition: UITableView.ScrollPosition.top)
            GlobalOsc.shared.lastSelectedRow = replayRow
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print(#function)
        conductorDisappear()
    }
    
    func reloadTable(freq: Float, tuningSystem: TuningSystem, scale: Scale, baseNote: Scale) {
        let oldBaseFreq = GlobalOsc.shared.baseFreq
        freqArray = makeFreqArray(tuningSystem: tuningSystem, baseFreq: freq, scale: scale, baseNote: baseNote)
        tblFreqList.reloadData()
        if GlobalOsc.shared.conductor.osc.amplitude != 0.0 {
            let lastFreq = GlobalOsc.shared.conductor.data.frequency
            GlobalOsc.shared.conductor.noteOn(frequency:  lastFreq + freq - oldBaseFreq)
            GlobalOsc.shared.isShoudReplay = true
        }
        GlobalOsc.shared.baseFreq = freq
        GlobalOsc.shared.currentTuningSystem = tuningSystem
    }
    
    @IBAction func btnPlusAct(_ sender: Any) {
        guard let text = textA4FreqOutlet.text else { return }
        guard let num = Float(text) else { return }
        textA4FreqOutlet.text = String(num + 1)
        reloadTable(freq: num + 1, tuningSystem: GlobalOsc.shared.currentTuningSystem, scale: GlobalOsc.shared.currentJIScale, baseNote: GlobalOsc.shared.baseNote)
        if GlobalOsc.shared.lastSelectedRow != nil {
            tblFreqList.selectRow(at: IndexPath(row: GlobalOsc.shared.lastSelectedRow!, section: 0), animated: false, scrollPosition: UITableView.ScrollPosition.none)
        }
    }
    
    @IBAction func btnMinusAct(_ sender: Any) {
        guard let text = textA4FreqOutlet.text else { return }
        guard let num = Float(text) else { return }
        textA4FreqOutlet.text = String(num - 1)
        reloadTable(freq: num - 1, tuningSystem: GlobalOsc.shared.currentTuningSystem, scale: GlobalOsc.shared.currentJIScale, baseNote: GlobalOsc.shared.baseNote)
        if GlobalOsc.shared.lastSelectedRow != nil {
            tblFreqList.selectRow(at: IndexPath(row: GlobalOsc.shared.lastSelectedRow!, section: 0), animated: false, scrollPosition: UITableView.ScrollPosition.none)
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
    
    @IBAction func btnBaseNoteSelectAct(_ sender: Any) {
        baseNoteDropDown.show()
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
        if GlobalOsc.shared.lastSelectedRow != nil && GlobalOsc.shared.lastSelectedRow! == indexPath.row {
            tableView.deselectRow(at: indexPath, animated: true)
            GlobalOsc.shared.conductor.noteOff()
            GlobalOsc.shared.isShoudReplay = false
            GlobalOsc.shared.replayRow = -1
            GlobalOsc.shared.lastSelectedRow = nil
        } else {
            GlobalOsc.shared.conductor.data.isPlaying = true
            GlobalOsc.shared.conductor.start()
            GlobalOsc.shared.conductor.noteOn(frequency: freqArray[indexPath.row].eachFreq)
            GlobalOsc.shared.isShoudReplay = true
            GlobalOsc.shared.replayRow = indexPath.row
            GlobalOsc.shared.lastSelectedRow = indexPath.row
        }
    }
    
}

class FreqCell: UITableViewCell {
    @IBOutlet weak var lblNoteName: UILabel!
    @IBOutlet weak var lblFreq: UILabel!
    @IBOutlet weak var lblSpeedOfSound: UILabel!
    
    func update(freqInfo: FrequencyInfo) {
        lblNoteName.text = freqInfo.note.textValueMixed + makeSubscriptOfNumber(freqInfo.octave)
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
        
        let charSetExceptNumber = CharacterSet(charactersIn: "0123456789.").inverted
        let strComponents = string.components(separatedBy: charSetExceptNumber)
        let numberFiltered = strComponents.joined(separator: "")

        return string == numberFiltered
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let oldFreq = GlobalOsc.shared.baseFreq
        guard let text = textField.text else { return }
        guard let freq = Float(text) else {
            reloadTable(freq: 440, tuningSystem: GlobalOsc.shared.currentTuningSystem, scale: GlobalOsc.shared.currentJIScale, baseNote: GlobalOsc.shared.baseNote)
            return
        }
        
        if freq < 200 || freq > 600 {
            simpleAlert(self, message: "주파수의 범위는 200 ~ 600만 입력할 수 있습니다.", title: "범위 초과", handler: nil)
            textField.text = String(oldFreq)
            reloadTable(freq: oldFreq, tuningSystem: GlobalOsc.shared.currentTuningSystem, scale: GlobalOsc.shared.currentJIScale, baseNote: GlobalOsc.shared.baseNote)
            return
        }
        
        reloadTable(freq: freq, tuningSystem: GlobalOsc.shared.currentTuningSystem, scale: GlobalOsc.shared.currentJIScale, baseNote: GlobalOsc.shared.baseNote)
    }
}

extension FreqTableViewController {
    func setTuningDropDown() {
        tuningDropDown.dataSource = TuningSystem.allCases.map { $0.textValue }
        tuningDropDown.anchorView = btnTuningSelect
        tuningDropDown.cornerRadius = 15
        btnTuningSelect.setTitle(GlobalOsc.shared.currentTuningSystem.textValue, for: .normal)
        btnScaleSelect.isHidden = true
        tuningDropDown.selectRow(GlobalOsc.shared.currentTuningSystem.rawValue)
        
        tuningDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("선택한 아이템 : \(item)")
            print("인덱스 : \(index)")
            
            if index == 0 {
                btnScaleSelect.isHidden = true
            } else {
                btnScaleSelect.isHidden = false
            }
            
            let tuningSystem: TuningSystem = TuningSystem(rawValue: index) ?? TuningSystem.equalTemperament
            reloadTable(freq: GlobalOsc.shared.baseFreq, tuningSystem: tuningSystem, scale: GlobalOsc.shared.currentJIScale, baseNote: GlobalOsc.shared.baseNote)
            btnTuningSelect.setTitle(tuningSystem.textValue, for: .normal)
            GlobalOsc.shared.conductor.stop()
            GlobalOsc.shared.currentTuningSystem = tuningSystem
            GlobalOsc.shared.lastSelectedRow = nil
        }
    }
    
    func setScaleDropDown() {
        scaleDropDown.dataSource = Scale.allCases.map { $0.textValueMixed }
        scaleDropDown.anchorView = btnScaleSelect
        scaleDropDown.cornerRadius = 15
        scaleDropDown.selectRow(GlobalOsc.shared.currentJIScale.rawValue)
        
        scaleDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            let scale: Scale = Scale(rawValue: index) ?? Scale.C
            reloadTable(freq: GlobalOsc.shared.baseFreq, tuningSystem: GlobalOsc.shared.currentTuningSystem, scale: scale, baseNote: GlobalOsc.shared.baseNote)
            btnScaleSelect.setTitle(item, for: .normal)
            GlobalOsc.shared.conductor.stop()
            GlobalOsc.shared.currentJIScale = scale
            GlobalOsc.shared.lastSelectedRow = nil
        }
    }
    
    func setBaseNoteDropDown() {
        baseNoteDropDown.dataSource = Scale.allCases.map { key in
            if key.textValueForSharp == key.textValueForFlat {
                return key.textValueForSharp + makeSubscriptOfNumber(4)
            } else {
                return "\(key.textValueForSharp + makeSubscriptOfNumber(4)) / \(key.textValueForFlat + makeSubscriptOfNumber(4))"
            }
        }
        baseNoteDropDown.anchorView = btnBaseNoteSelect
        baseNoteDropDown.cornerRadius = 15
        baseNoteDropDown.selectRow(GlobalOsc.shared.baseNote.rawValue)
        
        baseNoteDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            let baseNote = Scale(rawValue: index) ?? Scale.A
            // baseFreq 변경
            guard let freqObj = freqArray.first(where: { $0.octave == 4 && $0.note == baseNote }) else {
                return
            }
            
            reloadTable(freq: freqObj.eachFreq, tuningSystem: GlobalOsc.shared.currentTuningSystem, scale: GlobalOsc.shared.currentJIScale, baseNote: baseNote)
            btnBaseNoteSelect.setTitle(item, for: .normal)
            GlobalOsc.shared.conductor.stop()
            GlobalOsc.shared.baseNote = baseNote
            GlobalOsc.shared.baseFreq = freqObj.eachFreq
            textA4FreqOutlet.text = String(freqObj.eachFreq.cleanFixTwo)
            GlobalOsc.shared.lastSelectedRow = nil
        }
    }
}
