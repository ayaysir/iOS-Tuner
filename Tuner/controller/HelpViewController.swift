//
//  HelpViewController.swift
//  Tuner
//
//  Created by yoonbumtae on 2021/08/19.
//

import UIKit
import WebKit
import MessageUI

class HelpViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    
    @IBOutlet weak var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        print("OS Version:", UIDevice.current.systemVersion)
        loadHelpPage()
    }
    
    func loadHelpPage() {
        // 웹 파일 로딩
        webView.uiDelegate = self
        webView.navigationDelegate = self

        let pageName = "help-kor"
        guard let url = Bundle.main.url(forResource: pageName, withExtension: "html", subdirectory: "webpage") else {
            return
        }
        webView.loadFileURL(url, allowingReadAccessTo: url)
        let request = URLRequest(url: url)
        webView.load(request)
    }

}

extension HelpViewController: MFMailComposeViewControllerDelegate {
    @IBAction func launchEmail(sender: UIButton) {
        
        guard MFMailComposeViewController.canSendMail() else {
            simpleAlert(self, message: "해당 디바이스에서 사용자의 메일 계정이 설정되어 있지 않습니다. yoonbumtae@gmail.com 으로 메일을 보내주시면 답변드리겠습니다.", title: "메일 전송 불가", handler: nil)
            return
        }
        
        let emailTitle = "Tuner XR 피드백"
        let messageBody =
        """
        OS Version: \(UIDevice.current.systemVersion)
        Device: \(UIDevice.modelName)
        
        """
            
        +
            
        """
        'Tuner XR'에 대한 피드백이 있으신가요?
        """
        
        let toRecipents = ["yoonbumtae@gmail.com"]
        let mc: MFMailComposeViewController = MFMailComposeViewController()
        mc.mailComposeDelegate = self
        mc.setSubject(emailTitle)
        mc.setMessageBody(messageBody, isHTML: false)
        mc.setToRecipients(toRecipents)
        
        self.present(mc, animated: true, completion: nil)
    }
    
    private func mailComposeController(controller:MFMailComposeViewController, didFinishWithResult result:MFMailComposeResult, error:NSError) {
        switch result {
        case .cancelled:
            print("Mail cancelled")
        case .saved:
            print("Mail saved")
        case .sent:
            print("Mail sent")
        case .failed:
            print("Mail sent failure: \(error.localizedDescription)")
        default:
            break
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc(mailComposeController:didFinishWithResult:error:)
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult,error: Error?) {
            controller.dismiss(animated: true)
        }
    
}
