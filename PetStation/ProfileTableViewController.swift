//
//  ProfileTableViewController.swift
//  PetStation
//
//  Created by Xiaotian LIU on 2/11/18.
//  Copyright © 2018 Xiaotian LIU. All rights reserved.
//

import UIKit
import Firebase

class ProfileTableViewController: UITableViewController {
    
    let databaseRef: DatabaseReference = Database.database().reference().child("petstation").child("users")
    let storageRef: StorageReference = Storage.storage().reference()
    var name: String?
    var weight: Float?
    var gender: Int?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        guard let uid = getCurrentUser() else {
            return
        }
        
        // get pet name, gender, weight
        self.databaseRef.child(uid).child("pet").observeSingleEvent(of: .value) { (snapshot) in
            guard let pet = snapshot.value as? NSDictionary else {
                return
            }
            
            self.name = pet["name"] as? String
            self.weight = pet["weight"] as? Float
            self.gender = pet["gender"] as? Int
            
        }
    }
    
    func getCurrentUser() -> String? {
        guard let uid = Auth.auth().currentUser?.uid else {
            displayErrorMessage("No user found")
            return nil
        }
        return uid
    }
    
    func displayErrorMessage(_ errorMessage: String) {
        let alertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 4
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath)

        // Configure the cell...
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Photo"
        case 1:
            cell.textLabel?.text = "Name"
        case 2:
            cell.textLabel?.text = "Gender"
        case 3:
            cell.textLabel?.text = "Weight"
        default:
            break
        }

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
