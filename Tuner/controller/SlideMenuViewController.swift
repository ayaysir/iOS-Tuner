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
        print("\(sender.currentTitle!) 클릭됨.")
        
        // 사이드메뉴 닫기
//        let targetVC = self.storyboard?.instantiateViewController(identifier: "FreqTableViewController")
//        self.present(targetVC!, animated: false, completion: nil)
        
        let targetVC = self.storyboard?.instantiateViewController(identifier: "FreqTableViewController")
        self.sideMenuController()?.setContentViewController(targetVC!)
    }
    
    
}


