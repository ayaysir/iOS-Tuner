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
        let menu = "FreqTableViewController"
        if MenuState.shared.currentMenu == menu {
            sideMenuController()?.sideMenu?.toggleMenu()
            return
        }
        
        MenuState.shared.currentMenu = menu
        let targetVC = self.storyboard?.instantiateViewController(identifier: menu)
        self.sideMenuController()?.setContentViewController(targetVC!)
    }
    
    
    @IBAction func btnTuner(_ sender: Any) {
        let menu = "TunerViewController"
        if MenuState.shared.currentMenu == menu {
            sideMenuController()?.sideMenu?.toggleMenu()
            return
        }
        
        MenuState.shared.currentMenu = menu
        let targetVC = self.storyboard?.instantiateViewController(identifier: menu)
        self.sideMenuController()?.setContentViewController(targetVC!)
    }
    
    @IBAction func btnStats(_ sender: Any) {
        let menu = "StatsViewController"
        if MenuState.shared.currentMenu == menu {
            sideMenuController()?.sideMenu?.toggleMenu()
            return
        }
        
        MenuState.shared.currentMenu = menu
        let targetVC = self.storyboard?.instantiateViewController(identifier: menu)
        self.sideMenuController()?.setContentViewController(targetVC!)
    }
    
}


