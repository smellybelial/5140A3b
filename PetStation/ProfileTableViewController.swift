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
    let storageRef: Storage = Storage.storage()
    var name: String = ""
    var weight: Float = 0.0
    var gender: String = ""
    var photopath: String = ""
    var photo: UIImage?

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
            
            self.name = pet["name"] as? String ?? "Unknown"
            self.weight = pet["weight"] as? Float ?? 0.0
            self.gender = pet["gender"] as? String ?? "Unknown"
            let url = pet["photopath"] as? String ?? "?"
//            let fileName = pet["fileName"] as! String
            self.tableView.reloadData()
            
//            if self.photopath != url {
//                self.photopath = url
//                if self.localFileExists(fileName: fileName) {
//                    if let image = self.loadImageData(fileName: fileName) {
//                        self.photo = image
////                        self.collectionView?.reloadSections([0])
//                    }
//                } else {
//                    self.storageRef.reference(forURL: self.photopath).getData(maxSize: 5*1024*1024, completion: { (data, error) in
//                        if let error = error {
//                            print(error.localizedDescription)
//                        } else {
//                            let image = UIImage(data: data!)!
//                            self.saveLocalData(fileName: fileName, imageData: data!)
//                            self.photo = image
////                            self.collectionView?.reloadSections([0])
//                        }
//                    })
//                }
//            }
            
        }
    }
    
    func localFileExists(fileName: String) -> Bool {
        var localFileExists = false
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        if let pathComponent = url.appendingPathComponent(fileName) {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            localFileExists = fileManager.fileExists(atPath: filePath)
        }
        
        return localFileExists
    }
    
    func loadImageData(fileName: String) -> UIImage? {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        var image: UIImage?
        if let pathComponent = url.appendingPathComponent(fileName) {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            let fileData = fileManager.contents(atPath: filePath)
            image = UIImage(data: fileData!)
        }
        
        return image
    }
    
    func saveLocalData(fileName: String, imageData: Data) {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        if let pathComponent = url.appendingPathComponent(fileName) {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            fileManager.createFile(atPath: filePath, contents: imageData, attributes: nil)
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
            cell.detailTextLabel?.text = self.photopath
        case 1:
            cell.textLabel?.text = "Name"
            cell.detailTextLabel?.text = self.name
        case 2:
            cell.textLabel?.text = "Gender"
            cell.detailTextLabel?.text = self.gender
        case 3:
            cell.textLabel?.text = "Weight"
            cell.detailTextLabel?.text = String(self.weight)
        default:
            break
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            self.performSegue(withIdentifier: "PhotoSegue", sender: nil)
        case 1:
            self.performSegue(withIdentifier: "NameSegue", sender: nil)
        case 2:
            self.performSegue(withIdentifier: "GenderSegue", sender: nil)
        case 3:
            self.performSegue(withIdentifier: "WeightSegue", sender: nil)
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
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
