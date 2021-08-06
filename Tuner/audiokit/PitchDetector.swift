import AudioKit
import AudioKitEX
import AudioToolbox
import SoundpipeAudioKit

struct TunerData {
    var pitch: Float = 0.0
    var amplitude: Float = 0.0
    var noteNameWithSharps = "-"
    var noteNameWithFlats = "-"
    var note: Scale = Scale.C
    var noteNum: Float = 0.0
    var octave: Int = 0
    var standardFreq: Float = 0.0
    var centDist: Float = 0.0
}

class TunerConductor: ObservableObject {
    let engine = AudioEngine()
    var mic: AudioEngine.InputNode
    var tappableNode1: Fader
    var tappableNodeA: Fader
    var tappableNode2: Fader
    var tappableNodeB: Fader
    var tappableNode3: Fader
    var tappableNodeC: Fader
    var tracker: PitchTap!
    var silence: Fader
    
    let noteFrequencies = [16.3516, 17.32391, 18.35404, 19.44544, 20.60172, 21.82676, 23.12465, 24.49971, 25.95654, 27.5, 29.13524, 30.86771]
    let noteNamesWithSharps = ["C", "C♯", "D", "D♯", "E", "F", "F♯", "G", "G♯", "A", "A♯", "B"]
    let noteNamesWithFlats = ["C", "D♭", "D", "E♭", "E", "F", "G♭", "G", "A♭", "A", "B♭", "B"]
    let semitone = 69
    
    var data = TunerData()
    
    init() {
        guard let input = engine.input else {
            fatalError()
        }

        mic = input
        tappableNode1 = Fader(mic)
        tappableNode2 = Fader(tappableNode1)
        tappableNode3 = Fader(tappableNode2)
        tappableNodeA = Fader(tappableNode3)
        tappableNodeB = Fader(tappableNodeA)
        tappableNodeC = Fader(tappableNodeB)
        silence = Fader(tappableNodeC, gain: 0)
        engine.output = silence
        
        tracker = PitchTap(mic) { pitch, amp in
            DispatchQueue.main.async {
                self.update(pitch[0], amp[0])
            }
        }
    }
    
    func getNote(frequency: Float) -> Float {
        let note = 12 * (log(frequency / 440) / log(2))
        return roundf(note) + Float(semitone)
    }
    
    func getStandardFrequency(noteNum: Float) -> Float {
        let exponent = (noteNum - Float(semitone)) / 12
        return 440 * Float(truncating: pow(2, exponent) as NSNumber)
    }

    func getCents(frequency: Float, noteNum: Float) -> Float {
        return floor((1200 * log(frequency / getStandardFrequency(noteNum: noteNum))) / log(2.0))
    }
    
    func update(_ pitch: AUValue, _ amp: AUValue) {
        data.pitch = pitch
        data.amplitude = amp

//        var frequency = pitch
//        while frequency > Float(noteFrequencies[noteFrequencies.count - 1]) {
//            frequency /= 2.0
//        }
//        while frequency < Float(noteFrequencies[0]) {
//            frequency *= 2.0
//        }
//
//        var minDistance: Float = 10_000.0
//        var index = 0
//
//        for possibleIndex in 0 ..< noteFrequencies.count {
//            let distance = fabsf(Float(noteFrequencies[possibleIndex]) - frequency)
//            if distance < minDistance {
//                index = possibleIndex
//                minDistance = distance
//            }
//        }
//        let octave = Int(log2f(pitch / frequency))
//
//        data.octave = octave
//        data.noteNum = getNote(frequency: pitch)
//        data.note = Scale(rawValue: index)!
//        data.noteNameWithSharps = "\(noteNamesWithSharps[index])\(octave)"
//        data.noteNameWithFlats = "\(noteNamesWithFlats[index])\(octave)"
        
        let noteNum = getNote(frequency: pitch)
        data.octave = Int(noteNum / 12) - 1
        data.note = Scale(rawValue: Int(noteNum) % 12)!
        data.noteNum = noteNum
        data.noteNameWithSharps = "\(noteNamesWithSharps[data.note.rawValue])\(data.octave)"
        data.noteNameWithSharps = "\(noteNamesWithFlats[data.note.rawValue])\(data.octave)"
        data.standardFreq = getStandardFrequency(noteNum: noteNum)
        data.centDist = getCents(frequency: pitch, noteNum: noteNum)
        
//        print(noteNum, getStandardFrequency(noteNum: noteNum), getCents(frequency: pitch, noteNum: noteNum))
    }
    
    func start() {

        do {
            try engine.start()
            tracker.start()
        } catch let err {
            Log(err)
        }
    }

    func stop() {
        engine.stop()
    }
}


/**
 https://github.com/qiuxiang/tuner/blob/master/app/tuner.js
 /**
  * get musical note from frequency
  *
  * @param {number} frequency
  * @returns {number}
  */
 Tuner.prototype.getNote = function(frequency) {
   const note = 12 * (Math.log(frequency / this.middleA) / Math.log(2))
   return Math.round(note) + this.semitone
 }

 /**
  * get the musical note's standard frequency
  *
  * @param note
  * @returns {number}
  */
 Tuner.prototype.getStandardFrequency = function(note) {
   return this.middleA * Math.pow(2, (note - this.semitone) / 12)
 }

 /**
  * get cents difference between given frequency and musical note's standard frequency
  *
  * @param {number} frequency
  * @param {number} note
  * @returns {number}
  */
 Tuner.prototype.getCents = function(frequency, note) {
   return Math.floor(
     (1200 * Math.log(frequency / this.getStandardFrequency(note))) / Math.log(2)
   )
 }
 
 Tuner.prototype.startRecord = function () {
   const self = this
   navigator.mediaDevices
     .getUserMedia({ audio: true })
     .then(function(stream) {
       self.audioContext.createMediaStreamSource(stream).connect(self.analyser)
       self.analyser.connect(self.scriptProcessor)
       self.scriptProcessor.connect(self.audioContext.destination)
       self.scriptProcessor.addEventListener('audioprocess', function(event) {
         const frequency = self.pitchDetector.do(
           event.inputBuffer.getChannelData(0)
         )
         if (frequency && self.onNoteDetected) {
           const note = self.getNote(frequency)
           self.onNoteDetected({
             name: self.noteStrings[note % 12],
             value: note,
             cents: self.getCents(frequency, note),
             octave: parseInt(note / 12) - 1,
             frequency: frequency
           })
         }
       })
     })
     .catch(function(error) {
       alert(error.name + ': ' + error.message)
     })
 }
 
 */
