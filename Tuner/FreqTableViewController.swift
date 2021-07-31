//
//  FreqTableViewController.swift
//  Tuner
//
//  Created by yoonbumtae on 2021/07/31.
//

import UIKit

class FreqTableViewController: UIViewController {
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(EXP)
        drawTable()
        
        // Do any additional setup after loading the view.
    }
    
    func drawTable(baseFreq: Int = 440) {
        let indexOfA = NOTE_NAMES.firstIndex {$0 == "A"}!
        let distanceFromBaseToLowest = NOTE_NAMES.count * (BASE_OCTAVE - NOTE_START) + indexOfA
        var distIndex = 0
        // draw initial table
        for octave in NOTE_START...NOTE_END {
            for note in NOTE_NAMES {
                //                var td1 = $("<td/>")
                //                var noteName = makeNoteStr(NOTES.names[j]) + "<sub>" + i + "</sub>"
                //                if(NOTES.altNames[NOTES.names[j]]){
                //                    noteName += " / " + makeNoteStr(NOTES.altNames[NOTES.names[j]]) + "<sub>" + i + "</sub>"
                //                }
                //                td1.html(noteName)
                
                let dist = distanceFromBaseToLowest * -1 + distIndex
                distIndex += 1
                let eachFreq = Float(baseFreq) * pow(EXP, Float(dist))
                
                //                var td2 = $("<td/>", {
                //                    text: eachFreq.toFixed(2),
                //                    class: "td-of-freq",
                //                    "data-dist": dist
                //                })
                //                var td3 = $("<td/>", {
                //                    text: (NOTES.speedOfSound / eachFreq).toFixed(2)
                //                })
                let speedOfSound = Float(SPEED_OF_SOUND) / eachFreq
                
                let numberOfPlaces = 2.0
                let multiplier = pow(10.0, numberOfPlaces)
                let eachFreqRounded = round(Double(eachFreq) * multiplier) / multiplier
                let speedOfSoundRounded = round(Double(speedOfSound) * multiplier) / multiplier
                print(note, octave, dist, distIndex, eachFreqRounded, speedOfSoundRounded)
                
                //                var tr = $("<tr/>", {
                //                    "onclick": "playOneNote(" + eachFreq + ", 1000, 'triangle')"
                //                })
                //                if (dist == 0) {
                //                    tr.addClass("tr-of-base-note")
                //                }
                //                tr.append(td1, td2, td3)
                //                tbody.append(tr)
                
            }
            
        }
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
