//
//  StatisticsViewController.swift
//  PetStation
//
//  Created by Xiaotian LIU on 4/11/18.
//  Copyright © 2018 Xiaotian LIU. All rights reserved.
//

import UIKit
import Charts
import ChartsRealm
import Firebase

enum DateFormat: String {
    case Daily = "HH:mm"
    case Weekly = "dd-MM E"
    case Monthly = "dd-MM"
}

class StatisticsViewController: UIViewController, IAxisValueFormatter {

    @IBOutlet weak var barChartView: BarChartView!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var selectedDisplayRange: UISegmentedControl!
    
    var datePicker: UIDatePicker?
    var feedingHistory: [(date: TimeInterval, amount: Double)]?
    var eatingHistory: [(date: TimeInterval, amount: Double)]?
    var axisFormatDelegate: IAxisValueFormatter?
    let databaseRef: DatabaseReference = Database.database().reference().child("petstation/users")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.axisFormatDelegate = self
        datePickerSetUp()
        loadFeedingHistory()
        loadEatingHistory()
//        getFeedingHistory(dateRange: (from: 1541382171.0, to: 1541404171.0), completion: {(data) in self.drawChart(withData: data)})
        dateTextField.text = toString(date: Date(), format: "dd/MM/yyyy")

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // MARK: - Date formatting
    
    /**
     It converts a date to a String according to the date format
     
     - Parameters:
        - date: the date being converted
        - format: the date format
     
     - Returns: a formatted date string
     */
    func toString(date: Date, format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }
    
    func toDate(dateString: String, format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: dateString)
    }
    
    func roundingToDay(date: Date) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: dateFormatter.string(from: date))
    }
    
    func roundingToDay(_ timeIntervalSince1970: TimeInterval) -> TimeInterval {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return (dateFormatter.date(from: dateFormatter.string(from: Date(timeIntervalSince1970: timeIntervalSince1970)))?.timeIntervalSince1970)!
    }
    
    func roundingTo1stDayOfMonth(date: Date) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM"
        return dateFormatter.date(from: dateFormatter.string(from: date))
    }
    
    func getDateRangeOfOneDayContaining(date: Date) -> (from: TimeInterval, to: TimeInterval) {
        let from = roundingToDay(date: date)!
        let to = Calendar.current.date(byAdding: .day, value: 1, to: from)!
        return (from.timeIntervalSince1970, to.timeIntervalSince1970)
    }
    
    func getDateRangeOfOneWeekContaining(date: Date) -> (from: TimeInterval, to: TimeInterval) {
        let aDate = roundingToDay(date: date)!
        let weekday = Calendar.current.component(.weekday, from: aDate)
        let from = Calendar.current.date(byAdding: .day, value: -weekday + 1, to: aDate)!
        let to = Calendar.current.date(byAdding: .day, value: 7, to: from)!
        return (from.timeIntervalSince1970, to.timeIntervalSince1970)
    }
    
    func getDateRangeOfOneMonthContaining(date: Date) -> (from: TimeInterval, to: TimeInterval) {
        let from = roundingTo1stDayOfMonth(date: date)!
        let to = Calendar.current.date(byAdding: .month, value: 1, to: from)
        return (from.timeIntervalSince1970, (to?.timeIntervalSince1970)!)
    }

    // MARK: - Date Picker
    func datePickerSetUp() {
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        datePicker?.date = roundingToDay(date: Date())!
        datePicker?.addTarget(self, action: #selector(self.dateChanged(datepicker:)), for: .valueChanged)
        dateTextField.inputView = datePicker
        
        displayChart(date: Date(), selectedDisplayRange: 0)
    }
    
    func displayChart(date: Date, selectedDisplayRange: Int) {
        // determine date range
        var dateRange = getDateRangeOfOneDayContaining(date: date)
        switch selectedDisplayRange {
        case 0:
            dateRange = getDateRangeOfOneDayContaining(date: date)
        case 1:
            dateRange = getDateRangeOfOneWeekContaining(date: date)
        case 2:
            dateRange = getDateRangeOfOneMonthContaining(date: date)
        default:
            break
        }
        
        // if show data for only one day, DO NOT use groupByDay; otherwise, groupByDay first
        if selectedDisplayRange == 0 {
            getFeedingHistory(dateRange: dateRange) { (feedHistory) in
                self.getEatingHistory(dateRange: dateRange, completion: { (eatHistory) in
                    self.drawChart(withDatasets: [feedHistory, eatHistory], labels: ["Feed History", "Eat History"], colors: [.orange,.green])
                })
            }
        } else {
            getFeedingHistory(dateRange: dateRange) { (feedHistory) in
                let groupedFeedHistory = self.groupByDay(dataset: feedHistory)
                self.getEatingHistory(dateRange: dateRange, completion: { (eatHistory) in
                    let groupedEatHistory = self.groupByDay(dataset: eatHistory)
                    self.drawChart(withDatasets: [groupedFeedHistory, groupedEatHistory], labels: ["Feed History", "Eat History"], colors: [.orange,.green])
                })
            }
        }
    }
    
    @objc func dateChanged(datepicker: UIDatePicker) {
        dateTextField.text = toString(date: datepicker.date, format: "dd/MM/yyyy")
//        switch self.selectedDisplayRange.selectedSegmentIndex {
//        case 0:
//            let dateRange = getDateRangeOfOneDayContaining(date: (datePicker?.date)!)
//            getFeedingHistory(dateRange: dateRange) { (dataset) in
//                self.drawChart(withDataset: dataset)
//            }
//        case 1:
//            let dateRange = getDateRangeOfOneWeekContaining(date: (datePicker?.date)!)
//            getFeedingHistory(dateRange: dateRange) { (dataset) in
//                let groupedDataset = self.groupByDay(dataset: dataset)
//                self.drawChart(withDataset: groupedDataset)
//            }
//        case 2:
//            let dateRange = getDateRangeOfOneMonthContaining(date: (datePicker?.date)!)
//            getFeedingHistory(dateRange: dateRange) { (dataset) in
//                let groupedDataset = self.groupByDay(dataset: dataset)
//                self.drawChart(withDataset: groupedDataset)
//            }
//        default:
//            return
//        }
        displayChart(date: datepicker.date, selectedDisplayRange: self.selectedDisplayRange.selectedSegmentIndex)
    }
    
    
    @IBAction func selectDisplayRange(_ sender: UISegmentedControl) {
//        switch sender.selectedSegmentIndex {
//        case 0:
//            let dateRange = getDateRangeOfOneDayContaining(date: (datePicker?.date)!)
//            getFeedingHistory(dateRange: dateRange) { (dataset) in
//                self.drawChart(withDataset: dataset)
//            }
//        case 1:
//            let dateRange = getDateRangeOfOneWeekContaining(date: (datePicker?.date)!)
//            getFeedingHistory(dateRange: dateRange) { (dataset) in
//                let groupedDataset = self.groupByDay(dataset: dataset)
//                self.drawChart(withDataset: groupedDataset)
//            }
//        case 2:
//            let dateRange = getDateRangeOfOneMonthContaining(date: (datePicker?.date)!)
//            getFeedingHistory(dateRange: dateRange) { (dataset) in
//                let groupedDataset = self.groupByDay(dataset: dataset)
//                self.drawChart(withDataset: groupedDataset)
//            }
//        default:
//            return
//        }
        displayChart(date: (datePicker?.date)!, selectedDisplayRange: sender.selectedSegmentIndex)
    }
    
    func loadFeedingHistory() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        self.databaseRef.child(uid).child("feedHistory").observeSingleEvent(of: .value) { (snapshot) in
            guard let dataset = snapshot.value as? NSDictionary else {
                return
            }
            var feedingHistory: [(TimeInterval, Double)] = []
            dataset.forEach({ (entry) in
                let date = Double(entry.key as! String)! / 1000
                let amount = Double(entry.value as! Int)
                feedingHistory.append((date, amount))
            })
            self.feedingHistory = feedingHistory
        }
    }
    
    func loadEatingHistory() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        self.databaseRef.child(uid).child("eatHistory").observeSingleEvent(of: .value) { (snapshot) in
            guard let dataset = snapshot.value as? NSDictionary else {
                return
            }
            var eatingHistory: [(TimeInterval, Double)] = []
            dataset.forEach({ (entry) in
                let date = Double(entry.key as! String)! / 1000
                let amount = Double(entry.value as! Int)
                eatingHistory.append((date, amount))
            })
            self.eatingHistory = eatingHistory
        }
    }
    
    func getFeedingHistory(dateRange: (from: TimeInterval, to: TimeInterval), completion: @escaping ([(date: TimeInterval, amount: Double)]) -> Void) {
        if let localDataset = self.feedingHistory {
            let boundedHistory = getHistoryLocally(dateRange: dateRange, from: localDataset)
            completion(boundedHistory)
        } else {
            getHistoryRemotely(for: "feedHistory", dateRange: dateRange, completion: completion)
        }
    }
    
    func getEatingHistory(dateRange: (from: TimeInterval, to: TimeInterval), completion: @escaping ([(date: TimeInterval, amount: Double)]) -> Void) {
        if let localDataset = self.eatingHistory {
            let boundedHistory = getHistoryLocally(dateRange: dateRange, from: localDataset)
            completion(boundedHistory)
        } else {
            getHistoryRemotely(for: "eatHistory", dateRange: dateRange, completion: completion)
        }
    }
    
    func getHistoryLocally(dateRange: (from: TimeInterval, to: TimeInterval), from localDataset: [(date: TimeInterval, amount: Double)]) -> [(date: TimeInterval, amount: Double)] {
        var boundedHistory: [(TimeInterval, Double)] = []
        boundedHistory.append((dateRange.from, 0.0))
        localDataset.forEach({ (entry) in
            if entry.date >= dateRange.from && entry.date <= dateRange.to {
                boundedHistory.append(entry)
            }
        })
        boundedHistory.append((dateRange.to, 0.0))
        
        return boundedHistory
    }
    
    func getHistoryRemotely(for node: String, dateRange: (from: TimeInterval, to: TimeInterval), completion: @escaping ([(date: TimeInterval, amount: Double)]) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        self.databaseRef.child(uid).child(node).observeSingleEvent(of: .value) { (snapshot) in
            guard let dataset = snapshot.value as? NSDictionary else {
                return
            }
            var boundedFeedingHistory: [(Double, Double)] = []
            boundedFeedingHistory.append((dateRange.from, 0.0))
            dataset.forEach({ (entry) in
                let date = Double(entry.key as! String)! / 1000
                let amount = Double(entry.value as! Int)
                if date >= dateRange.from && date <= dateRange.to {
                    boundedFeedingHistory.append((date, amount))
                }
            })
            boundedFeedingHistory.append((dateRange.to, 0.0))
            completion(boundedFeedingHistory)
        }
    }
    
    func groupByDay(dataset: [(date: TimeInterval, amount: Double)]) -> [(TimeInterval, Double)] {
        //        let aWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: (datePicker?.date)!)
        //        getTemperatures(from: aWeekAgo!, to: (datePicker?.date)!)
        
        var dailyHistory: [(date: TimeInterval, temp: Double)] = []
        
        let TempDict = Dictionary(grouping: dataset) { (entry) -> String in
            let date = roundingToDay(entry.date)
            return String(date)
        }
        
        for (key, group) in TempDict {
            let sum = group.reduce(0.0) { (runningTotal, nextRecord) -> Double in
                return runningTotal + nextRecord.amount
            }
            dailyHistory.append((Double(key)!, sum))
        }
        
        dailyHistory.sort { (date1, date2) -> Bool in
            return date1.date < date2.date
        }
        
        return dailyHistory
    }
    
    func drawChart(withDataset: [(date: Double, amount: Double)]) {
        var dataEntries: [BarChartDataEntry] = []
        for i in 0..<withDataset.count {
            let dataEntry = BarChartDataEntry(x: Double(withDataset[i].date), y: Double(withDataset[i].amount))
            dataEntries.append(dataEntry)
        }
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "Feeding Amount")
//        chartDataSet.setColor(.blue)
        let chartData = BarChartData(dataSet: chartDataSet)
        
        // setting bar width
        var barWidth = 2000.0
        switch self.selectedDisplayRange.selectedSegmentIndex {
        case 0:
            barWidth = 2000.0
        case 1:
            barWidth = 3600.0 * 12
        case 2:
            barWidth = 3600.0 * 12
        default:
            break
        }
        chartData.barWidth = barWidth
        
        barChartView.data = chartData
        
        // formatting xAxis
        let xaxis = barChartView.xAxis
        xaxis.valueFormatter = axisFormatDelegate
        xaxis.labelPosition = .bottom
        xaxis.labelRotationAngle = 45.0
    }
    
    func drawChart(withDatasets: [[(date: Double, amount: Double)]], labels: [String], colors: [NSUIColor]) {
        
        // preparing datasets
        var chartDatesets: [BarChartDataSet] = []
        for i in 0..<withDatasets.count {
            var dataEntries: [BarChartDataEntry] = []
            for j in 0..<withDatasets[i].count {
                let dataEntry = BarChartDataEntry(x: Double(withDatasets[i][j].date), y: Double(withDatasets[i][j].amount))
                dataEntries.append(dataEntry)
            }
            let chartDataSet = BarChartDataSet(values: dataEntries, label: labels[i])
            if i < colors.count {
                chartDataSet.setColor(colors[i])
            }
            chartDatesets.append(chartDataSet)
        }
        
        let chartData = BarChartData(dataSets: chartDatesets)
        
        // setting bar width
        var barWidth = 1500.0
        switch self.selectedDisplayRange.selectedSegmentIndex {
        case 0:
            barWidth = 1500.0
        case 1:
            barWidth = 3600.0 * 12
        case 2:
            barWidth = 3600.0 * 12
        default:
            break
        }
        chartData.barWidth = barWidth
        
        // assign to chart view
        barChartView.data = chartData
        
        // formatting xAxis
        let xaxis = barChartView.xAxis
        xaxis.valueFormatter = axisFormatDelegate
        xaxis.labelPosition = .bottom
        xaxis.labelRotationAngle = 45.0
    }
    
    // IAxisValueFormattor
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        var format = DateFormat.Daily
        switch self.selectedDisplayRange.selectedSegmentIndex {
        case 0:
            format = DateFormat.Daily
        case 1:
            format = DateFormat.Weekly
        case 2:
            format = DateFormat.Monthly
        default:
            break
        }
        return toString(date: Date(timeIntervalSince1970: value), format: (format.rawValue))
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
