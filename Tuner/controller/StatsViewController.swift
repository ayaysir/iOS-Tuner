//
//  StatsViewController.swift
//  Tuner
//
//  Created by yoonbumtae on 2021/08/14.
//

import UIKit
import Charts

class StatsViewController: UIViewController {
    
    @IBOutlet weak var tblTuningRecords: UITableView!
    @IBOutlet weak var combinedChartView: CombinedChartView!
    
    var viewModel = StatsViewModel()
    
    var months: [String]!
    var unitsSold: [Double]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblTuningRecords.delegate = self
        tblTuningRecords.dataSource = self
        
        do {
            try viewModel.setList(list: readCoreData())
        } catch {
            print(error.localizedDescription)
        }

        
        setChart(dataPoints: viewModel.forChartList.map { (Scale(rawValue: $0.noteIndex)?.textValueForSharp) ?? "" }, barValues: viewModel.forChartList.map { $0.avgFreq }, lineValues: viewModel.forChartList.map { $0.standardFreq } )
    }
    
    func setChart(dataPoints: [String], barValues: [Float], lineValues: [Float]) {
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
        let barChartDataSet = BarChartDataSet(entries: barDataEntries, label: "목표 처리량")
        let lineChartDataSet = LineChartDataSet(entries: lineDataEntries, label: "실시간 처리량")
        
        // 라인 원 색깔 변경
        lineChartDataSet.colors = [.red ]
        lineChartDataSet.circleColors = [.red ]

        // 데이터 생성
        let data: CombinedChartData = CombinedChartData()

        // bar 데이터 지정
        data.barData = BarChartData(dataSet: barChartDataSet)
        // line 데이터 지정
        data.lineData = LineChartData(dataSet: lineChartDataSet)

        // 콤비 데이터 지정
        combinedChartView.data = data
        
        combinedChartView.leftAxis.enabled = false
        combinedChartView.drawGridBackgroundEnabled = false
        
        lineChartDataSet.circleRadius = 1
        lineChartDataSet.circleHoleRadius = 1
        lineChartDataSet.mode = .cubicBezier
        combinedChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        
        
        
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
    
    
}

class StatsTableViewCell: UITableViewCell {
    @IBOutlet weak var lblNoteName: UILabel!
    @IBOutlet weak var lblStandardPitch: UILabel!
    @IBOutlet weak var lblMyPitchAndCents: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblTuningSystem: UILabel!
    
    func update(record: TunerRecord) {
        lblNoteName.text = Scale(rawValue: record.noteIndex)!.textValueForSharp + String(makeSubscriptOfNumber(record.octave
        ))
        lblStandardPitch.text = "\(record.standardFreq.cleanFixTwo)Hz"
        lblMyPitchAndCents.text = "\(record.avgFreq.cleanFixTwo)HZ" + "(\(Int(record.centDist)) cents)"
        
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-D hh:mm:dd"
        lblDate.text = "\(formatter.string(from: record.date))"
        lblTuningSystem.text = "Equal Temperament"
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
    
    var forChartList: [TunerRecord] {
        let REC_COUNT = 50
        
        var reversedArr = list[...REC_COUNT]
        reversedArr.sort { $0.date < $1.date }
        
        return Array(reversedArr)
    }
}
