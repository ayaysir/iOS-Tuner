//
//  ViewController.swift
//  Tuner
//
//  Created by yoonbumtae on 2021/07/30.
//

import UIKit
import AVFoundation
import CoreAudio

class ViewController: UIViewController {
    
    var recorder: AVAudioRecorder!
    var levelTimer = Timer()

    @IBOutlet weak var lblFreq: UILabel!
    
    var conductor = TunerConductor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    }
    
    @IBAction func btnTempFreqTable(_ sender: Any) {
        
    }
    
    @IBAction func btnShowMenu(_ sender: Any) {
        self.toggleSideMenuView()
    }
    
    func initRecord() {
        
        switch AVAudioSession.sharedInstance().recordPermission {
        case AVAudioSession.RecordPermission.granted:
            record()
        case AVAudioSession.RecordPermission.denied:
            recordNotAllowed()
        case AVAudioSession.RecordPermission.undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission({ (granted) in
                print(granted)
                if granted {
                    // timer는 main thread 에서 실행됨
                    // 그러나 requestRecordPermission 의 클로저 함수는 별도의 스레드에서 실행되므로
                    // 강제로 main 에서 실행되도록 한다.
                    DispatchQueue.main.sync {
                        self.record()
                    }
                } else {
                    self.recordNotAllowed()
                }
            })
        default:
            break
        }
    }
    
    
    func recordNotAllowed() {
        print("permission denied")
    }
    
    func record() {
        
        let audioSession = AVAudioSession.sharedInstance()
        
        // userDomainMask에 녹음 파일 생성
        let documents = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0])
        let url = documents.appendingPathComponent("record.caf")
        print("이 URL을 복사한 뒤 Finder - '이동' 메뉴 - '폴더로 가기'를 사용해 이동하세요.",
              documents.absoluteString.replacingOccurrences(of: "file://", with: "")
        )
        
        // 녹음 세팅
        let recordSettings: [String: Any] = [
            AVFormatIDKey:              kAudioFormatAppleIMA4,
            AVSampleRateKey:            16000, // 44100.0(표준), 32kHz, 24, 16, 12
            AVNumberOfChannelsKey:      1, // 1: 모노 2: 스테레오(표준)
            AVEncoderBitRateKey:        9600, // 32k, 96, 128(표준), 160, 192, 256, 320
            AVLinearPCMBitDepthKey:     8, // 4, 8, 11, 12, 16(표준), 18,
            AVEncoderAudioQualityKey:   AVAudioQuality.max.rawValue
        ]
        
        do {
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord)
            try audioSession.setActive(true)
            try recorder = AVAudioRecorder(url:url, settings: recordSettings)
        } catch {
            return
        }
        
        recorder.prepareToRecord()
        recorder.isMeteringEnabled = true
        recorder.record()
        

    }
}

extension ViewController: ENSideMenuDelegate {
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
