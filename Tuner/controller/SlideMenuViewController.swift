//
//  SlideMenuViewController.swift
//  Tuner
//
//  Created by yoonbumtae on 2021/08/05.
//

import UIKit

class MenuState {
    static let shared = MenuState()
    var currentMenu = "TunerViewController"
}

class SlideMenuViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
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


