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

    @IBOutlet weak var textFreqOutlet: UITextField!
    @IBOutlet weak var btnTuningSelect: UIButton!
    @IBOutlet weak var btnScaleSelect: UIButton!
    @IBOutlet weak var btnBaseNoteSelect: UIButton!
    @IBOutlet weak var lblRecordStatus: UILabel!
    
    @IBOutlet weak var lblJustFrequency: UILabel!
    
    @IBOutlet weak var viewIndicator: TunerIndicator!
    
    var conductor = TunerConductor()
    
    let tuningDropDown = DropDown()
    let scaleDropDown = DropDown()
    let baseNoteDropDown = DropDown()
    
    var state: TunerViewState!

//    var monitor: [TunerData] = []
    var monitorCount: Int = 0
    var countdown: Int = 0
    var freqMonitor: [Float] = []
    var dBMonitor: [Float] = []
    var centMonitor: [Float] = []
    var octaveMonitor: [Float] = []
    var noteMonitor: [Scale] = []
    var standardFreqMonitor: [Float] = []
    
    var freqRecord45: [Float] = []
    var noteRecord45: [Scale] = []
    var centRecord45: [Float] = []
    var octaveRecord45: [Float] = []
    var standardFreq45: [Float] = []
    
    var monitorContinousCount: Int = 0
    var isRecordingOn: Bool = false
    var failedCount: Int = 0
    
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
            self.levelTimer = Timer.scheduledTimer(timeInterval: 0.0167, target: self, selector: #selector(self.levelTimerCallback), userInfo: nil, repeats: true)
            self.levelTimer.tolerance = 0.1
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(conductorDisappear), name: UIScene.willDeactivateNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(conductorAppear), name: UIScene.didActivateNotification, object: nil)
    }
    
    @objc func conductorAppear() {
        let oldData = conductor.data
        conductor = TunerConductor()
        conductor.data = oldData
        conductor.start()
    }
    
    @objc func conductorDisappear() {
        conductor.stop()
        saveStateToUserDefaults()
        levelTimer.invalidate()
    }
    
    func initField() {
        textFreqOutlet.text = String(state.baseFreq.cleanFixTwo)
        textFreqOutlet.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        conductorAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("Tuner: viewWillDisappear")
        conductorDisappear()
    }
   
    /**
     === 타이머 갱신 ===
     */
    @objc func levelTimerCallback() {
        
        // TODO: - 분리
        let R_BLOCK = 15
        
//        monitor.append(conductor.data)
        dBMonitor.append(conductor.data.dB)
        centMonitor.append(conductor.data.centDist)
        freqMonitor.append(conductor.data.pitch)
        octaveMonitor.append(Float(conductor.data.octave))
        noteMonitor.append(conductor.data.note)
        standardFreqMonitor.append(conductor.data.standardFreq)
        
        if freqMonitor.count == R_BLOCK {
            monitorCount += R_BLOCK
            lblJustFrequency.text = String(octaveMonitor.std())
            
            // 4.5초 (270회) 기록
            // 중간에 0.75초 이상 중지시 취소
            // 4.5초동안 아래 조건이 true인 경우의 평균, 표준편차 기록
            
            let condition = octaveMonitor.std() == 0 && (freqMonitor.std() <= 0.3 || centMonitor.std() <= 0.12 || dBMonitor.std() <= 0.3)
            
            if condition {
                conductor.data.isStdSmooth = true
                monitorContinousCount += 15
                
                freqRecord45.append(contentsOf: freqMonitor)
                centRecord45.append(contentsOf: centMonitor)
                octaveRecord45.append(contentsOf: octaveMonitor)
                noteRecord45.append(contentsOf: noteMonitor)
                standardFreq45.append(contentsOf: standardFreqMonitor)
            } else {
                conductor.data.isStdSmooth = false
                monitorContinousCount = 0
                if isRecordingOn {
                    failedCount += 1
                }
            }
            
            centMonitor = []
            dBMonitor = []
            freqMonitor = []
            octaveMonitor = []
            noteMonitor = []
            standardFreqMonitor = []
            
            // 연속 기록이 0.75초 true 된 경우
            if monitorContinousCount == R_BLOCK * 3 {
                isRecordingOn = true
                countdown = 3
            }
            
            if isRecordingOn && freqRecord45.count % 60 == 0 {
                lblRecordStatus.text = countdown == 0 ? "기록중" : String(countdown)
                countdown -= 1
            }
            
            if isRecordingOn && failedCount >= 1 {
                isRecordingOn = false
                failedCount = 0
                
                // == reset == //
                freqRecord45 = []
                centRecord45 = []
                octaveRecord45 = []
                noteRecord45 = []
                standardFreq45 = []
                
                countdown = 0
                lblRecordStatus.text = "failed"
                
            } else if isRecordingOn && freqRecord45.count == 270 {
                var maxOctave: Int {
                    let octaveCounts = octaveRecord45.reduce(into: [:]) { $0[$1, default:0] += 1 }
                    if let (value, count) = octaveCounts.max(by: { $0.1 < $1.1 }) {
                        print("octave:", value, count)
                        return Int(value)
                    }
                    return 0
                }
                
                var maxNote: Scale {
                    let noteCounts = noteRecord45.reduce(into: [:]) { $0[$1, default: 0] += 1 }
                    if let (value, count) = noteCounts.max(by: { $0.1 < $1.1 }) {
                        print("notes:", value, count)
                        return value
                    }
                    return Scale.C
                }
                
                var maxStandardFreq: Float {
                    let sfCounts = standardFreq45.reduce(into: [:]) { $0[$1, default: 0] += 1 }
                    if let (value, _) = sfCounts.max(by: { $0.1 < $1.1 }) {
                        return value
                    }
                    return 0
                }
                
                print("record:", freqRecord45.avg(), freqRecord45.std())
                
                if maxOctave >= 0 {
                    // core data 기록
                    let record = TunerRecord(id: UUID(), date: Date(), avgFreq: freqRecord45.avg(), stdFreq: freqRecord45.std(), standardFreq: maxStandardFreq, centDist: centRecord45.avg(), noteIndex: maxNote.rawValue, octave: maxOctave)
                    
                    do {
                        try saveCoreData(record: record)
                        print(getDocumentsDirectory())
                        lblRecordStatus.text = "기록 완료"
                    } catch {
                        print("저장 에러 >>>", error.localizedDescription)
                    }
                } else {
                    print("not saved: dirty data", maxOctave)
                    lblRecordStatus.text = ""
                }
                
                
                // == reset == //
                freqRecord45 = []
                centRecord45 = []
                octaveRecord45 = []
                noteRecord45 = []
                standardFreq45 = []
                
                isRecordingOn = false
                countdown = 0
            }
            
        }
        viewIndicator.state = conductor.data
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

