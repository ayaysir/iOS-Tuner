//
//  FreqTableViewController.swift
//  Tuner
//
//  Created by yoonbumtae on 2021/07/31.
//

import UIKit
// import DropDown
// import GoogleMobileAds
import AppTrackingTransparency

class GlobalOsc {
    static let shared = GlobalOsc()
    let conductor = DynamicOscillatorConductor()
}

class FreqTableViewController: UIViewController {
    
    // private var bannerView: GADBannerView!
    
    var freqArray: [FrequencyInfo]!
    
    // let tuningDropDown = DropDown()
    // let scaleDropDown = DropDown()
    // let baseNoteDropDown = DropDown()
    
    @IBOutlet weak var textA4FreqOutlet: UITextField!
    @IBOutlet weak var tblFreqList: UITableView!
    @IBOutlet var menuScale: UICommand!
    @IBOutlet weak var btnTuningSelect: UIButton!
    @IBOutlet weak var btnScaleSelect: UIButton!
    @IBOutlet weak var btnBaseNoteSelect: UIButton!
    
    @IBOutlet weak var btnBottomSlide: UIButton!
    @IBOutlet weak var settingView: UIView!
    
    @IBOutlet weak var cnstSettingViewBottom: NSLayoutConstraint!
    @IBOutlet weak var cnstSettngViewTop: NSLayoutConstraint!
    
    @IBOutlet weak var cnstMenuBtnBottom: NSLayoutConstraint!
    @IBOutlet weak var cnstFreqTableBottom: NSLayoutConstraint!
    
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
        // textA4FreqOutlet.delegate = self
        
        // selectBackgroundPlay.isOn = UserDefaults.standard.bool(forKey: "freq-bg-play")
        
        NotificationCenter.default.addObserver(self, selector: #selector(conductorDisappear), name: UIScene.willDeactivateNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(conductorAppear), name: UIScene.didActivateNotification, object: nil)
        
        if AdSupporter.shared.showAd {
            if #available(iOS 14, *) {
                ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                })
            }
            // self.setupBannerView()
        }
        btnScaleSelect.setBackgroundColor(UIColor(named: "button-disabled") ?? UIColor.systemGray, for: .disabled)
        
        // 키보드 밖 클릭하면 없어지게 하기
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(doneChangeFrequencey))
        tapRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapRecognizer)
    }
    
    @objc func doneChangeFrequencey() {
        view.endEditing(true)
    }
    
    @objc func conductorDisappear() {
        print(">> disappear")
        // let isOn = UserDefaults.standard.bool(forKey: "freq-bg-play")
        // if !isOn {
        //     GlobalOsc.shared.conductor.stop()
        // }
    }
    
    @objc func conductorAppear() {
        print(">> active")
        // let isOn = UserDefaults.standard.bool(forKey: "freq-bg-play")
        let isOn = true
        let isShoudReplay = state.isShouldReplay
        if !isOn && isShoudReplay {
            GlobalOsc.shared.conductor.start()
            let lastFreq = GlobalOsc.shared.conductor.data.frequency
            GlobalOsc.shared.conductor.noteOn(frequency: lastFreq)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        conductorAppear()
        let replayRow = state.replayRow
        if replayRow != -1 {
            tblFreqList.selectRow(at: IndexPath(row: replayRow, section: 0), animated: false, scrollPosition: UITableView.ScrollPosition.top)
            state.lastSelectedRow = replayRow
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
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
    
    // @IBAction func selectBackgroundPlayAct(_ sender: Any) {
    //     UserDefaults.standard.setValue(selectBackgroundPlay.isOn, forKey: "freq-bg-play")
    // }
    
    @IBAction func btnToggleSideMenu(_ sender: Any) {
        self.toggleSideMenuView()
    }
    
    @IBAction func btnTuningSelectAct(_ sender: UIButton) {}
    
    @IBAction func btnScaleSelectAct(_ sender: Any) {
        // scaleDropDown.show()
    }
    
    @IBAction func btnBaseNoteSelectAct(_ sender: Any) {
        // baseNoteDropDown.show()
    }
    
    var isSettingViewUpside = false
    var upsideY: CGFloat = 0
    @IBAction func btnSlideSettingView(_ sender: UIButton) {
        // if isSettingViewUpside {
        //     cnstSettngViewTop.constant += upsideY
        //     UIView.animate(withDuration: 0.5) {
        //         self.view.layoutIfNeeded()
        //     }
        //     DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
        //         self.btnBottomSlide.setImage(UIImage(systemName: "arrowtriangle.up.fill"), for: .normal)
        //     }
        // } else {
        //     self.upsideY = settingView.frame.height - 10
        //     cnstSettngViewTop.constant -= upsideY
        //     UIView.animate(withDuration: 0.5) {
        //         self.view.layoutIfNeeded()
        //     }
        //     DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
        //         self.btnBottomSlide.setImage(UIImage(systemName: "arrowtriangle.down.fill"), for: .normal)
        //     }
        // }
        // isSettingViewUpside = !isSettingViewUpside
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableCell(withIdentifier: "freqHeader")
        return view
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
            simpleAlert(self, message: "주파수의 범위는 200 ~ 600Hz만 입력할 수 있습니다.".localized, title: "범위 초과", handler: nil)
            textField.text = String(oldFreq)
            reloadTable(freq: oldFreq, tuningSystem: state.currentTuningSystem, scale: state.currentJIScale, baseNote: state.baseNote)
            return
        }
        
        reloadTable(freq: freq, tuningSystem: state.currentTuningSystem, scale: state.currentJIScale, baseNote: state.baseNote)
    }
}

extension FreqTableViewController {
    func setTuningDropDown() {
        // 튜닝 시스템 데이터소스
        let actions: [UIAction] = TuningSystem.allCases.map { tuningSystem in
            UIAction(title: tuningSystem.textValue.localized,
                     handler: { [unowned self, tuningSystem] action in
                btnScaleSelect.isEnabled = tuningSystem == .justIntonationMajor
                
                // 버튼 제목 설정
                btnTuningSelect.setTitle(tuningSystem.textValue.localized, for: .normal)
                state.currentTuningSystem = tuningSystem
                state.lastSelectedRow = nil
                
                reloadTable(freq: state.baseFreq, tuningSystem: tuningSystem, scale: state.currentJIScale, baseNote: state.baseNote)
                btnTuningSelect.setTitle(tuningSystem.textValue.localized, for: .normal)
                GlobalOsc.shared.conductor.stop()
                state.currentTuningSystem = tuningSystem
                state.lastSelectedRow = nil
                
                saveStateToUserDefaults()
            })
        }
        
        btnTuningSelect.showsMenuAsPrimaryAction = true
        btnTuningSelect.menu = UIMenu(
            title: "튜닝 시스템을 선택하세요",
            options: .displayInline,
            children: actions)
        
        // 버튼 제목 설정
        btnTuningSelect.setTitle(state.currentTuningSystem.textValue.localized, for: .normal)
        btnScaleSelect.isEnabled = (state.currentTuningSystem != .equalTemperament)

        // tuningDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
        //     print("선택한 아이템 : \(item)")
        //     print("인덱스 : \(index)")
        //     
        //     if index == 0 {
        //         btnScaleSelect.isEnabled = false
        //     } else {
        //         btnScaleSelect.isEnabled = true
        //     }
        //     
        //     let tuningSystem: TuningSystem = TuningSystem(rawValue: index) ?? TuningSystem.equalTemperament
        //     reloadTable(freq: state.baseFreq, tuningSystem: tuningSystem, scale: state.currentJIScale, baseNote: state.baseNote)
        //     btnTuningSelect.setTitle(tuningSystem.textValue.localized, for: .normal)
        //     GlobalOsc.shared.conductor.stop()
        //     state.currentTuningSystem = tuningSystem
        //     state.lastSelectedRow = nil
        // }
    }
    
    func setScaleDropDown() {
        // scaleDropDown.dataSource = Scale.allCases.map { $0.textValueMixed }
        // scaleDropDown.anchorView = btnScaleSelect
        // scaleDropDown.cornerRadius = 15
        // scaleDropDown.selectRow(state.currentJIScale.rawValue)
        // btnScaleSelect.setTitle(state.currentJIScale.textValueMixed, for: .normal)
        // 
        // scaleDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
        //     let scale: Scale = Scale(rawValue: index) ?? Scale.C
        //     reloadTable(freq: state.baseFreq, tuningSystem: state.currentTuningSystem, scale: scale, baseNote: state.baseNote)
        //     btnScaleSelect.setTitle(item, for: .normal)
        //     GlobalOsc.shared.conductor.stop()
        //     state.currentJIScale = scale
        //     state.lastSelectedRow = nil
        // }
    }
    
    func setBaseNoteDropDown() {
        // baseNoteDropDown.dataSource = Scale.allCases.map { key in
        //     if key.textValueForSharp == key.textValueForFlat {
        //         return key.textValueForSharp + makeSubscriptOfNumber(4)
        //     } else {
        //         return "\(key.textValueForSharp + makeSubscriptOfNumber(4)) / \(key.textValueForFlat + makeSubscriptOfNumber(4))"
        //     }
        // }
        // baseNoteDropDown.anchorView = btnBaseNoteSelect
        // baseNoteDropDown.cornerRadius = 15
        // baseNoteDropDown.selectRow(state.baseNote.rawValue)
        // btnBaseNoteSelect.setTitle(baseNoteDropDown.dataSource[state.baseNote.rawValue], for: .normal)
        // 
        // baseNoteDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
        //     let baseNote = Scale(rawValue: index) ?? Scale.A
        //     // baseFreq 변경
        //     guard let freqObj = freqArray.first(where: { $0.octave == 4 && $0.note == baseNote }) else {
        //         return
        //     }
        //     
        //     reloadTable(freq: freqObj.eachFreq, tuningSystem: state.currentTuningSystem, scale: state.currentJIScale, baseNote: baseNote)
        //     btnBaseNoteSelect.setTitle(item, for: .normal)
        //     GlobalOsc.shared.conductor.stop()
        //     state.baseNote = baseNote
        //     state.baseFreq = freqObj.eachFreq
        //     textA4FreqOutlet.text = String(freqObj.eachFreq.cleanFixTwo)
        //     state.lastSelectedRow = nil
        // }
    }
}

// ============ 애드몹 셋업 ============
/*
 extension FreqTableViewController: GADBannerViewDelegate {
     // 본 클래스에 다음 선언 추가
     // // AdMob
     // private var bannerView: GADBannerView!
     
     // viewDidLoad()에 다음 추가
     // setupBannerView()
     
     private func setupBannerView() {
         let adSize = GADAdSizeFromCGSize(CGSize(width: self.view.frame.width, height: 50))
         self.bannerView = GADBannerView(adSize: adSize)
         addBannerViewToView(bannerView)
 //         bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716" // test
         bannerView.adUnitID = AdSupporter.shared.FREQTABLE_AD_CODE
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
         cnstMenuBtnBottom.constant += 50
         cnstFreqTableBottom.constant += 50
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
 */
