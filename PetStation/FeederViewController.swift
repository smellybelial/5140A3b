//
//  FeederViewController.swift
//  PetStation
//
//  Created by kaijie hou on 1/11/18.
//  Copyright © 2018 Xiaotian LIU. All rights reserved.
//

import UIKit
import Firebase

enum Cup: Int {
    case Quarter = 3 // 12/4
    case Third = 4 // 12/3
    case Half = 6 // 12/2
    case Sixth = 2  // 12/6
}

class FeederViewController: UIViewController {
    let databaseRef: DatabaseReference = Database.database().reference().child("petstation").child("users")

    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var amountSegment: UISegmentedControl!
    
    
    //@IBOutlet weak var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        idLabel.text = Auth.auth().currentUser?.email
        // Do any additional setup after loading the view.
        
    }
    
    func getCurrentUser() -> String? {
        guard let uid = Auth.auth().currentUser?.uid else {
            return nil
        }
        return uid
    }
    
//    func getLastFeed() {
//
//    }
    
    func setFeed(cup: Cup) {
        guard let uid = getCurrentUser() else {
            return
        }
        let manual = self.databaseRef.child("\(uid)/feeder/manual")
        manual.setValue(cup.rawValue)
    }
    
    @IBAction func feedButton(button: UIButton) {
        var foodAmount = Cup.Sixth
        
        switch (amountSegment.selectedSegmentIndex) {
        case 0 :
            foodAmount = Cup.Quarter //3/12     rotate 3 times, each 90 degrees.
            break
        case 1 :
            foodAmount = Cup.Third //4/12       rotate 4 times, each 90 degrees.
            break
        case 2 :
            foodAmount = Cup.Half //6/12        rotate 6 times, each 90 degrees.
            break
        default:
            foodAmount = Cup.Sixth //2/12       rotate 2 times, each 90 degrees.
            break
        }
        setFeed(cup: foodAmount)
        
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
