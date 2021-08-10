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
    
    var state: TunerViewState!
    
    func loadStateFromUserDefaults() {
        do {
            let loadedState = try UserDefaults.standard.getObject(forKey: "state-freqTable", castTo: TunerViewState.self)
            self.state = loadedState
        } catch {
            print(error.localizedDescription)
            self.state = TunerViewState()
        }
    }
    
    func saveStateToUserDefaults() {
        do {
            try UserDefaults.standard.setObject(state, forKey: "state-freqTable")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function)
        loadStateFromUserDefaults()
        
        setTuningDropDown()
        setScaleDropDown()
        setBaseNoteDropDown()
        
        print(EXP)
        reloadTable(freq: state.baseFreq, tuningSystem: state.currentTuningSystem, scale: state.currentJIScale, baseNote: state.baseNote)
        textA4FreqOutlet.text = String(state.baseFreq)
        
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
        let isShoudReplay = state.isShouldReplay
        if !isOn && isShoudReplay {
            GlobalOsc.shared.conductor.start()
            let lastFreq = GlobalOsc.shared.conductor.data.frequency
            GlobalOsc.shared.conductor.noteOn(frequency: lastFreq)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print(#function)
        conductorAppear()
        let replayRow = state.replayRow
        if replayRow != -1 {
            tblFreqList.selectRow(at: IndexPath(row: replayRow, section: 0), animated: false, scrollPosition: UITableView.ScrollPosition.top)
            state.lastSelectedRow = replayRow
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print(#function)
        saveStateToUserDefaults()
        conductorDisappear()
    }
    
    func reloadTable(freq: Float, tuningSystem: TuningSystem, scale: Scale, baseNote: Scale) {
        let oldBaseFreq = state.baseFreq
        freqArray = makeFreqArray(tuningSystem: tuningSystem, baseFreq: freq, scale: scale, baseNote: baseNote)
        tblFreqList.reloadData()
        if GlobalOsc.shared.conductor.osc.amplitude != 0.0 && state.lastSelectedRow != nil {
            let lastFreq = GlobalOsc.shared.conductor.data.frequency
            GlobalOsc.shared.conductor.noteOn(frequency:  lastFreq + freq - oldBaseFreq)
            state.isShouldReplay = true
        }
        state.baseFreq = freq
        state.currentTuningSystem = tuningSystem
    }
    
    @IBAction func btnPlusAct(_ sender: Any) {
        guard let text = textA4FreqOutlet.text else { return }
        guard let num = Float(text) else { return }
        textA4FreqOutlet.text = String(num + 1)
        reloadTable(freq: num + 1, tuningSystem: state.currentTuningSystem, scale: state.currentJIScale, baseNote: state.baseNote)
        if state.lastSelectedRow != nil {
            tblFreqList.selectRow(at: IndexPath(row: state.lastSelectedRow!, section: 0), animated: false, scrollPosition: UITableView.ScrollPosition.none)
        }
    }
    
    @IBAction func btnMinusAct(_ sender: Any) {
        guard let text = textA4FreqOutlet.text else { return }
        guard let num = Float(text) else { return }
        textA4FreqOutlet.text = String(num - 1)
        reloadTable(freq: num - 1, tuningSystem: state.currentTuningSystem, scale: state.currentJIScale, baseNote: state.baseNote)
        if state.lastSelectedRow != nil {
            tblFreqList.selectRow(at: IndexPath(row: state.lastSelectedRow!, section: 0), animated: false, scrollPosition: UITableView.ScrollPosition.none)
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
        if state.lastSelectedRow != nil && state.lastSelectedRow! == indexPath.row {
            tableView.deselectRow(at: indexPath, animated: true)
            GlobalOsc.shared.conductor.stop()
            state.isShouldReplay = false
            state.replayRow = -1
            state.lastSelectedRow = nil
        } else {
            GlobalOsc.shared.conductor.data.isPlaying = true
            GlobalOsc.shared.conductor.start()
            GlobalOsc.shared.conductor.noteOn(frequency: freqArray[indexPath.row].eachFreq)
            state.isShouldReplay = true
            state.replayRow = indexPath.row
            state.lastSelectedRow = indexPath.row
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
        return freq_shouldChangeCharactersIn(textField, shouldChangeCharactersIn: range, replacementString: string)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let oldFreq = state.baseFreq
        guard let text = textField.text else { return }
        guard let freq = Float(text) else {
            reloadTable(freq: 440, tuningSystem: state.currentTuningSystem, scale: state.currentJIScale, baseNote: state.baseNote)
            return
        }
        
        if freq < 200 || freq > 600 {
            simpleAlert(self, message: "주파수의 범위는 200 ~ 600만 입력할 수 있습니다.", title: "범위 초과", handler: nil)
            textField.text = String(oldFreq)
            reloadTable(freq: oldFreq, tuningSystem: state.currentTuningSystem, scale: state.currentJIScale, baseNote: state.baseNote)
            return
        }
        
        reloadTable(freq: freq, tuningSystem: state.currentTuningSystem, scale: state.currentJIScale, baseNote: state.baseNote)
    }
}

extension FreqTableViewController {
    func setTuningDropDown() {
        tuningDropDown.dataSource = TuningSystem.allCases.map { $0.textValue }
        tuningDropDown.anchorView = btnTuningSelect
        tuningDropDown.cornerRadius = 15
        btnTuningSelect.setTitle(state.currentTuningSystem.textValue, for: .normal)
        btnScaleSelect.isHidden = (state.currentTuningSystem == .equalTemperament)
        tuningDropDown.selectRow(state.currentTuningSystem.rawValue)
        
        tuningDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("선택한 아이템 : \(item)")
            print("인덱스 : \(index)")
            
            if index == 0 {
                btnScaleSelect.isHidden = true
            } else {
                btnScaleSelect.isHidden = false
            }
            
            let tuningSystem: TuningSystem = TuningSystem(rawValue: index) ?? TuningSystem.equalTemperament
            reloadTable(freq: state.baseFreq, tuningSystem: tuningSystem, scale: state.currentJIScale, baseNote: state.baseNote)
            btnTuningSelect.setTitle(tuningSystem.textValue, for: .normal)
            GlobalOsc.shared.conductor.stop()
            state.currentTuningSystem = tuningSystem
            state.lastSelectedRow = nil
        }
    }
    
    func setScaleDropDown() {
        scaleDropDown.dataSource = Scale.allCases.map { $0.textValueMixed }
        scaleDropDown.anchorView = btnScaleSelect
        scaleDropDown.cornerRadius = 15
        scaleDropDown.selectRow(state.currentJIScale.rawValue)
        btnScaleSelect.setTitle(state.currentJIScale.textValueMixed, for: .normal)
        
        scaleDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            let scale: Scale = Scale(rawValue: index) ?? Scale.C
            reloadTable(freq: state.baseFreq, tuningSystem: state.currentTuningSystem, scale: scale, baseNote: state.baseNote)
            btnScaleSelect.setTitle(item, for: .normal)
            GlobalOsc.shared.conductor.stop()
            state.currentJIScale = scale
            state.lastSelectedRow = nil
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
        baseNoteDropDown.selectRow(state.baseNote.rawValue)
        btnBaseNoteSelect.setTitle(baseNoteDropDown.dataSource[state.baseNote.rawValue], for: .normal)
        
        baseNoteDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            let baseNote = Scale(rawValue: index) ?? Scale.A
            // baseFreq 변경
            guard let freqObj = freqArray.first(where: { $0.octave == 4 && $0.note == baseNote }) else {
                return
            }
            
            reloadTable(freq: freqObj.eachFreq, tuningSystem: state.currentTuningSystem, scale: state.currentJIScale, baseNote: baseNote)
            btnBaseNoteSelect.setTitle(item, for: .normal)
            GlobalOsc.shared.conductor.stop()
            state.baseNote = baseNote
            state.baseFreq = freqObj.eachFreq
            textA4FreqOutlet.text = String(freqObj.eachFreq.cleanFixTwo)
            state.lastSelectedRow = nil
        }
    }
}
