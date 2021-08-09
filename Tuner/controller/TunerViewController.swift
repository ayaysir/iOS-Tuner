//
//  ViewController.swift
//  Tuner
//
//  Created by yoonbumtae on 2021/07/30.
//

import UIKit
import AVFoundation
import CoreAudio
import DropDown

class TunerViewController: UIViewController {
    
    var recorder: AVAudioRecorder!
    var levelTimer = Timer()
    
    var freqTable: [FrequencyInfo]!

    @IBOutlet weak var lblFreq: UILabel!
    @IBOutlet weak var textFreqOutlet: UITextField!
    @IBOutlet weak var btnTuningSelect: UIButton!
    @IBOutlet weak var btnScaleSelect: UIButton!
    @IBOutlet weak var btnBaseNoteSelect: UIButton!
    @IBOutlet weak var lblOctave: UILabel!
    
    @IBOutlet weak var lblCentDist: UILabel!
    @IBOutlet weak var lblJustFrequency: UILabel!
    
    @IBOutlet weak var viewIndicator: TunerIndicator!
    
    var conductor = TunerConductor()
    
    let tuningDropDown = DropDown()
    let scaleDropDown = DropDown()
    let baseNoteDropDown = DropDown()
    
    var state: TunerViewState!
    
    func loadStateFromUserDefaults() {
        do {
            let loadedState = try UserDefaults.standard.getObject(forKey: "state-tuner", castTo: TunerViewState.self)
            self.state = loadedState
        } catch {
            print(error.localizedDescription)
            self.state = TunerViewState()
        }
    }
    
    func saveStateToUserDefaults() {
        do {
            try UserDefaults.standard.setObject(state, forKey: "state-tuner")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadStateFromUserDefaults()
        
        setTuningDropDown()
        setScaleDropDown()
        setBaseNoteDropDown()
        
        initField()
        
        self.sideMenuController()?.sideMenu?.delegate = self
        
        // Do any additional setup after loading the view.
        AVAudioSession.sharedInstance().requestRecordPermission({ (granted) in
            // Handle granted
        })
        DispatchQueue.main.async {
            // 타이머는 main thread 에서 실행됨
            self.levelTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.levelTimerCallback), userInfo: nil, repeats: true)
        }
    }
    
    func initField() {
        textFreqOutlet.text = String(state.baseFreq.cleanFixTwo)
        textFreqOutlet.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        conductor.start()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        conductor.stop()
        saveStateToUserDefaults()
    }
    
    /**
     === 타이머 갱신 ===
     */
    @objc func levelTimerCallback() {
        lblFreq.text = "\(Int(round(conductor.data.pitch)))"
        lblOctave.text = "\(conductor.data.noteNameWithSharps)"
        lblCentDist.text = String(Int(conductor.data.centDist))
        viewIndicator.state = conductor.data
        
        lblJustFrequency.text = String(getStandardFrequency_JI(noteNum: conductor.data.noteNum, c4Frequency: conductor.data.c4Frequency, scale: state.currentJIScale))
    }
    
    @IBAction func btnShowMenu(_ sender: Any) {
        self.toggleSideMenuView()
    }
    
    @IBAction func textFreqAct(_ sender: UITextField) {
        
    }
    
    
    @IBAction func btnPlusAct(_ sender: Any) {
        guard let text = textFreqOutlet.text else { return }
        guard let num = Float(text) else { return }
        textFreqOutlet.text = String(num + 1)
    }
    
    @IBAction func btnMinusAct(_ sender: Any) {
        guard let text = textFreqOutlet.text else { return }
        guard let num = Float(text) else { return }
        textFreqOutlet.text = String(num - 1)
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

extension TunerViewController {
    func setTuningDropDown() {
        tuningDropDown.dataSource = TuningSystem.allCases.map { $0.textValue }
        tuningDropDown.anchorView = btnTuningSelect
        tuningDropDown.cornerRadius = 15
        btnTuningSelect.setTitle(state.currentTuningSystem.textValue, for: .normal)
        btnScaleSelect.isHidden = (state.currentTuningSystem == .equalTemperament)
        tuningDropDown.selectRow(state.currentTuningSystem.rawValue)
        
        conductor.data.tuningSystem = state.currentTuningSystem
        conductor.data.c4Frequency = getC4Frequency_JI(prevNote4: state.baseNote, prev4frequency: state.baseFreq, scale: state.currentJIScale)
        
        tuningDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("선택한 아이템 : \(item)")
            print("인덱스 : \(index)")
            
            if index == 0 {
                btnScaleSelect.isHidden = true
            } else {
                btnScaleSelect.isHidden = false
            }
            
            let tuningSystem: TuningSystem = TuningSystem(rawValue: index) ?? TuningSystem.equalTemperament
            btnTuningSelect.setTitle(tuningSystem.textValue, for: .normal)
            state.currentTuningSystem = tuningSystem
            state.lastSelectedRow = nil
            
            // JI - PitchDetector에 스케일 정보 전달 - 튜닝, 스케일, 기본 노트(i4 주파수)
            conductor.data.tuningSystem = tuningSystem
            print(">> tuningsystem", tuningSystem)
            conductor.data.c4Frequency = getC4Frequency_JI(prevNote4: state.baseNote, prev4frequency: state.baseFreq, scale: state.currentJIScale)
            conductor.data.jiScale = state.currentJIScale
        }
    }
    
    func setScaleDropDown() {
        scaleDropDown.dataSource = Scale.allCases.map { $0.textValueMixed }
        scaleDropDown.anchorView = btnScaleSelect
        scaleDropDown.cornerRadius = 15
        scaleDropDown.selectRow(state.currentJIScale.rawValue)
        btnScaleSelect.setTitle(state.currentJIScale.textValueMixed, for: .normal)
        
        conductor.data.jiScale = state.currentJIScale
        
        scaleDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            let scale: Scale = Scale(rawValue: index) ?? Scale.C
            btnScaleSelect.setTitle(item, for: .normal)
            state.currentJIScale = scale
            state.lastSelectedRow = nil
            
            // JI - PitchDetector에 스케일 정보 전달 - 튜닝, 스케일, 기본 노트(i4 주파수)
            conductor.data.tuningSystem = state.currentTuningSystem
            conductor.data.c4Frequency = getC4Frequency_JI(prevNote4: state.baseNote, prev4frequency: state.baseFreq, scale: scale)
            print(">> i4frequency", conductor.data.c4Frequency)
            conductor.data.jiScale = scale
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
            print(state.baseNote, state.baseFreq)
            let baseFreq = getOctave4Frequency_ET(targetNote4: baseNote, prevNote4: state.baseNote, prev4frequency: state.baseFreq)
            let a4Freq = getA4Frequency_ET(baseNote4: baseNote, frequency: baseFreq)
            
            btnBaseNoteSelect.setTitle(item, for: .normal)
            state.baseNote = baseNote
            state.baseFreq = baseFreq
            textFreqOutlet.text = String(baseFreq.cleanFixTwo)
            conductor.data.a4Frequency = a4Freq
            
            // JI - PitchDetector에 스케일 정보 전달 - 튜닝, 스케일, 기본 노트(i4 주파수)
            conductor.data.tuningSystem = state.currentTuningSystem
            conductor.data.c4Frequency = getC4Frequency_JI(prevNote4: baseNote, prev4frequency: baseFreq, scale: state.currentJIScale)
            conductor.data.jiScale = state.currentJIScale
            
        }
    }
}

extension TunerViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return freq_shouldChangeCharactersIn(textField, shouldChangeCharactersIn: range, replacementString: string)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let oldFreq = state.baseFreq
        guard let text = textField.text else { return }
        guard let freq = Float(text) else {
            return
        }

        if freq < 200 || freq > 600 {
            simpleAlert(self, message: "주파수의 범위는 200 ~ 600만 입력할 수 있습니다.", title: "범위 초과", handler: nil)
            textField.text = String(oldFreq)
            return
        }
        
        state.baseFreq = freq
        
    }
}

extension TunerViewController: ENSideMenuDelegate {
    // MARK: - ENSideMenu Delegate
    func sideMenuWillOpen() {
        print("sideMenuWillOpen")
    }
    
    func sideMenuWillClose() {
        print("sideMenuWillClose")
    }
    
    func sideMenuShouldOpenSideMenu() -> Bool {
        print("sideMenuShouldOpenSideMenu")
        return true
    }
    
    func sideMenuDidClose() {
        print("sideMenuDidClose")
    }
    
    func sideMenuDidOpen() {
        print("sideMenuDidOpen")
    }
}

