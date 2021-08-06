//
//  ViewController.swift
//  Tuner
//
//  Created by yoonbumtae on 2021/07/30.
//

import UIKit
import AVFoundation
import CoreAudio

class TunerViewController: UIViewController {
    
    var recorder: AVAudioRecorder!
    var levelTimer = Timer()
    
    var freqTable: [FrequencyInfo]!

    @IBOutlet weak var lblFreq: UILabel!
    
    var conductor = TunerConductor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sideMenuController()?.sideMenu?.delegate = self
        
        let freqs = getBothFreqET(freq: 440)
        print(freqs)
        
        
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
