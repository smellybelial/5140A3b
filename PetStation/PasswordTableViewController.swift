//
//  PasswordTableViewController.swift
//  PetStation
//
//  Created by Xiaotian LIU on 8/11/18.
//  Copyright © 2018 Xiaotian LIU. All rights reserved.
//

import UIKit
import Firebase

class PasswordTableViewController: UITableViewController {

    @IBOutlet weak var busy: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.done))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancel))
    }
    
    @objc func done() {
        self.view.endEditing(true)
        let oldPasswordCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! PasswordTableViewCell
        let newPasswordCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! PasswordTableViewCell
        let newPasswordAgainCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as! PasswordTableViewCell
        let oldPassword = oldPasswordCell.passwordTextField.text
        let newPassword = newPasswordCell.passwordTextField.text
        let newPasswordAgain = newPasswordAgainCell.passwordTextField.text
        
        let email = Auth.auth().currentUser?.email
        let credential = EmailAuthProvider.credential(withEmail: email!, password: oldPassword!)
        
        self.busy.startAnimating()
        Auth.auth().currentUser?.reauthenticateAndRetrieveData(with: credential, completion: { (result, error) in
            if error != nil {
                self.busy.stopAnimating()
                self.displayMessage(error!.localizedDescription, "Error")
                return
            }
            
            guard oldPassword != newPassword else {
                self.busy.stopAnimating()
                self.displayMessage("New password is identical with the old one", "Error")
                return
            }
            guard newPassword != "", newPasswordAgain != "" else {
                self.busy.stopAnimating()
                self.displayMessage("password should not be empty", "Error")
                return
            }
            
            guard newPassword == newPasswordAgain else {
                self.busy.stopAnimating()
                self.displayMessage("Make sure you entered password twice correctly", "Error")
                return
            }
            Auth.auth().currentUser?.updatePassword(to: newPassword!, completion: { (error) in
                if error != nil {
                    self.busy.stopAnimating()
                    self.displayMessage(error!.localizedDescription, "Error")
                    return
                }
                self.busy.stopAnimating()
                self.displayMessage("Password changed!", "Success")
                oldPasswordCell.passwordTextField.text = ""
                newPasswordCell.passwordTextField.text = ""
                newPasswordAgainCell.passwordTextField.text = ""
            })
        })
    }
    
    @objc func cancel() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func displayMessage(_ message: String, _ title: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PasswordCell", for: indexPath) as! PasswordTableViewCell

        // Configure the cell...
        switch indexPath.section {
        case 0:
            cell.passwordTextField.placeholder = "Enter Old Password"
        case 1:
            cell.passwordTextField.placeholder = "Enter New Password"
        case 2:
            cell.passwordTextField.placeholder = "Enter New Password Again"
        default:
            break
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Old Password"
        case 1:
            return "New Password"
        case 2:
            return "Re-enter New Passord"
        default:
            return nil
        }
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
