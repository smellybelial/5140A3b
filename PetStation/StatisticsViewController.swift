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
    case Monthly = "dd/MM"
    case forDatePicker = "dd-MMM-yyyy"
}

class StatisticsViewController: UIViewController, IAxisValueFormatter {
    // IAxisValueFormattor
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return toString(date: Date(timeIntervalSince1970: value), format: DateFormat.Daily.rawValue)
    }
    

    @IBOutlet weak var barChartView: BarChartView!
    @IBOutlet weak var dateTextField: UITextField!
    var datePicker: UIDatePicker?
    var feedingHistory: [(date: TimeInterval, amount: Double)]?
    var axisFormatDelegate: IAxisValueFormatter?
    let databaseRef: DatabaseReference = Database.database().reference().child("petstation/users")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.axisFormatDelegate = self
        loadFeedingHistory()
        getFeedingHistory(dateRange: (from: 1541382171.0, to: 1541404171.0), completion: {(data) in self.drawChart(withData: data)})
        datePickerSetUp()
        dateTextField.text = toString(date: Date(), format: "dd/MM/yyyy")

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
    }
    
    @objc func dateChanged(datepicker: UIDatePicker) {
        dateTextField.text = toString(date: datepicker.date, format: "dd/MM/yyyy")
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
    
    func getFeedingHistory(dateRange: (from: TimeInterval, to: TimeInterval), completion: @escaping ([(date: TimeInterval, amount: Double)]) -> Void) {
        if self.feedingHistory != nil {
            let boundedFeedingHistory = getFeedingHistoryLocally(dateRange: dateRange)
            completion(boundedFeedingHistory)
        } else {
            getFeedingHistoryRemotely(dateRange: dateRange, completion: completion)
        }
    }
    
    func getFeedingHistoryLocally(dateRange: (from: TimeInterval, to: TimeInterval)) -> [(date: TimeInterval, amount: Double)] {
        var boundedFeedingHistory: [(TimeInterval, Double)] = []
        boundedFeedingHistory.append((dateRange.from, 0.0))
        self.feedingHistory?.forEach({ (entry) in
            if entry.date >= dateRange.from && entry.date <= dateRange.to {
                boundedFeedingHistory.append(entry)
            }
        })
        boundedFeedingHistory.append((dateRange.to, 0.0))
        
        return boundedFeedingHistory
    }
    
    func getFeedingHistoryRemotely(dateRange: (from: TimeInterval, to: TimeInterval), completion: @escaping ([(date: TimeInterval, amount: Double)]) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        self.databaseRef.child(uid).child("feedHistory").observeSingleEvent(of: .value) { (snapshot) in
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
    
    func drawChart(withData: [(date: Double, amount: Double)]) {
        var dataEntries: [BarChartDataEntry] = []
        for i in 0..<withData.count {
            let dataEntry = BarChartDataEntry(x: Double(withData[i].date), y: Double(withData[i].amount))
            dataEntries.append(dataEntry)
        }
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "Feeding Amount")
//        chartDataSet.setColor(.blue)
        let chartData = BarChartData(dataSet: chartDataSet)
        chartData.barWidth = 1000.0
        barChartView.data = chartData
        
        let xaxis = barChartView.xAxis
        xaxis.valueFormatter = axisFormatDelegate
        xaxis.labelPosition = .bottom
        xaxis.labelRotationAngle = 45.0
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func groupByDay(dataset: [(date: TimeInterval, amount: Double)]) -> [(TimeInterval, Double)] {
        //        let aWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: (datePicker?.date)!)
        //        getTemperatures(from: aWeekAgo!, to: (datePicker?.date)!)
        
        var dailyFeedingHistory: [(date: TimeInterval, temp: Double)] = []
        
        let TempDict = Dictionary(grouping: dataset) { (entry) -> String in
            let date = roundingToDay(entry.date)
            return String(date)
        }
        
        for (key, group) in TempDict {
            let sum = group.reduce(0.0) { (runningTotal, nextRecord) -> Double in
                return runningTotal + nextRecord.amount
            }
            dailyFeedingHistory.append((Double(key)!, sum))
        }
        
        dailyFeedingHistory.sort { (date1, date2) -> Bool in
            return date1.date < date2.date
        }
        
        return dailyFeedingHistory
    }

}


class LineViewController: UIViewController {
    
    var datePicker: UIDatePicker?
//    var chartView: BarsChart!
    var chart: UIView?
    
    @IBOutlet weak var dateTextView: UITextField!
    
    var databaseRef = Database.database().reference().child("raspio").child("users")
    var storageRef = Storage.storage()
    var allTemperatures: [(date: Date, temp: Double)] = []
    var temperatures: [(date: Date, temp: Double)] = []
    var dailyTemperatures: [(date: String, temp: Double)] = []
    var hourlyTemperatures: [(hour: String, temp: Double)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //default selected date is current day
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        dateTextView.text = dateFormatter.string(from: Date())
 
        datePickerSetUp()
        dateTextView.allowsEditingTextAttributes = false
        
        let startDate = dateFormatter.date(from: "21/09/2018")
        let endDate = dateFormatter.date(from: "24/09/2018")
        self.getTemperatures(from: startDate!, to: endDate!)
        
        // set default chart
//        self.chart = showChart(points: hourlyTemperatures, color: UIColor.red)
        self.view.addSubview(self.chart!)
        
        // Do any additional setup after loading the view, typically from a nib.
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func choosePeriodSegment(_ sender: UISegmentedControl) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        if dateFormatter.date(from: dateTextView.text!) == nil {
            let error = "Input is not a valid date! Seleted Date is reset to default"
            displayErrorMessage(error)
            dateTextView.text = dateFormatter.string(from: Date())//show the date in textfield
        }
        
        self.chart?.removeFromSuperview()
        
        switch sender.selectedSegmentIndex {
        case 0:
            let hourlyTemp = groupByHour(dataset: self.getTemperatures(from: (datePicker?.date)!, to: (self.datePicker?.date.addingTimeInterval(3600.0*24))!))
            self.chart = showChart(points: hourlyTemp, color: UIColor.red)
        case 1:
            let weekTemp = groupByDay(dataset: self.getTemperatures(from: (datePicker?.date.addingTimeInterval(3600*24*(-7)))!, to: (datePicker?.date)!))
            self.chart = showChart(points: weekTemp, color: UIColor.blue)
        default:
            return
        }
        self.view.addSubview(self.chart!)
    }
    
    
    //need a selected day
    func showChart(points: [(String, Double)], color: UIColor) -> UIView {
//        guard points.count > 0 else {
//            return UIView()
//        }
//        let range = getRange(points: points)
//        //        let domain = getDomain(points: points)
//
//        //        let chartConfig = ChartConfigXY(
//        //            xAxisConfig: ChartAxisConfig (from: domain.min - 1, to: domain.max + 1, by: 1),
//        //            yAxisConfig: ChartAxisConfig (from: range.min - 2, to: range.max + 2, by: 1))
//
//        let chartConfig = BarsChartConfig(valsAxisConfig: ChartAxisConfig(from: range.min - 2, to: range.max + 2, by: 1))
//
//        let width = self.view.frame.width - 30
//        let frame = CGRect(x: 10, y: 180, width: self.view.frame.width - 30, height: self.view.frame.height - 200)
//
//
//        let chart = BarsChart(
//            frame: frame,
//            chartConfig: chartConfig,
//            xTitle: "Time",
//            yTitle: "Temperature",
//            bars: points,
//            color: color,
//            barWidth: CGFloat(width) / CGFloat(points.count + 1) - 10
//            //chart top y label not showing fully
//        )
//
//        self.chartView = chart
//        return chart.view
        return UIView()
    }
    
    
    // get range of the dataset
//    func getRange(points: [(x: String, y: Double)] ) -> (min: Double, max: Double) {
//
//        // get minimum value
//        let min = points.min { (point1, point2) -> Bool in
//            return point1.y < point2.y
//        }
//
//        // get maximum value
//        let max = points.max { (point1, point2) -> Bool in
//            return point1.y < point2.y
//        }
//
//        return (min!.y, max!.y)
//    }
    
//    func getDomain(points: [(x: Date, y: Double)] ) -> (min: Date, max: Date) {
//
//        // get minimum value
//        let min = points.min { (point1, point2) -> Bool in
//            return point1.x < point2.x
//        }
//
//        // get maximum value
//        let max = points.max { (point1, point2) -> Bool in
//            return point1.x < point2.x
//        }
//
//        return (min!.x, max!.x)
//    }
    
    func datePickerSetUp() {
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        
        //set range of datePicker
        datePicker?.maximumDate = Date()//set the maximum date to current date
        datePicker?.minimumDate = Date(timeIntervalSince1970: Double(1536599965547/1000))
        datePicker?.addTarget(self, action: #selector(self.dateChanged(datepicker:)), for: .valueChanged)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.viewTapped(gestureRecogizer:)))
        view.addGestureRecognizer(tapGesture)
        
        dateTextView.inputView = datePicker
        
    }
    
    @objc func viewTapped(gestureRecogizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @objc func dateChanged(datepicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        dateTextView.text = dateFormatter.string(from: datepicker.date)
    }
    
    //display error msg
    func displayErrorMessage(_ errorMessage: String) {
        let alertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func getTemperatures(from: Date, to: Date) -> [(date: Date, temp: Double)] {
        var temperatures: [(date: Date, temp: Double)] = []
        for (date, temp) in self.allTemperatures {
            if date >= from && date <= to {
                temperatures.append((date: date, temp: temp))
            }
        }
        return temperatures
    }
    
    
    func getUserRef() -> DatabaseReference? {
        let user = Auth.auth().currentUser
        guard user != nil else {
            return nil
        }
        let userID = Auth.auth().currentUser!.uid
        return databaseRef.child(userID)
    }
    
    
    // adapted from https://stackoverflow.com/a/31220067
    func groupByHour(dataset: [(date: Date, temp: Double)]) -> [(String, Double)]{
//        let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: (datePicker?.date)!)
//        getTemperatures(from: (datePicker?.date)!, to: nextDay!)
        
        var hourlyTemperatures: [(hour: String, temp: Double)] = []
        
        let TempDict = Dictionary(grouping: dataset) { (record) -> String in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH"
            let date = dateFormatter.string(from: record.date)
            return date
        }
        
        for (key, value) in TempDict {
            let sum = value.reduce(0.0) { (runningTotal, nextRecord) -> Double in
                return runningTotal + nextRecord.temp
            }
            let avgTemp = sum / Double(value.count)
            hourlyTemperatures.append((key + ":00", avgTemp))
        }
        
        hourlyTemperatures.sort { (date1, date2) -> Bool in
            return date1.hour < date2.hour
        }
        
        return hourlyTemperatures
    }
    
    func groupByDay(dataset: [(date: Date, temp: Double)]) -> [(String, Double)] {
//        let aWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: (datePicker?.date)!)
//        getTemperatures(from: aWeekAgo!, to: (datePicker?.date)!)
        
        var dailyTemperatures: [(date: String, temp: Double)] = []
        
        let TempDict = Dictionary(grouping: dataset) { (record) -> String in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            let date = dateFormatter.string(from: record.date)
            return date
        }
        
        for (key, value) in TempDict {
            let sum = value.reduce(0.0) { (runningTotal, nextRecord) -> Double in
                return runningTotal + nextRecord.temp
            }
            let avgTemp = sum / Double(value.count)
            dailyTemperatures.append((key, avgTemp))
        }
        
        dailyTemperatures.sort { (date1, date2) -> Bool in
            return date1.date < date2.date
        }
        
        return dailyTemperatures
    }
    
 
}
