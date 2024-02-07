//
//  SettingViewController.swift
//  Tuner
//
//  Created by yoonbumtae on 2021/08/15.
//

import UIKit
import StoreKit
import AppTrackingTransparency
import GoogleMobileAds

class SettingViewController: UIViewController {
    private var bannerView: GADBannerView!
    
    @IBOutlet weak var segconMode: UISegmentedControl!
    @IBOutlet weak var segconNotation: UISegmentedControl!
    @IBOutlet weak var btnRange1: UIButton!
    @IBOutlet weak var btnRange2: UIButton!
    @IBOutlet weak var btnOctave1: UIButton!
    @IBOutlet weak var btnOctave2: UIButton!
    
    @IBOutlet weak var stackViewRange: UIStackView!
    @IBOutlet weak var constrMenuButton: NSLayoutConstraint!
    
    var leftRange = NoteRangeConfig(note: Scale.C, octave: 1)
    var rightRange = NoteRangeConfig(note: Scale.B, octave: 7)
    
    let products: [SKProduct]? = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setRange()
        loadRangeFromUserDefaults()
        loadAppearanceInfo()
        loadNotationInfo()
        initIAP()
        
        if AdSupporter.shared.showAd {
            if #available(iOS 14, *) {
                ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                })
            }
            self.setupBannerView()
        }
    }
    
    func loadAppearanceInfo() {
        let key = "config-appearance"
        let mode = UserDefaults.standard.string(forKey: key) ?? "unspecified"
        switch mode {
        case "light":
            segconMode.selectedSegmentIndex = 1
        case "dark":
            segconMode.selectedSegmentIndex = 2
        default:
            segconMode.selectedSegmentIndex = 0
        }
    }
    
    func loadNotationInfo() {
        let key = "config-notation"
        let notation = UserDefaults.standard.string(forKey: key) ?? "sharp"
        if notation == "sharp" {
            segconNotation.selectedSegmentIndex = 0
        } else {
            segconNotation.selectedSegmentIndex = 1
        }
    }
    
    func loadRangeFromUserDefaults() {
        do {
            leftRange = try UserDefaults.standard.getObject(forKey: "config-rangeLeft", castTo: NoteRangeConfig.self)
            rightRange = try UserDefaults.standard.getObject(forKey: "config-rangeRight", castTo: NoteRangeConfig.self)
            print(leftRange, rightRange)
            
            btnRange1.setTitle(leftRange.note.textValueMixed, for: .normal)
            btnOctave1.setTitle(String(leftRange.octave), for: .normal)
            
            btnRange2.setTitle(rightRange.note.textValueMixed, for: .normal)
            btnOctave2.setTitle(String(rightRange.octave), for: .normal)
        } catch {
            print(#function, error.localizedDescription)
        }
    }
    
    func saveLeftRangeToUserDefaults() {
        do {
            try UserDefaults.standard.setObject(leftRange, forKey: "config-rangeLeft")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func saveRightRangeToUserDefaults() {
        do {
            try UserDefaults.standard.setObject(rightRange, forKey: "config-rangeRight")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func saveRangeToUserDefaults() {
        do {
            try UserDefaults.standard.setObject(leftRange, forKey: "config-rangeLeft")
            try UserDefaults.standard.setObject(rightRange, forKey: "config-rangeRight")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @IBAction func segconSelectAppearance(_ sender: UISegmentedControl) {
        let key = "config-appearance"
        switch sender.selectedSegmentIndex {
        case 0:
            UIApplication.shared.windows.forEach { window in
                window.overrideUserInterfaceStyle = .unspecified
            }
            UserDefaults.standard.setValue("unspecified", forKey: key)
        case 1:
            UIApplication.shared.windows.forEach { window in
                window.overrideUserInterfaceStyle = .light
            }
            UserDefaults.standard.setValue("light", forKey: key)
        case 2:
            UIApplication.shared.windows.forEach { window in
                window.overrideUserInterfaceStyle = .dark
            }
            UserDefaults.standard.setValue("dark", forKey: key)
        default:
            break
        }
    }
    
    @IBAction func segconNotationAct(_ sender: UISegmentedControl) {
        let key = "config-notation"
        switch sender.selectedSegmentIndex {
        case 0:
            UserDefaults.standard.setValue("sharp", forKey: key)
        case 1:
            UserDefaults.standard.setValue("flat", forKey: key)
        default:
            break
        }
    }
    
    @IBAction func btnRemoveAdsIAP(_ sender: Any) {}
    
    @IBAction func btnToggleSideMenu(_ sender: Any) {
        self.toggleSideMenuView()
    }
    
    @IBAction func btnRangeNoteLeftAct(_ sender: UIButton) {
        showPopover()
    }
    
    @IBAction func btnRangeOctaveLeftAct(_ sender: UIButton) {
        showPopover()
    }
    
    @IBAction func btnRangeNoteRightAct(_ sender: UIButton) {
        showPopover(isLeft: false)
    }
    
    @IBAction func btnRangeOctaveRightAct(_ sender: UIButton) {
        showPopover(isLeft: false)
    }
    
    private func showPopover(isLeft: Bool = true) {
        view.layoutIfNeeded()
        stackViewRange.layoutIfNeeded()
        
        let x = isLeft ? stackViewRange.frame.minX : stackViewRange.frame.maxX - (btnRange2.frame.width + btnOctave2.frame.width)
        
        let buttonFrame = CGRect(
            x: x,
            y: stackViewRange.frame.minY + btnRange1.frame.height / 2,
            width: btnRange1.frame.width + btnOctave1.frame.width,
            height: btnRange1.frame.height)
        
        ChangeRangeViewController.show(
            self,
            displayKey: isLeft ? leftRange.note : rightRange.note,
            displayOctave: isLeft ? leftRange.octave : rightRange.octave,
            buttonFrame: buttonFrame,
            isLeft: isLeft)
    }
}

extension SettingViewController {
    func setRange() {
        btnRange1.setTitle(leftRange.note.textValueMixed, for: .normal)
        btnOctave1.setTitle(String(leftRange.octave), for: .normal)
        btnRange2.setTitle(rightRange.note.textValueMixed, for: .normal)
        btnOctave2.setTitle(String(rightRange.octave), for: .normal)
    }
    
    func validateRange() -> Bool {
        let leftNoteNum = leftRange.note.rawValue + (leftRange.octave * 12)
        let rightNoteNum = rightRange.note.rawValue + (rightRange.octave * 12)
        return leftNoteNum < rightNoteNum
    }
    
    func setRangeLeftNote() {
        // noteDropDownLeft.dataSource = Scale.allCases.map { $0.textValueMixed }
        // noteDropDownLeft.anchorView = btnRange1
        // noteDropDownLeft.cornerRadius = 15
        // noteDropDownLeft.selectRow(leftRange.note.rawValue)
        //
        // 
        // noteDropDownLeft.selectionAction = { [unowned self] (index: Int, item: String) in
        //     let oldItem = leftRange.note
        //     leftRange.note = Scale(rawValue: index) ?? Scale.C
        //     if validateRange() {
        //         saveRangeToUserDefaults()
        //         btnRange1.setTitle(item, for: .normal)
        //     } else {
        //         print(oldItem)
        //         simpleAlert(self, message: "범위는 왼쪽 노트보다 오른쪽 노트의 음높이가 높아야 합니다.".localized, title: "범위 오류".localized) { _ in
        //             noteDropDownLeft.selectRow(oldItem.rawValue)
        //             btnRange1.setTitle(oldItem.textValueMixed, for: .normal)
        //             leftRange.note = oldItem
        //         }
        //     }
        // }
    }
    
    func setRangeLeftOctave() {
        // octaveDropDownLeft.dataSource = [0, 1, 2, 3, 4, 5, 6, 7].map { String($0) }
        // octaveDropDownLeft.anchorView = btnOctave1
        // octaveDropDownLeft.cornerRadius = 15
        // octaveDropDownLeft.selectRow(leftRange.octave)
        //
        // 
        // octaveDropDownLeft.selectionAction = { [unowned self] (index: Int, item: String) in
        //     let oldItem = leftRange.octave
        //     leftRange.octave = index
        //     if validateRange() {
        //         saveRangeToUserDefaults()
        //         btnOctave1.setTitle(item, for: .normal)
        //     } else {
        //         print(oldItem)
        //         simpleAlert(self, message: "범위는 왼쪽 노트보다 오른쪽 노트의 음높이가 높아야 합니다.".localized, title: "범위 오류".localized) { _ in
        //             octaveDropDownLeft.selectRow(oldItem)
        //             btnOctave1.setTitle(String(oldItem), for: .normal)
        //             leftRange.octave = oldItem
        //         }
        //     }
        // }
    }
    
    func setRangeRightNote() {
        // noteDropDownRight.dataSource = Scale.allCases.map { $0.textValueMixed }
        // noteDropDownRight.anchorView = btnRange2
        // noteDropDownRight.cornerRadius = 15
        // noteDropDownRight.selectRow(rightRange.note.rawValue)
        //
        // 
        // noteDropDownRight.selectionAction = { [unowned self] (index: Int, item: String) in
        //     let oldItem = rightRange.note
        //     rightRange.note = Scale(rawValue: index) ?? Scale.C
        //     if validateRange() {
        //         saveRangeToUserDefaults()
        //         btnRange2.setTitle(item, for: .normal)
        //     } else {
        //         simpleAlert(self, message: "범위는 왼쪽 노트보다 오른쪽 노트의 음높이가 높아야 합니다.".localized, title: "범위 오류".localized) { _ in
        //             noteDropDownRight.selectRow(oldItem.rawValue)
        //             btnRange2.setTitle(oldItem.textValueMixed, for: .normal)
        //             rightRange.note = oldItem
        //         }
        //     }
        // }
    }
    
    func setRangeRightOctave() {
        // octaveDropDownRight.dataSource = [0, 1, 2, 3, 4, 5, 6, 7].map { String($0) }
        // octaveDropDownRight.anchorView = btnOctave2
        // octaveDropDownRight.cornerRadius = 15
        // octaveDropDownRight.selectRow(rightRange.octave)
        // btnOctave2.setTitle(String(rightRange.octave), for: .normal)
        // 
        // octaveDropDownRight.selectionAction = { [unowned self] (index: Int, item: String) in
        //     let oldItem = rightRange.octave
        //     rightRange.octave = index
        //     if validateRange() {
        //         saveRangeToUserDefaults()
        //         btnOctave2.setTitle(item, for: .normal)
        //     } else {
        //         simpleAlert(self, message: "범위는 왼쪽 노트보다 오른쪽 노트의 음높이가 높아야 합니다.".localized, title: "범위 오류".localized) { _ in
        //             octaveDropDownRight.selectRow(oldItem)
        //             btnOctave2.setTitle(String(oldItem), for: .normal)
        //             rightRange.octave = oldItem
        //         }
        //     }
        // }
    }
}

extension SettingViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        .none
    }

    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {}

    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        true
    }
}

extension SettingViewController: ChangeRangeVCDelegate {
    func didSelectedNote(_ controller: ChangeRangeViewController, key: Scale, octave: Int, isLeft: Bool) {
        if isLeft {
            let oldItem = leftRange
            
            leftRange.note = key
            leftRange.octave = octave
            
            if validateRange() {
                saveLeftRangeToUserDefaults()
                btnRange1.setTitle(key.textValueMixed, for: .normal)
                btnOctave1.setTitle(String(octave), for: .normal)
            } else {
                simpleAlert(self, message: "범위는 왼쪽 노트보다 오른쪽 노트의 음높이가 높아야 합니다.".localized, title: "범위 오류".localized) { [unowned self] _ in
                    btnOctave1.setTitle(oldItem.note.textValueMixed, for: .normal)
                    btnOctave1.setTitle(String(oldItem.octave), for: .normal)
                    leftRange = oldItem
                }
            }
        } else {
            let oldItem = rightRange
            
            rightRange.note = key
            rightRange.octave = octave
            
            if validateRange() {
                saveRightRangeToUserDefaults()
                btnRange2.setTitle(key.textValueMixed, for: .normal)
                btnOctave2.setTitle(String(octave), for: .normal)
            } else {
                simpleAlert(self, message: "범위는 왼쪽 노트보다 오른쪽 노트의 음높이가 높아야 합니다.".localized, title: "범위 오류".localized) { [unowned self] _ in
                    btnOctave2.setTitle(oldItem.note.textValueMixed, for: .normal)
                    btnOctave2.setTitle(String(oldItem.octave), for: .normal)
                    rightRange = oldItem
                }
            }
        }
    }
}

// ============ 애드몹 셋업 ============
extension SettingViewController: GADBannerViewDelegate {
    /// 1. 본 클래스 멤버 변수로 다음 선언 추가
    /// `private var bannerView: GADBannerView!`
    ///
    /// 2. viewDidLoad()에 다음 추가
    /// `setupBannerView()`
    private func setupBannerView() {
        let adSize = GADAdSizeFromCGSize(CGSize(width: self.view.frame.width, height: 50))
        self.bannerView = GADBannerView(adSize: adSize)
        addBannerViewToView(bannerView)
        bannerView.adUnitID = AdSupporter.shared.TUNER_AD_CODE
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
        constrMenuButton.constant += 50
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

/*
 추후 추가: 인앱 결제로 광고 제거
 */
extension SettingViewController {
    
    private func initIAP() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleIAPPurchase(_:)), name: .IAPHelperPurchaseNotification, object: nil)

        // IAP 불러오기
        InAppProducts.store.requestProducts { [weak self] (success, products) in
            guard let self = self, success else { return }
            print(self)
            // ...
        }
    }

    // 인앱 결제 버튼 눌렀을 때
    private func touchIAP() {
        if let product = products?.first {
            InAppProducts.store.buyProduct(product) // 구매하기
        }
    }

    // 결제 후 Notification을 받아 처리
    @objc func handleIAPPurchase(_ notification: Notification) {
        guard let success = notification.object as? Bool else { return }

        if success {
            DispatchQueue.main.async {
                let vc = UIAlertController(title: "알림", message: "구매 성공.", preferredStyle: .alert)
                let ok = UIAlertAction(title: "확인", style: .default) { _ in

                    if let mainURL = URL(string: "homeurl") {
                        let request = URLRequest(url: mainURL)
//                        self.mainWebview.load(request)
                        print(request)
                    }
                }
                vc.addAction(ok)
                self.present(vc, animated: true, completion: nil)
            }

        } else {

            DispatchQueue.main.async {
                let vc = UIAlertController(title: "알림", message: "구매에 실패했습니다.", preferredStyle: .alert)
                let ok = UIAlertAction(title: "확인", style: .default, handler: nil)
                vc.addAction(ok)
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
}
