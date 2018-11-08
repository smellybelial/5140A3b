//
//  YoutubeAccountTableViewController.swift
//  PetStation
//
//  Created by Xiaotian LIU on 8/11/18.
//  Copyright © 2018 Xiaotian LIU. All rights reserved.
//

import UIKit
import Firebase

class YoutubeAccountTableViewController: UITableViewController {
    
    let databaseRef: DatabaseReference = Database.database().reference().child("petstation/users")
    var videoID: String?
    var streamKey: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.done))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancel))
        
        // Load videoID and streamKey
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        databaseRef.child(uid).child("toy/videoID").observeSingleEvent(of: .value) { (snapshot) in
            guard let value = snapshot.value as? String else {
                return
            }
            
            self.videoID = value
            self.tableView.reloadData()
        }
        
        databaseRef.child(uid).child("toy/streamKey").observeSingleEvent(of: .value) { (snapshot) in
            guard let value = snapshot.value as? String else {
                return
            }
            
            self.streamKey = value
            self.tableView.reloadData()
        }
    }
    
    @objc func done() {
        self.updateValues()
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        if let videoID = self.videoID, let streamKey = self.streamKey, videoID != "", streamKey != "" {
            databaseRef.child(uid).child("toy").updateChildValues(["videoID": videoID, "streamKey": streamKey])
            let alertController = UIAlertController(title: "Success", message: "videoID and streamKey changed.", preferredStyle: .alert)
            self.present(alertController, animated: true, completion: {
                let _ = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { (_) in
                    alertController.dismiss(animated: true, completion: nil)
                })
            })
        } else {
            let alertController = UIAlertController(title: "Error", message: "VideoID and StreamKey cannot be empty", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @objc func cancel() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func updateValues() {
        let videoIDCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! YoutubeAccountTableViewCell
        let streamKeyCell = self.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! YoutubeAccountTableViewCell
        self.videoID = videoIDCell.inputTextField.text
        self.streamKey = streamKeyCell.inputTextField.text
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "YoutubeAccountCell", for: indexPath) as! YoutubeAccountTableViewCell
        // Configure the cell...
        switch indexPath.row {
        case 0:
//            cell.inputTextField.placeholder = "VideoID, example: tvw6nOEMYL4"
            cell.inputTextField.text = "Hello"
            if let videoID = self.videoID {
                cell.inputTextField.text = videoID
            }
        case 1:
//            cell.inputTextField.placeholder = "StreamKey example: wyee-v0kz-5yzj-c54u"
            cell.inputTextField.text = "How is it going?"
            if let streamKey = self.streamKey {
                cell.inputTextField.text = streamKey
            }
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
