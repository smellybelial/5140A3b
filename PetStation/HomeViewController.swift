//
//  HomeViewController.swift
//  PetStation
//
//  Created by Xiaotian LIU on 4/11/18.
//  Copyright © 2018 Xiaotian LIU. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var helloTextField: UILabel!
    @IBOutlet weak var datetimeTextField: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.datetimeTextField.text = "Today is \(self.toString(date: Date(), format: "EEEE, dd/MMM/yyyy, HH:mm"))"
        
        // get the hour of the current time
        let hour = Calendar.current.component(.hour, from: Date())
        
        // set a string according to current hour
        var period = ""
        if hour < 12 {
            period = "morning"
        } else if hour < 18 {
            period = "afternoon"
        } else {
            period = "evening"
        }
        
        self.helloTextField.text = "Good \(period)!"
    
    }
    
    // convert a date into a string with a specified format
    func toString(date: Date, format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
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
