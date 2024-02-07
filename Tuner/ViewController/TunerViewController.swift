//
//  ViewController.swift
//  Tuner
//
//  Created by yoonbumtae on 2021/07/30.
//

import UIKit
import AVFoundation
import CoreAudio
import AppTrackingTransparency
import GoogleMobileAds

class TunerViewController: UIViewController {
    private var bannerView: GADBannerView!
    
    var recorder: AVAudioRecorder!
    var levelTimer = Timer()
    var displayTimer = Timer()
    
    var freqTable: [FrequencyInfo]!

    @IBOutlet weak var textFreqOutlet: UITextField!
    @IBOutlet weak var btnTuningSelect: UIButton!
    @IBOutlet weak var btnScaleSelect: UIButton!
    @IBOutlet weak var btnBaseNoteSelect: UIButton!
    @IBOutlet weak var lblRecordStatus: UILabel!
    @IBOutlet weak var btnBottomSlide: UIButton!
    @IBOutlet weak var lblJustFrequency: UILabel!
    
    @IBOutlet weak var viewIndicator: TunerIndicator!
    
    @IBOutlet weak var constrMenuButton: NSLayoutConstraint!
    @IBOutlet weak var constraintPanelLeftLeading: NSLayoutConstraint!
    @IBOutlet weak var constraintPanelRightTrailing: NSLayoutConstraint!
    @IBOutlet weak var cnstrRecordStatusBottom: NSLayoutConstraint!
    @IBOutlet weak var cnstrIndicatorCenterY: NSLayoutConstraint!
    
    @IBOutlet weak var settingView: UIView!
    @IBOutlet weak var settingAboveStackView: UIStackView!
    
    var conductor = TunerConductor()
    
    var state: TunerViewState!

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
    
    func setA4AndC4(baseNote4: Scale, freqOfBaseNote: Float) {
        conductor.data.a4Frequency = getA4Frequency_ET(baseNote4: baseNote4, frequency: freqOfBaseNote)
        conductor.data.c4Frequency = getC4Frequency_JI(prevNote4: baseNote4, prev4frequency: freqOfBaseNote, scale: state.currentJIScale)
    }
    
    func loadStateFromUserDefaults() {
        do {
            let loadedState = try UserDefaults.standard.getObject(forKey: "state-tuner", castTo: TunerViewState.self)
            self.state = loadedState
            setA4AndC4(baseNote4: state.baseNote, freqOfBaseNote: state.baseFreq)
            print("load:", state as Any, conductor.data)
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
        
        setTuningList()
        setScale()
        setBaseNote()
        
        initField()
        
        self.sideMenuController()?.sideMenu?.delegate = self
        
        AVAudioSession.sharedInstance().requestRecordPermission({ (granted) in
            // Handle granted
        })
        
        DispatchQueue.main.async {
            // 타이머는 main thread 에서 실행됨
            // 0.0167 -> 45
            // 0.05 -> 15
            self.levelTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(self.levelTimerCallback), userInfo: nil, repeats: true)
            self.displayTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(self.refreshIndicator), userInfo: nil, repeats: true)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(conductorDisappear), name: UIScene.willDeactivateNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(conductorAppear), name: UIScene.didActivateNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(conductorDisappear), name: UIApplication.willResignActiveNotification, object: nil)

        if AdSupporter.shared.showAd {
            if #available(iOS 14, *) {
                ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                })
            }
            self.setupBannerView()
        }
        
        lblRecordStatus.text = ""
        
        btnScaleSelect.setBackgroundColor(UIColor(named: "button-disabled") ?? UIColor.systemGray, for: .disabled)
        
        viewIndicator.layer.drawsAsynchronously = true
        viewIndicator.layer.shouldRasterize = true
        
        if UIDevice.current.orientation.isLandscape {
            changeLandscapeMode()
        }
        
        // 키보드 밖 클릭하면 없어지게 하기
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(doneChangeFrequencey))
        view.addGestureRecognizer(tapRecognizer)
        
        // 실행횟수 기록
        let visited = UserDefaults.standard.integer(forKey: "TunerVC_Visitied")
        UserDefaults.standard.set(visited + 1, forKey: "TunerVC_Visited")
    }
    
    @objc func doneChangeFrequencey() {
        view.endEditing(true)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if UIDevice.current.orientation.isLandscape {
            print("landscape")
            changeLandscapeMode()
        } else {
            print("portrait")
            changePortraitMode()
        }
    }
    
    func changeLandscapeMode() {
        cnstrIndicatorCenterY.constant += 80
    }
    
    func changePortraitMode() {
        cnstrIndicatorCenterY.constant -= 80
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
        
        print("tuning conductor stopped")
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
    @objc func refreshIndicator() {
        viewIndicator.state = conductor.data
    }
    
    @objc func levelTimerCallback() {
        
        // TODO: - 분리
        let R_BLOCK = 5
        
        dBMonitor.append(conductor.data.dB)
        centMonitor.append(conductor.data.centDist)
        freqMonitor.append(conductor.data.pitch)
        octaveMonitor.append(Float(conductor.data.octave))
        noteMonitor.append(conductor.data.note)
        standardFreqMonitor.append(conductor.data.standardFreq)
        
        if octaveMonitor.count == R_BLOCK {
            monitorCount += R_BLOCK
            lblJustFrequency.text = String(dBMonitor.std())
            
            // 4.5초 (270회) 기록
            // 중간에 0.75초 이상 중지시 취소
            // 4.5초동안 아래 조건이 true인 경우의 평균, 표준편차 기록
            
            let condition = octaveMonitor.std() == 0
               // && (freqMonitor.std() <= 0.3 || centMonitor.std() <= 0.12 || dBMonitor.std() <= 0.5)
            
            if condition {
                conductor.data.isStdSmooth = true
                monitorContinousCount += R_BLOCK
                
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
                // 여기서 지우지 않으면 찌꺼기가 남는다
                // == reset == //
                freqRecord45 = []
                centRecord45 = []
                octaveRecord45 = []
                noteRecord45 = []
                standardFreq45 = []
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
            
            if isRecordingOn && freqRecord45.count % 20 == 0 {
                lblRecordStatus.text = countdown == 0 ? "기록중".localized : String(countdown)
                lblRecordStatus.textColor = UIColor.lightGray
                lblRecordStatus.doGlow(withColor: UIColor.lightGray)
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
                lblRecordStatus.textColor = UIColor.orange
                lblRecordStatus.doGlow(withColor: UIColor.orange)
                lblRecordStatus.text = "기록 실패".localized
                
            } else if isRecordingOn && freqRecord45.count == 75 {
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
                
                var configLeftRangeNum: Int? {
                    do {
                        let noteNum = try UserDefaults.standard.getObject(forKey: "config-rangeLeft", castTo: NoteRangeConfig.self).noteNum
                        return noteNum
                    } catch {
                        print(error.localizedDescription)
                        return nil
                    }
                }
                
                var configRightRangeNum: Int? {
                    do {
                        let noteNum = try UserDefaults.standard.getObject(forKey: "config-rangeRight", castTo: NoteRangeConfig.self).noteNum
                        return noteNum
                    } catch {
                        print(error.localizedDescription)
                        return nil
                    }
                }
                
                let maxNoteNum = maxNote.rawValue + (12 * maxOctave)
                let rangeCondition = (configLeftRangeNum != nil && configRightRangeNum != nil) ? (configLeftRangeNum! <= maxNoteNum && maxNoteNum <= configRightRangeNum!) : true
                let totalCents = getCents(frequency: freqRecord45.avg(), noteNum: Float(maxNoteNum), standardFrequency: maxStandardFreq)
                
                if maxOctave >= 0 && rangeCondition && (-50 <= totalCents && totalCents <= 50)  {
                    // core data 기록
                    let record = TunerRecord(id: UUID(), date: Date(), avgFreq: freqRecord45.avg(), stdFreq: freqRecord45.std(), standardFreq: maxStandardFreq, centDist: centRecord45.avg(), noteIndex: maxNote.rawValue, octave: maxOctave, tuningSystem: state.currentTuningSystem)
                    
                    do {
                        try saveCoreData(record: record)
                        lblRecordStatus.text = "기록 완료".localized + " (\(maxNote.textValueMixed))"
                        lblRecordStatus.textColor = #colorLiteral(red: 0.2535300891, green: 0.7974340783, blue: 0.2312508963, alpha: 1)
                        lblRecordStatus.doGlow(withColor: #colorLiteral(red: 0.2535300891, green: 0.7974340783, blue: 0.2312508963, alpha: 1))
                    } catch {
                        print("저장 에러 >>>", error.localizedDescription)
                    }
                } else {
                    print("not saved: dirty data", maxOctave)
                    lblRecordStatus.textColor = UIColor.orange
                    lblRecordStatus.doGlow(withColor: UIColor.orange)
                    lblRecordStatus.text = "기록 대상이 아닙니다.".localized
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
    }
    
    // MARK: - IBActions
    
    @IBAction func btnShowMenu(_ sender: UIButton) {
        self.toggleSideMenuView()
    }
    
    @IBAction func textFreqAct(_ sender: UITextField) {}
    
    @IBAction func btnPlusAct(_ sender: UIButton) {
        guard let text = textFreqOutlet.text else { return }
        guard let num = Float(text) else { return }
        let freq: Float = num + 1
        textFreqOutlet.text = String(freq)
        state.baseFreq = freq
        setA4AndC4(baseNote4: state.baseNote, freqOfBaseNote: freq)
    }
    
    @IBAction func btnMinusAct(_ sender: UIButton) {
        guard let text = textFreqOutlet.text else { return }
        guard let num = Float(text) else { return }
        let freq: Float = num - 1
        textFreqOutlet.text = String(freq)
        state.baseFreq = freq
        setA4AndC4(baseNote4: state.baseNote, freqOfBaseNote: freq)
    }
    
    @IBAction func btnTuningSelectAct(_ sender: UIButton) {}
    
    @IBAction func btnScaleSelectAct(_ sender: UIButton) {
        view.layoutIfNeeded()
        let buttonFrame = CGRect(
            x: sender.frame.minX,
            y: sender.frame.maxY,
            width: sender.frame.size.width,
            height: sender.frame.size.height)
        
        ChangeKeyViewController.show(self, displayKey: state.currentJIScale, buttonFrame: buttonFrame)
    }
    
    @IBAction func btnBaseNoteSelectAct(_ sender: UIButton) {
        let buttonFrame = CGRect(
            x: settingAboveStackView.frame.minX,
            y: settingAboveStackView.frame.minY + btnBaseNoteSelect.frame.size.height,
            width: btnBaseNoteSelect.frame.size.width,
            height: btnBaseNoteSelect.frame.size.height)
        
        ChangeKeyViewController.show(self, displayKey: state.baseNote, buttonFrame: buttonFrame, isAddOctave: true)
    }
 
    var isSettingViewCollapsed = false
    var moveXtoRight: CGFloat = 0
    @IBAction func btnSlideRight(_ sender: UIButton) {
        if isSettingViewCollapsed {
            constraintPanelLeftLeading.constant -= moveXtoRight
            constraintPanelRightTrailing.constant += moveXtoRight
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
        } else {
            self.moveXtoRight = settingView.frame.width - 10
            constraintPanelLeftLeading.constant += moveXtoRight
            constraintPanelRightTrailing.constant -= moveXtoRight
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
        }
        isSettingViewCollapsed = !isSettingViewCollapsed
    }
}

extension TunerViewController {
    func setTuningList() {
        // 튜닝 시스템 데이터소스
        let actions: [UIAction] = TuningSystem.allCases.map { tuningSystem in
            UIAction(title: tuningSystem.textValue.localized,
                     handler: { [unowned self, tuningSystem] action in
                btnScaleSelect.isEnabled = tuningSystem == .justIntonationMajor
                
                // 버튼 제목 설정
                btnTuningSelect.setTitle(tuningSystem.textValue.localized, for: .normal)
                state.currentTuningSystem = tuningSystem
                state.lastSelectedRow = nil
                
                // JI - PitchDetector에 스케일 정보 전달 - 튜닝, 스케일, 기본 노트(i4 주파수)
                conductor.data.tuningSystem = tuningSystem
                print(">> tuningsystem", tuningSystem)
                conductor.data.c4Frequency = getC4Frequency_JI(
                    prevNote4: state.baseNote,
                    prev4frequency: state.baseFreq,
                    scale: state.currentJIScale)
                conductor.data.jiScale = state.currentJIScale
                
                saveStateToUserDefaults()
            })
        }
        
        btnTuningSelect.showsMenuAsPrimaryAction = true
        btnTuningSelect.menu = UIMenu(
            title: "튜닝 시스템을 선택하세요",
            options: .displayInline,
            children: actions)
        
        conductor.data.tuningSystem = state.currentTuningSystem
        conductor.data.c4Frequency = getC4Frequency_JI(
            prevNote4: state.baseNote,
            prev4frequency: state.baseFreq,
            scale: state.currentJIScale)
        
        // 버튼 제목 설정
        btnTuningSelect.setTitle(state.currentTuningSystem.textValue.localized, for: .normal)
        btnScaleSelect.isEnabled = (state.currentTuningSystem != .equalTemperament)
    }
    
    func setScale() {
        btnScaleSelect.setTitle(state.currentJIScale.textValueMixed, for: .normal)
        conductor.data.jiScale = state.currentJIScale
    }
    
    func setBaseNote() {
        btnBaseNoteSelect.setTitle(state.baseNote.textValueMixedAttach4, for: .normal)
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
            simpleAlert(self, message: "주파수의 범위는 200 ~ 600Hz만 입력할 수 있습니다.".localized, title: "범위 초과".localized, handler: nil)
            textField.text = String(oldFreq)
            return
        }
        
        state.baseFreq = freq
        setA4AndC4(baseNote4: state.baseNote, freqOfBaseNote: freq)
    }
}

extension TunerViewController: ENSideMenuDelegate {
    // MARK: - ENSideMenu Delegate
    func sideMenuWillOpen() {}
    
    func sideMenuWillClose() {}
    
    func sideMenuShouldOpenSideMenu() -> Bool {
        true
    }
    
    func sideMenuDidClose() {}
    
    func sideMenuDidOpen() {}
}

extension TunerViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        .none
    }

    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {}

    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        true
    }
}

extension TunerViewController: ChangeKeyVCDelegate {
    func didSelectedKey(_ controller: ChangeKeyViewController, key: Scale, isLimitedOctave: Bool) {
        // print(key, isLimitedOctave)
        if isLimitedOctave {
            // 베이스 노트
            btnBaseNoteSelect.setTitle(key.textValueMixedAttach4, for: .normal)
            
            let baseFreq = getOctave4Frequency_ET(
                targetNote4: key,
                prevNote4: state.baseNote,
                prev4frequency: state.baseFreq)
            let a4Freq = getA4Frequency_ET(baseNote4: key, frequency: baseFreq)
        
            state.baseNote = key
            state.baseFreq = baseFreq
            textFreqOutlet.text = String(baseFreq.cleanFixTwo)
            conductor.data.a4Frequency = a4Freq
        
            // JI - PitchDetector에 스케일 정보 전달 - 튜닝, 스케일, 기본 노트(i4 주파수)
            conductor.data.tuningSystem = state.currentTuningSystem
            conductor.data.c4Frequency = getC4Frequency_JI(
                prevNote4: key,
                prev4frequency: baseFreq,
                scale: state.currentJIScale)
            conductor.data.jiScale = state.currentJIScale
        } else {
            // 순정 스케일
            btnScaleSelect.setTitle(key.textValueMixed, for: .normal)
            
            state.currentJIScale = key
            state.lastSelectedRow = nil
            
            // JI - PitchDetector에 스케일 정보 전달 - 튜닝, 스케일, 기본 노트(i4 주파수)
            conductor.data.tuningSystem = state.currentTuningSystem
            conductor.data.c4Frequency = getC4Frequency_JI(
                prevNote4: state.baseNote,
                prev4frequency: state.baseFreq,
                scale: key)
            conductor.data.jiScale = key
        }
        
        saveStateToUserDefaults()
    }
}

// ============ 애드몹 셋업 ============
extension TunerViewController: GADBannerViewDelegate {
    /// 1. 본 클래스 멤버 변수로 다음 선언 추가
    /// `private var bannerView: GADBannerView!`
    ///
    /// 2. viewDidLoad()에 다음 추가
    /// `setupBannerView()`
    private func setupBannerView() {
        let adSize = GADAdSizeFromCGSize(CGSize(width: self.view.frame.width, height: 50))
        self.bannerView = GADBannerView(adSize: adSize)
        addBannerViewToView(bannerView)
        bannerView.adUnitID = AdSupporter.shared.TUNER_AD_CODE
        // bannerView.adUnitID = AdSupporter.shared.TEST_CODE
        print("adUnitID: ", bannerView.adUnitID!)
        bannerView.rootViewController = self
        let request = GADRequest()
        bannerView.load(request)
        bannerView.delegate = self
    }
    
    private func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints( [NSLayoutConstraint(item: bannerView, attribute: .bottom, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0), NSLayoutConstraint(item: bannerView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0) ])
    }
    
    // GADBannerViewDelegate
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("GAD: \(#function)")
        // 버튼 constraint 50
        constrMenuButton.constant -= 50
        cnstrRecordStatusBottom.constant += 50
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print("GAD: \(#function)", error)
    }
    
    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("GAD: \(#function)")
    }
    
    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("GAD: \(#function)")
    }
    
    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("GAD: \(#function)")
    }
}
