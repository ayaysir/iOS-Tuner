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
        
        // Show navigation bar above side menu
        self.view.bringSubviewToFront(navigationBar)
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
