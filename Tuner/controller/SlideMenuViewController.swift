//
//  SlideMenuViewController.swift
//  Tuner
//
//  Created by yoonbumtae on 2021/08/05.
//

import UIKit

protocol SlideMenuDelegate {
    func selectedMenu(_ controller: SlideMenuViewController, identifier: String)
}

class SlideMenuViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnFreqTable(_ sender: UIButton) {
        
        let targetVC = self.storyboard?.instantiateViewController(identifier: "FreqTableViewController")
        self.sideMenuController()?.setContentViewController(targetVC!)
    }
    
    
    @IBAction func btnTuner(_ sender: Any) {
        let targetVC = self.storyboard?.instantiateViewController(identifier: "TunerViewController")
        self.sideMenuController()?.setContentViewController(targetVC!)
    }
}


