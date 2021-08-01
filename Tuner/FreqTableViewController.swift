//
//  FreqTableViewController.swift
//  Tuner
//
//  Created by yoonbumtae on 2021/07/31.
//

import UIKit

class FreqTableViewController: UIViewController {
    
    var freqArray: [FrequencyInfo] = []
    
    // tableview 최근 선택 행
    var lastSelectedRow: Int?
    
    let NOTE_NAMES = ["C", "C♯", "D", "D♯", "E", "F", "F♯", "G", "G♯", "A", "A♯", "B"]
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
    
    let conductor = DynamicOscillatorConductor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(EXP)
        makeFreqArray()
        
        // Do any additional setup after loading the view.
    }
    
    func makeFreqArray(baseFreq: Int = 440) {
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
                print(note, octave, dist, distIndex, eachFreqRounded, speedOfSoundRounded)
                freqArray.append(FrequencyInfo(note: note, octave: octave, distanceFromBaseFreq: dist, eachFreq: Double(eachFreq), speedOfSound: Double(speedOfSound)))
                
                // Base note (440)의 경우 하이라이트
                
            }
        }
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
            self.conductor.noteOff()
            lastSelectedRow = nil
        } else {
            self.conductor.data.isPlaying = true
            self.conductor.start()
            self.conductor.noteOn(frequency: freqArray[indexPath.row].eachFreq)
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
