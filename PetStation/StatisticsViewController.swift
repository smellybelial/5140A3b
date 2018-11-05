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

class StatisticsViewController: UIViewController, IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm.ss"
        return dateFormatter.string(from: Date(timeIntervalSince1970: value))
    }
    

    @IBOutlet weak var barChartView: BarChartView!
    @IBOutlet weak var inputTextField: UITextField!
    var visitorCounts: [(date: Date, count: Int)] = []
    var feedingHistory: [(date: Double, amount: Double)]?
    var axisFormatDelegate: IAxisValueFormatter?
    let databaseRef: DatabaseReference = Database.database().reference().child("petstation/users")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.axisFormatDelegate = self
        updateChartWithData()
    }
    
    @IBAction func addValue(_ sender: Any) {
        if let value = inputTextField.text , value != "" {
            let date = Date()
            let count = (NumberFormatter().number(from: value)?.intValue)!
            self.visitorCounts.append((date, count))
            inputTextField.text = ""
        }
        updateChartWithData()
    }
    
    func getFeedingHistory() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        self.databaseRef.child(uid).child("feedHistory").observeSingleEvent(of: .value) { (snapshot) in
            guard let dataset = snapshot.value as? NSDictionary else {
                return
            }
            var feedingHistory: [(Double, Double)] = []
            dataset.forEach({ (elem) in
                let date = elem.key as! Double
                let amount = elem.value as! Double
                feedingHistory.append((date, amount))
            })
            self.feedingHistory = feedingHistory
        }
    }
    
    func getFeedingHistory(dateRange: (from: Double, to: Double), completion: @escaping ([(date: Double, amount: Double)]) -> Void) {
        if self.feedingHistory != nil {
            self.getFeedingHistoryLocally(dateRange: dateRange)
        } else {
            guard let uid = Auth.auth().currentUser?.uid else {
                return
            }
            
            self.databaseRef.child(uid).child("feedHistory").observeSingleEvent(of: .value) { (snapshot) in
                guard let dataset = snapshot.value as? NSDictionary else {
                    return
                }
                var feedingHistory: [(Double, Double)] = []
                dataset.forEach({ (elem) in
                    let date = elem.key as! Double
                    let amount = elem.value as! Double
                    if date >= dateRange.from && date <= dateRange.to {
                        feedingHistory.append((date, amount))
                    }
                })
                completion(feedingHistory)
            }
        }
    }
    
    func getFeedingHistoryLocally(dateRange: (from: Double, to: Double)) {
        
    }
    
    func updateChartWithData() {
        var dataEntries: [BarChartDataEntry] = []
        for i in 0..<self.visitorCounts.count {
            let timeIntervalForDate: TimeInterval = visitorCounts[i].date.timeIntervalSince1970
            let dataEntry = BarChartDataEntry(x: Double(timeIntervalForDate), y: Double(visitorCounts[i].count))
            dataEntries.append(dataEntry)
        }
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "Visitor count")
        let chartData = BarChartData(dataSet: chartDataSet)
        barChartView.data = chartData
        
        let xaxis = barChartView.xAxis
        xaxis.valueFormatter = axisFormatDelegate
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

}

/*
class LineViewController: UIViewController {
    
    var datePicker: UIDatePicker?
    var chartView: BarsChart!
    var oneDay = Date()
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
        dateTextView.text = dateFormatter.string(from: oneDay)
 
        datePickerSetUp()
        dateTextView.allowsEditingTextAttributes = false
        
        let startDate = dateFormatter.date(from: "21/09/2018")
        let endDate = dateFormatter.date(from: "24/09/2018")
        self.getTemperatures(from: startDate!, to: endDate!)
        self.getAllTemperatures()
        
        
        // set default chart
        self.chart = showChart(points: hourlyTemperatures, color: UIColor.red)
        self.view.addSubview(self.chart!)
        
        // Do any additional setup after loading the view, typically from a nib.
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func choosePeriodSegment(_ sender: UISegmentedControl) {
        if (isValidDate(dateString: dateTextView.text!) == true) {
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            oneDay = dateFormatter.date(from: dateTextView.text!)!
        }
        else {
            let error = "Input is not a valid date! Seleted Date is reset to default"
            displayErrorMessage(error)
            
            oneDay = Date() //reset to default date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            dateTextView.text = dateFormatter.string(from: oneDay)//show the date in textfield
        }
        
        
        self.chart?.removeFromSuperview()
        
        switch sender.selectedSegmentIndex {
        case 0:
            groupByHour()
            self.chart = showChart(points: hourlyTemperatures, color: UIColor.red)
        case 1:
            groupByDay()
            self.chart = showChart(points: dailyTemperatures, color: UIColor.blue)
        default:
            return
        }
        self.view.addSubview(self.chart!)
    }
    
    //need a selected day
    func showChart(points: [(String, Double)], color: UIColor) -> UIView {
        guard points.count > 0 else {
            return UIView()
        }
        let range = getRange(points: points)
        //        let domain = getDomain(points: points)
        
        //        let chartConfig = ChartConfigXY(
        //            xAxisConfig: ChartAxisConfig (from: domain.min - 1, to: domain.max + 1, by: 1),
        //            yAxisConfig: ChartAxisConfig (from: range.min - 2, to: range.max + 2, by: 1))
        
        let chartConfig = BarsChartConfig(valsAxisConfig: ChartAxisConfig(from: range.min - 2, to: range.max + 2, by: 1))
        
        let width = self.view.frame.width - 30
        let frame = CGRect(x: 10, y: 180, width: self.view.frame.width - 30, height: self.view.frame.height - 200)
        
        
        let chart = BarsChart(
            frame: frame,
            chartConfig: chartConfig,
            xTitle: "Time",
            yTitle: "Temperature",
            bars: points,
            color: color,
            barWidth: CGFloat(width) / CGFloat(points.count + 1) - 10
            //chart top y label not showing fully
        )
        
        self.chartView = chart
        return chart.view
    }
    
    //replace this to the hardcoded line chartPoints
    func getChartPoints(tempTime: NSDictionary) -> Array<(Double, Double)> {
        var chartPoints = Array<(Double, Double)>()
        for (time, temp) in tempTime {
            let newTime = Double(time as! Double)
            let newTemp = Double(temp as! Double)
            
            chartPoints.append((newTime, newTemp))
        }
        return chartPoints
    }
    
    // get range of the dataset
    func getRange(points: [(x: String, y: Double)] ) -> (min: Double, max: Double) {
        
        // get minimum value
        let min = points.min { (point1, point2) -> Bool in
            return point1.y < point2.y
        }
        
        // get maximum value
        let max = points.max { (point1, point2) -> Bool in
            return point1.y < point2.y
        }
        
        return (min!.y, max!.y)
    }
    
    func getDomain(points: [(x: Date, y: Double)] ) -> (min: Date, max: Date) {
        
        // get minimum value
        let min = points.min { (point1, point2) -> Bool in
            return point1.x < point2.x
        }
        
        // get maximum value
        let max = points.max { (point1, point2) -> Bool in
            return point1.x < point2.x
        }
        
        return (min!.x, max!.x)
    }
    
    func datePickerSetUp() {
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        
        //set range of datePicker
        datePicker?.maximumDate = Date()//set the maximum date to current date
        datePicker?.minimumDate = Date(timeIntervalSince1970: Double(1536599965547/1000))
        datePicker?.addTarget(self, action: #selector(LineViewController.dateChanged(datepicker:)), for: .valueChanged)
        
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
        oneDay = (datePicker?.date)!
        dateTextView.text = dateFormatter.string(from: oneDay)
    }
    
    //check string is a valid date
    func isValidDate(dateString: String) -> Bool {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "dd/MM/yyyy"
        if let _ = dateFormatterGet.date(from: dateString) {
            return true
        } else {
            // Invalid date
            return false
        }
    }
    
    //display eroor msg
    func displayErrorMessage(_ errorMessage: String) {
        let alertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func getTemperatures(from: Date, to: Date) {
        self.temperatures.removeAll()
        for (date, temp) in self.allTemperatures {
            if date >= from && date <= to {
                self.temperatures.append((date: date, temp: temp))
            }
        }
    }
    
    func getAllTemperatures() {
        self.allTemperatures.removeAll()
        
        guard let userRef = getUserRef()?.child("history") else {
            return
        }
        
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            guard let value = snapshot.value as? NSDictionary else {
                return
            }
            
            for (date, record) in value {
                let newDate = Date(timeIntervalSince1970: Double(date as! String)! / 1000)
                let newRecord = record as! NSDictionary
                let temp = newRecord["Temperature"] as! Double
                self.allTemperatures.append((date: newDate, temp: temp))
            }
        }
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
    func groupByHour() {
        let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: oneDay)
        getTemperatures(from: oneDay, to: nextDay!)
        self.hourlyTemperatures.removeAll()
        
        let TempDict = Dictionary(grouping: self.temperatures) { (record) -> String in
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
            self.hourlyTemperatures.append((key + ":00", avgTemp))
        }
        
        self.hourlyTemperatures.sort { (date1, date2) -> Bool in
            return date1 < date2
        }
        
        self.hourlyTemperatures.forEach { (temp) in
            print(temp)
        }
    }
    
    func groupByDay() {
        let aWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: oneDay)
        getTemperatures(from: aWeekAgo!, to: oneDay)
        self.dailyTemperatures.removeAll()
        
        let TempDict = Dictionary(grouping: self.temperatures) { (record) -> String in
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
            self.dailyTemperatures.append((key, avgTemp))
        }
        
        self.dailyTemperatures.sort { (date1, date2) -> Bool in
            return date1 < date2
        }
        
        self.dailyTemperatures.forEach { (temp) in
            print(temp)
        }
    }
    
    
}
*/
