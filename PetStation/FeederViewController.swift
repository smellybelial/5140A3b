//
//  FeederViewController.swift
//  PetStation
//
//  Created by kaijie hou on 1/11/18.
//  Copyright © 2018 Xiaotian LIU. All rights reserved.
//

import UIKit
import Firebase

class FeederViewController: UIViewController {
    var foodAmount: Int?
    var manual: String?
    let databaseRef : DatabaseReference = Database.database().reference().child("users")
    var uid: String?
    var ref: DatabaseReference!

    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var amountSegment: UISegmentedControl!
    
    
    //@IBOutlet weak var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        idLabel.text = getCurrentUser()
        // Do any additional setup after loading the view.
        ref = Database.database().reference()
        uid = getCurrentUser()
        
    }
    
    func getCurrentUser() -> String? {
        guard let uid = Auth.auth().currentUser?.uid else {
            return nil
        }
        return uid
    }
    
    func getLastFeed() {
        
    }
    
    func setFeed() {
        //self.ref.child("petstation/users/\(uid!)/feeder/amount").setValue(foodAmount!)
        self.ref.child("petstation/users/\(uid!)/feeder/manual").setValue(foodAmount)
        
    }
    
    @IBAction func feedButton(button: UIButton) {
        switch (amountSegment.selectedSegmentIndex) {
        case 0 :
            foodAmount = 3 //3/12 //should rotate 3 times, each 90 degrees.
            break
        case 1 :
            foodAmount = 4 //4/12
            break
        case 2 :
            foodAmount = 6 //6/12
            break
        default:
            foodAmount = 2 //2/12 //rotate 2 times, each 90degrees.
            break
        }
        setFeed()
        
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
