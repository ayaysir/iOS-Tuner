//
//  MenuNavigationController.swift
//  Tuner
//
//  Created by yoonbumtae on 2021/08/05.
//

import UIKit

class MenuNavigationController: ENSideMenuNavigationController {
    override func viewDidLoad() {
        // Create a table view controller
        let menuViewController = self.storyboard?.instantiateViewController(identifier: "SlideMenuViewController")
        
        
        // Create side menu
        self.sideMenu = ENSideMenu(sourceView: view, menuViewController: menuViewController!, menuPosition:.left)
        
        // Set a delegate
        self.sideMenu?.delegate = self
        
        // Configure side menu
        self.sideMenu?.menuWidth = 180.0
        self.sideMenu?.bouncingEnabled = false
        
        self.sideMenuAnimationType = .none
        
        // Show navigation bar above side menu
        self.view.bringSubviewToFront(navigationBar)
        
        // 다크모드 결정
        let mode = UserDefaults.standard.string(forKey: "config-appearance") ?? "unspecified"
        print(mode)
        switch mode {
        case "unspecified":
            UIApplication.shared.windows.forEach { window in
                window.overrideUserInterfaceStyle = .unspecified
            }
            UserDefaults.standard.setValue("unspecified", forKey: "config-appearance")
        case "light":
            UIApplication.shared.windows.forEach { window in
                window.overrideUserInterfaceStyle = .light
            }
            UserDefaults.standard.setValue("light", forKey: "config-appearance")
        case "dark":
            UIApplication.shared.windows.forEach { window in
                window.overrideUserInterfaceStyle = .dark
            }
            UserDefaults.standard.setValue("dark", forKey: "config-appearance")
        default:
            break
        }
    }
}

extension MenuNavigationController: ENSideMenuDelegate {
    func sideMenuWillOpen() {
        print("sideMenuWillOpen")
    }
    
    func sideMenuWillClose() {
        print("sideMenuWillClose")
    }
    
    func sideMenuDidClose() {
        print("sideMenuDidClose")
    }
    
    func sideMenuDidOpen() {
        print("sideMenuDidOpen")
    }
    
    func sideMenuShouldOpenSideMenu() -> Bool {
        return true
    }
}
