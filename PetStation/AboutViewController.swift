//
//  AboutViewController.swift
//  PetStation
//
//  Created by Xiaotian LIU on 9/11/18.
//  Copyright © 2018 Xiaotian LIU. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

    @IBOutlet weak var authorsTextView: UITextView!
    @IBOutlet weak var ackTextView: UITextView!
//    @IBOutlet weak var refTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.authorsTextView.text = "Kaijie Hou, StudentID: 26369230\n"
            + "Xiaotian Liu, StudentID: 28609921\n\n"
            + "Kaijie did most part of the IoT side, Xiaotian did most of the iOS side"
        // Do any additional setup after loading the view.
        self.ackTextView.text = "We would like to thank Kyle, who offered us great help in choosing sensors, arduinos as well as other IoT ideas.\n\n"
            + "We also appreciate the lovely icons made by Dave Gandy, Sergiu Bagrin, Freepik and mynamepongat at www.flaticon.com."
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
