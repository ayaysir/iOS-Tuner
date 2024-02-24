//
//  SlideMenuViewController.swift
//  Tuner
//
//  Created by yoonbumtae on 2021/08/05.
//

import UIKit
import GoogleMobileAds

class MenuState {
    static let shared = MenuState()
    private init() {}
    var currentMenu = "TunerViewController"
}

class SlideMenuViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func btnFreqTable(_ sender: UIButton) {
        openController(menu: "FreqTableViewController")
    }
    
    @IBAction func btnTuner(_ sender: Any) {
        openController(menu: "TunerViewController")
    }
    
    @IBAction func btnStats(_ sender: Any) {
        openController(menu: "StatsViewController")
    }
    
    @IBAction func btnSetting(_ sender: Any) {
        openController(menu: "SettingViewController")
    }
    
    @IBAction func btnHelp(_ sender: Any) {
        openController(menu: "HelpViewController")
    }
    func openController(menu: String) {
        if MenuState.shared.currentMenu == menu {
            sideMenuController()?.sideMenu?.toggleMenu()
            return
        }
        
        MenuState.shared.currentMenu = menu
        let targetVC = self.storyboard?.instantiateViewController(identifier: menu)
        self.sideMenuController()?.setContentViewController(targetVC!)
    }
}
