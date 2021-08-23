//
//  StatsViewController.swift
//  Tuner
//
//  Created by yoonbumtae on 2021/08/14.
//

import UIKit
import Charts
import GoogleMobileAds
import AppTrackingTransparency

class StatsViewController: UIViewController {
    
    private var bannerView: GADBannerView!
    
    @IBOutlet weak var tblTuningRecords: UITableView!
    @IBOutlet weak var combinedChartView: CombinedChartView!
    @IBOutlet weak var segconGraphOutlet: UISegmentedControl!
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var cnstStackBottom: NSLayoutConstraint!
    @IBOutlet weak var cnstMenuButtonBottom: NSLayoutConstraint!
    
    var viewModel = StatsViewModel()
    
    var months: [String]!
    var unitsSold: [Double]!
    
    var refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblTuningRecords.delegate = self
        tblTuningRecords.dataSource = self
        
        initData()
        
        tblTuningRecords.refreshControl = refreshControl
        refreshControl.attributedTitle = NSAttributedString(string: "당겨서 새로고침".localized)
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        
        tblTuningRecords.allowsSelection = false
        
        if AdSupporter.shared.showAd {
            if #available(iOS 14, *) {
                ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                })
            }
            self.setupBannerView()
        }
        
        /**
         css
         background:linear-gradient(150deg, #191971 0%, #82B2EE 100%);
         */
        
        let color1 = CGColor(red: 25/255, green: 25/255, blue: 113/255, alpha: 0.72)
        let color2 = CGColor(red: 130/255, green: 178/255, blue: 238/255, alpha: 0.72)
        let gradient = CAGradientLayer()
        gradient.colors = [color1, color2]
        gradient.startPoint = CGPoint(x: 0.25, y: 0.07)
        gradient.endPoint = CGPoint(x: 0.75, y: 0.94)
        
        // TODO - 하드코딩 ㄴㄴ - 제약 constant 값으로
        // 360:200 = width:height
        let width: CGFloat = view.frame.width - 20
        let height: CGFloat = width * 200 / 360
        gradient.frame = CGRect(x: 0, y: 0, width: width, height: height)
        gradient.cornerRadius = 10
        
        print("bounds:", combinedChartView.frame, combinedChartView.bounds, stackView.frame, view.frame)
        
        stackView.layer.insertSublayer(gradient, at: 0)
        //
    }
    
    func initData() {
        do {
            try viewModel.setList(list: readCoreData())
            if viewModel.listCount != 0 {
                setChart(mode: "frequency")
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @objc func refresh(_ refreshControl: UIRefreshControl) {
        initData()
        // Do your job, when done:
        refreshControl.endRefreshing()
        tblTuningRecords.reloadData()
    }
    
    func setChart(mode: String) {
       let dataPoints = viewModel.forChartList.map { (Scale(rawValue: $0.noteIndex)?.textValueForSharp) ?? "" }
        var barValues: [Float] {
            if mode == "frequency" {
                return viewModel.forChartList.map { $0.avgFreq }
            } else {
                return viewModel.forChartList.map { $0.centDist }
            }
        }
        var lineValues: [Float] {
            if mode == "frequency" {
                return viewModel.forChartList.map { $0.standardFreq }
            } else {
                return viewModel.forChartList.map { _ in 0 }
            }
        }
        // bar, line 엔트리 생성
        var barDataEntries: [BarChartDataEntry] = []
        var lineDataEntries: [ChartDataEntry] = []
                
        // bar, line 엔트리 삽입
        for i in 0..<dataPoints.count {
            let barDataEntry = BarChartDataEntry(x: Double(i), y: Double(barValues[i]))
            let lineDataEntry = ChartDataEntry(x: Double(i), y: Double(lineValues[i]))
            barDataEntries.append(barDataEntry)
            lineDataEntries.append(lineDataEntry)
                    }

        // 데이터셋 생성
        let barChartDataSet = BarChartDataSet(entries: barDataEntries, label: mode == "frequency" ? "주파수(Hz)".localized : "센트(cent)".localized)
        let lineChartDataSet = LineChartDataSet(entries: lineDataEntries, label: "정확한 수치".localized)
        
        // bar 색깔
        barChartDataSet.colors = [UIColor(white: 0.96, alpha: 0.85)]
        
        
        // 라인 원 색깔 변경
        lineChartDataSet.colors = [(UIColor(named: "graph-line") ?? .red)]
        lineChartDataSet.circleColors = [(UIColor(named: "graph-line") ?? .red)]

        // 데이터 생성
        let data: CombinedChartData = CombinedChartData()

        // bar 데이터 지정
        data.barData = BarChartData(dataSet: barChartDataSet)
        // line 데이터 지정
        data.lineData = LineChartData(dataSet: lineChartDataSet)

        // 콤비 데이터 지정
        combinedChartView.data = data
        
        // 표시 여부
        combinedChartView.leftAxis.enabled = false
        combinedChartView.leftAxis.drawLabelsEnabled = false
        combinedChartView.xAxis.enabled = false
        combinedChartView.rightAxis.drawGridLinesEnabled = false
        
        combinedChartView.backgroundColor = UIColor.clear
        combinedChartView.layer.masksToBounds = true
        combinedChartView.layer.cornerRadius = 8
        
        // 라벨 색
        combinedChartView.rightAxis.labelTextColor = UIColor.white
        combinedChartView.legend.textColor = UIColor.white
        
        lineChartDataSet.circleRadius = 1
        lineChartDataSet.circleHoleRadius = 1
        lineChartDataSet.mode = .cubicBezier
        combinedChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
        
    }
    
    
    @IBAction func segConSelectGraph(_ sender: UISegmentedControl) {
        if viewModel.listCount != 0 {
            switch sender.selectedSegmentIndex {
            case 0:
                setChart(mode: "frequency")
            case 1:
                setChart(mode: "cents")
            default:
                break
            }
        }
    }
    
    @IBAction func btnToggleSideMenu(_ sender: Any) {
        self.toggleSideMenuView()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension StatsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.listCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "recordCell") as? StatsTableViewCell else {
            return UITableViewCell()
        }
        cell.update(record: viewModel.list[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            simpleDestructiveYesAndNo(self, message: "정말 삭제하시겠습니까?".localized, title: "삭제".localized) { [self] _ in
                do {
                    try deleteCoreData(id: viewModel.list[indexPath.row].id)
                    viewModel.list.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .left)
                    setChart(mode: segconGraphOutlet.selectedSegmentIndex == 0 ? "frequency" : "cents")
                } catch {
                    print(error)
                }
            }
            
        }
    }
    
}

class StatsTableViewCell: UITableViewCell {
    @IBOutlet weak var lblNoteName: UILabel!
    @IBOutlet weak var lblStandardPitch: UILabel!
    @IBOutlet weak var lblMyPitchAndCents: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblTuningSystem: UILabel!
    
    func update(record: TunerRecord) {
        let key = "config-notation"
        let notation = UserDefaults.standard.string(forKey: key) ?? "sharp"
        let note = Scale(rawValue: record.noteIndex)!
        let noteName = notation == "sharp" ? note.textValueForSharp : note.textValueForFlat
        lblNoteName.text = noteName + String(makeSubscriptOfNumber(record.octave))
        lblStandardPitch.text = "\(record.standardFreq.cleanFixTwo)Hz"
        
        
        let noteNum = note.rawValue + (record.octave * 12)
        let cents = getCents(frequency: record.avgFreq, noteNum: Float(noteNum), standardFrequency: record.standardFreq)
        
        if abs(cents) > 2 {
            lblMyPitchAndCents.textColor = UIColor.red
        } else {
            lblMyPitchAndCents.textColor = #colorLiteral(red: 0, green: 0.8054361939, blue: 0.1784389913, alpha: 1)
        }
        
        if abs(cents) <= 50 {
            lblMyPitchAndCents.text = "\(record.avgFreq.cleanFixTwo)Hz" + " "
                + "(\(Int(record.centDist)) cents)"
        } else {
            lblMyPitchAndCents.textColor = UIColor.lightGray
            lblMyPitchAndCents.text = "\(record.avgFreq.cleanFixTwo)Hz" + " "
                + "(±50 cents 초과)".localized
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd E HH:mm:ss"
        lblDate.text = "\(formatter.string(from: record.date))"
        lblTuningSystem.text = record.tuningSystem.textValue.localized
    }
    
    
    
}

class StatsViewModel {
    var list: [TunerRecord] = []
    
    func setList(list: [TunerRecord]) {
        self.list = list
    }
    
    var listCount: Int {
        return list.count
    }
    
    var forChartList:  [TunerRecord] {
        let REC_COUNT = 50
        
        if listCount >= 50 {
            var reversedArr = list[...REC_COUNT]
            reversedArr.sort { $0.date < $1.date }
            return Array(reversedArr)
        } else if listCount >= 0 {
            var reversedArr = list[...(listCount - 1)]
            reversedArr.sort { $0.date < $1.date }
            
            let toCount = (50 - listCount)
            
            var blankArrWithReversedArr = [TunerRecord]()
            blankArrWithReversedArr.reserveCapacity(toCount)
            
            for _ in 0..<toCount {
                blankArrWithReversedArr.append(TunerRecord(id: UUID(), date: Date(), avgFreq: 0, stdFreq: 0, standardFreq: 0, centDist: 0, noteIndex: 0, octave: 0, tuningSystem: TuningSystem.equalTemperament))
            }
            
            blankArrWithReversedArr.append(contentsOf: reversedArr)
            return Array(blankArrWithReversedArr)
        } else {
            return Array<TunerRecord>()
        }
        
    }
}

// ============ 애드몹 셋업 ============
extension StatsViewController: GADBannerViewDelegate {
    // 본 클래스에 다음 선언 추가
    // // AdMob
    // private var bannerView: GADBannerView!
    
    // viewDidLoad()에 다음 추가
    // setupBannerView()
    
    private func setupBannerView() {
        let adSize = GADAdSizeFromCGSize(CGSize(width: self.view.frame.width, height: 50))
        self.bannerView = GADBannerView(adSize: adSize)
        addBannerViewToView(bannerView)
//         bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716" // test
        bannerView.adUnitID = AdSupporter.shared.STATS_AD_CODE
        print("adUnitID: ", bannerView.adUnitID!)
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
        cnstStackBottom.constant += 50
        cnstMenuButtonBottom.constant += 50
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

extension BarChartRenderer {
    // drawRect 함수에서 라운드 둥글게 처리했음
}
