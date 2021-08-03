//
//  FreqTableViewController.swift
//  Tuner
//
//  Created by yoonbumtae on 2021/07/31.
//

import UIKit

class GlobalOscillator {
    static let sharedInstance = GlobalOscillator()
    let conductor = DynamicOscillatorConductor()
    var isShoudReplay: Bool = false
    var replayRow: Int = -1
}

class FreqTableViewController: UIViewController {
    
    var freqArray: [FrequencyInfo] = []
    
    var baseFreq: Int = 440
    var baseAmplitude: Double = 0.5
    
    @IBOutlet weak var textA4FreqOutlet: UITextField!
    @IBOutlet weak var tblFreqList: UITableView!
    @IBOutlet weak var selectBackgroundPlay: UISwitch!
    
    // tableview 최근 선택 행
    var lastSelectedRow: Int?
    
    let NOTE_NAMES = ["C", "C♯ / D♭", "D", "D♯ / E♭", "E", "F", "F♯ / G♭", "G", "G♯ / A♭", "A", "A♯ / B♭", "B"]
    let ALT_NOTE_NAMES: [String: String] = [
        "C♯": "D♭",
        "D♯": "E♭",
        "F♯": "G♭",
        "G♯": "A♭",
        "A♯": "B♭"
    ]
    let BASE_NOTE = "A"
    let BASE_OCTAVE = 4
    let SPEED_OF_SOUND = 34500
    let EXP = pow(2, (1 / 12) as Float)
    let NOTE_START = 1
    let NOTE_END = 7
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(EXP)
        makeFreqArray()
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
            GlobalOscillator.sharedInstance.conductor.stop()
        }
    }
    
    @objc func conductorAppear() {
        print(">> active")
        let isOn = UserDefaults.standard.bool(forKey: "freq-bg-play")
        let isShoudReplay = GlobalOscillator.sharedInstance.isShoudReplay
        if !isOn && isShoudReplay {
            GlobalOscillator.sharedInstance.conductor.start()
            let lastFreq = GlobalOscillator.sharedInstance.conductor.data.frequency
            GlobalOscillator.sharedInstance.conductor.noteOn(frequency: lastFreq)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print(#function)
        conductorAppear()
        let replayRow = GlobalOscillator.sharedInstance.replayRow
        if replayRow != -1 {
            tblFreqList.selectRow(at: IndexPath(row: replayRow, section: 0), animated: false, scrollPosition: UITableView.ScrollPosition.top)
            lastSelectedRow = replayRow
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print(#function)
        conductorDisappear()
    }
    
    func makeFreqArray(baseFreq: Int = 440) {
        freqArray = []
        let indexOfA = NOTE_NAMES.firstIndex {$0 == "A"}!
        let distanceFromBaseToLowest = NOTE_NAMES.count * (BASE_OCTAVE - NOTE_START) + indexOfA
        var distIndex = 0
        // draw initial table
        for octave in NOTE_START...NOTE_END {
            for note in NOTE_NAMES {
                // 노트 옆에 옥타브를 아래 첨자로 표시
                // 이명동음의 경우 / 로 구분해 표시
                
                let dist = distanceFromBaseToLowest * -1 + distIndex
                distIndex += 1
                let eachFreq = Float(baseFreq) * pow(EXP, Float(dist))
                
                let speedOfSound = Float(SPEED_OF_SOUND) / eachFreq
                
                let numberOfPlaces = 2.0
                let multiplier = pow(10.0, numberOfPlaces)
                let eachFreqRounded = round(Double(eachFreq) * multiplier) / multiplier
                let speedOfSoundRounded = round(Double(speedOfSound) * multiplier) / multiplier
//                print(note, octave, dist, distIndex, eachFreqRounded, speedOfSoundRounded)
                freqArray.append(FrequencyInfo(note: note, octave: octave, distanceFromBaseFreq: dist, eachFreq: eachFreq, speedOfSound: Double(speedOfSound)))
                
                // Base note (440)의 경우 하이라이트
                
            }
        }
    }
    
    func reloadTable(freq: Int) {
        let oldBaseFreq = baseFreq
        makeFreqArray(baseFreq: freq)
        tblFreqList.reloadData()
        if GlobalOscillator.sharedInstance.conductor.osc.amplitude != 0.0 {
            let lastFreq = GlobalOscillator.sharedInstance.conductor.data.frequency
            GlobalOscillator.sharedInstance.conductor.noteOn(frequency:  lastFreq + Float(freq - oldBaseFreq))
            GlobalOscillator.sharedInstance.isShoudReplay = true
        }
        baseFreq = freq
    }
    
    @IBAction func btnPlusAct(_ sender: Any) {
        guard let text = textA4FreqOutlet.text else { return }
        guard let num = Int(text) else { return }
        textA4FreqOutlet.text = String(num + 1)
        reloadTable(freq: num + 1)
        if lastSelectedRow != nil {
            tblFreqList.selectRow(at: IndexPath(row: lastSelectedRow!, section: 0), animated: false, scrollPosition: UITableView.ScrollPosition.none)
        }
    }
    
    @IBAction func btnMinusAct(_ sender: Any) {
        guard let text = textA4FreqOutlet.text else { return }
        guard let num = Int(text) else { return }
        textA4FreqOutlet.text = String(num - 1)
        reloadTable(freq: num - 1)
        if lastSelectedRow != nil {
            tblFreqList.selectRow(at: IndexPath(row: lastSelectedRow!, section: 0), animated: false, scrollPosition: UITableView.ScrollPosition.none)
        }
    }
    
    @IBAction func selectBackgroundPlayAct(_ sender: Any) {
        print(selectBackgroundPlay.isOn)
        UserDefaults.standard.setValue(selectBackgroundPlay.isOn, forKey: "freq-bg-play")
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
            GlobalOscillator.sharedInstance.conductor.noteOff()
            GlobalOscillator.sharedInstance.isShoudReplay = false
            GlobalOscillator.sharedInstance.replayRow = -1
            lastSelectedRow = nil
        } else {
            GlobalOscillator.sharedInstance.conductor.data.isPlaying = true
            GlobalOscillator.sharedInstance.conductor.start()
            GlobalOscillator.sharedInstance.conductor.noteOn(frequency: freqArray[indexPath.row].eachFreq)
            GlobalOscillator.sharedInstance.isShoudReplay = true
            GlobalOscillator.sharedInstance.replayRow = indexPath.row
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
        lblFreq.text = String(freqInfo.eachFreq)
        lblSpeedOfSound.text = String(freqInfo.speedOfSound)
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
            reloadTable(freq: 440)
            return
        }
        reloadTable(freq: freq)
    }
}
