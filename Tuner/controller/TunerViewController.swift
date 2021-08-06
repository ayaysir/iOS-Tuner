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
    
    @IBOutlet weak var lblPrev: UILabel!
    @IBOutlet weak var lblNext: UILabel!
    @IBOutlet weak var lblCentDist: UILabel!
    
    var conductor = TunerConductor()
    
    var freqArray: [FrequencyInfo]!
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        conductor.start()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        conductor.stop()
    }
    
    @objc func levelTimerCallback() {
        lblFreq.text = "\(conductor.data.pitch)"
        lblOctave.text = "\(conductor.data.noteNameWithSharps)"
        
        let currentInfo = FrequencyInfo(note: conductor.data.note, octave: conductor.data.octave, eachFreq: 0, speedOfSound: 0)
        let both = getBothFreqInfo_ET(info: currentInfo)
        lblPrev.text = String(describing: both["prev"]!.note.textValueMixed)
        lblNext.text = String(describing: both["next"]!.note.textValueMixed)
        lblCentDist.text = String(conductor.data.centDist)
        
    }
    
    @IBAction func btnTempFreqTable(_ sender: Any) {
        
    }
    
    @IBAction func btnShowMenu(_ sender: Any) {
        self.toggleSideMenuView()
    }
    
    @IBAction func btnPlusAct(_ sender: Any) {
        guard let text = textFreqOutlet.text else { return }
        guard let num = Float(text) else { return }
        textFreqOutlet.text = String(num + 1)
        reloadTable(freq: num + 1, tuningSystem: state.currentTuningSystem, scale: state.currentJIScale, baseNote: state.baseNote)

    }
    
    @IBAction func btnMinusAct(_ sender: Any) {
        guard let text = textFreqOutlet.text else { return }
        guard let num = Float(text) else { return }
        textFreqOutlet.text = String(num - 1)
        reloadTable(freq: num - 1, tuningSystem: state.currentTuningSystem, scale: state.currentJIScale, baseNote: state.baseNote)
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
    
    
    func reloadTable(freq: Float, tuningSystem: TuningSystem, scale: Scale, baseNote: Scale) {
        freqArray = makeFreqArray(tuningSystem: tuningSystem, baseFreq: freq, scale: scale, baseNote: baseNote)
        state.baseFreq = freq
        state.currentTuningSystem = tuningSystem
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
            state.baseNote = baseNote
            state.baseFreq = freqObj.eachFreq
            textFreqOutlet.text = String(freqObj.eachFreq.cleanFixTwo)
            state.lastSelectedRow = nil
        }
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
