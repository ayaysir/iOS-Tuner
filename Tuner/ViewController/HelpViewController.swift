//
//  HelpViewController.swift
//  Tuner
//
//  Created by yoonbumtae on 2021/08/19.
//

import UIKit
import WebKit
import MessageUI
import AppTrackingTransparency
import StoreKit
import GoogleMobileAds

class HelpViewController: UIViewController {
    private var bannerView: GADBannerView!
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var btnSendMail: UIButton!
    @IBOutlet weak var cnstrWebViewBottom: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadHelpPage()
        
        btnSendMail.titleLabel?.adjustsFontSizeToFitWidth = true
        btnSendMail.layer.cornerRadius = 5
        
        if AdSupporter.shared.showAd {
            ATTrackingManager.requestTrackingAuthorization { status in
                // 광고 개인화 설정으로 허가 여부에 상관없이 광고는 표시됨
            }
            
            self.setupBannerView()
        }
    }
    
    @IBAction func btnActShowMenu(_ sender: UIButton) {
        self.toggleSideMenuView()
    }
    
}

extension HelpViewController: MFMailComposeViewControllerDelegate {
    @IBAction func launchEmail(sender: UIButton) {
        
        guard MFMailComposeViewController.canSendMail() else {
            simpleAlert(self, message: "해당 디바이스에서 사용자의 메일 계정이 설정되어 있지 않습니다. yoonbumtae@gmail.com 으로 메일을 보내주시면 답변드리겠습니다.".localized, title: "메일 전송 불가".localized, handler: nil)
            return
        }
        
        let emailTitle = "Tuner XR 피드백"
        let messageBody =
        """
        OS Version: \(UIDevice.current.systemVersion)
        Device: \(UIDevice.modelName)
        
        """ + "'Tuner XR'에 대한 피드백이 있으신가요?".localized
        
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

extension HelpViewController: WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
            case "openAppStore":
            let body = message.body as! String
            print("From JS:", body)
            popupAppStore(identifier: body)
            default:
                break
            }
    }
    
    func loadHelpPage() {
        // 웹 파일 로딩
        webView.uiDelegate = self
        webView.navigationDelegate = self
        
        webView.configuration.userContentController.add(self, name: "openAppStore")

        let pageName = "help-ko".localized
        guard let url = Bundle.main.url(forResource: pageName, withExtension: "html", subdirectory: "webpage") else {
            return
        }
        webView.loadFileURL(url, allowingReadAccessTo: url)
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard case .linkActivated = navigationAction.navigationType,
              let url = navigationAction.request.url
        else {
            decisionHandler(.allow)
            return
        }
        decisionHandler(.cancel)
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
   }
}

extension HelpViewController: SKStoreProductViewControllerDelegate {
    
    func popupAppStore(identifier: Any) {
        // 1631310626
        let parametersDictionary = [SKStoreProductParameterITunesItemIdentifier: identifier]
        let store = SKStoreProductViewController()
        store.delegate = self
        
        /*
         Attempt to load the selected product from the App Store. Display the store product view controller if success and print an error message,
         otherwise.
         */
        store.loadProduct(withParameters: parametersDictionary) { [unowned self] (result: Bool, error: Error?) in
            if result {
                self.present(store, animated: true, completion: {
                    print("The store view controller was presented.")
                })
            } else {
                if let error = error {
                    print("Error: \(error)")
                }
            }
        }
    }
}

// ============ 애드몹 셋업 ============
extension HelpViewController: GADBannerViewDelegate {
    /// 1. 본 클래스 멤버 변수로 다음 선언 추가
    /// `private var bannerView: GADBannerView!`
    ///
    /// 2. viewDidLoad()에 다음 추가
    /// `setupBannerView()`
    private func setupBannerView() {
        let adSize = GADAdSizeFromCGSize(CGSize(width: self.view.frame.width, height: 50))
        self.bannerView = GADBannerView(adSize: adSize)
        addBannerViewToView(bannerView)
        bannerView.adUnitID = AdSupporter.shared.HELP_AD_CODE
        // bannerView.adUnitID = AdSupporter.shared.TEST_CODE
        bannerView.rootViewController = self
        let request = GADRequest()
        bannerView.load(request)
        bannerView.delegate = self
    }
    
    private func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints( [NSLayoutConstraint(item: bannerView, attribute: .bottom, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0), NSLayoutConstraint(item: bannerView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0) ])
    }
    
    // GADBannerViewDelegate
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("GAD: \(#function)")
        // 버튼 constraint 50
        cnstrWebViewBottom.constant += 50
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print("GAD: \(#function)", error)
    }
    
    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("GAD: \(#function)")
    }
    
    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("GAD: \(#function)")
    }
    
    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("GAD: \(#function)")
    }
}
