//
//  ProfileTableViewController.swift
//  PetStation
//
//  Created by Xiaotian LIU on 2/11/18.
//  Copyright © 2018 Xiaotian LIU. All rights reserved.
//

import UIKit
import Firebase

protocol PhotoDelegate {
    func updatePhoto(_ fileName: String)
}

protocol NameDelegate {
    func updateName(_ name: String)
}

protocol GenderDelegate {
    func updateGender(_ gender: Gender)
}

protocol WeightDelegate {
    func updateWeight(_ weight: Double)
}

class ProfileTableViewController: UITableViewController, NameDelegate, GenderDelegate, WeightDelegate, PhotoDelegate {
    
    let databaseRef: DatabaseReference = Database.database().reference().child("petstation").child("users")
    let storageRef: Storage = Storage.storage()
    
    var pet: Pet?
    
    var url: String = ""
    var photo: UIImage?
    let defaultPhoto = UIImage(named: "pawprints")

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // initialise a Pet object
        self.pet = Pet()
        
        // get current user's id
        guard let uid = getCurrentUser() else {
            return
        }
        
        // get the pet's information from firebase database
        self.databaseRef.child(uid).child("pet").observeSingleEvent(of: .value) { (snapshot) in
            guard let pet = snapshot.value as? NSDictionary else {
                return
            }
            
            // get pet's name, gender, and weight
            self.pet?.name = (pet["name"] as! String)
            self.pet?.gender = Gender(rawValue: pet["gender"] as! Int)!
            self.pet?.weight = (pet["weight"] as! Double)
            
            // get the url (online path in firebase storage) of pet's photo
            guard let url = pet["photopath"] as? String else {
                // if there is no url, simply set the displayed photo using default photo
                self.photo = self.defaultPhoto
                self.tableView.reloadData()
                return
            }
            self.url = url
            
            // get local file name for pet's photo
            let fileName = pet["filepath"] as! String
            
            // if the local file exists, load it locally; otherwise, load it from firebase, then save it locally
            if self.localFileExists(fileName: fileName) {
                if let image = self.loadImageData(fileName: fileName) {
                    self.photo = image
                    self.tableView.reloadData()
                }
            } else {
                self.storageRef.reference(forURL: self.url).getData(maxSize: 5*1024*1024, completion: { (data, error) in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        let image = UIImage(data: data!)!
                        self.saveLocalData(fileName: fileName, imageData: data!)
                        self.photo = image
                        self.tableView.reloadData()
                    }
                })
            }
        }
    }
    
    // check if there exits a local file with specified name
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
    
    // load image data of a file with specified file name
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
    
    // save image data to a local file with a specified file name
    func saveLocalData(fileName: String, imageData: Data) {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        if let pathComponent = url.appendingPathComponent(fileName) {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            fileManager.createFile(atPath: filePath, contents: imageData, attributes: nil)
        }
    }
    
    // get current user's ID
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
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case 0:
            return 1
        case 1:
            return 3
        default:
            return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        if indexPath.section == 0 {
            let photoCell = tableView.dequeueReusableCell(withIdentifier: "ProfilePhotoCell", for: indexPath) as! PhotoTableViewCell
            photoCell.textLabel?.text = "Photo"
            photoCell.photoView.image = self.photo ?? self.defaultPhoto
            cell = photoCell
        }

        // Configure the cell...
        if indexPath.section == 1 {
            cell = tableView.dequeueReusableCell(withIdentifier: "ProfileAttributeCell", for: indexPath)
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Name"
                cell.detailTextLabel?.text = self.pet?.name
            case 1:
                cell.textLabel?.text = "Gender"
                cell.detailTextLabel?.text = "\((self.pet?.gender)!)"
            case 2:
                cell.textLabel?.text = "Weight"
                cell.detailTextLabel?.text = String((self.pet?.weight)!)
            default:
                break
            }
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            self.performSegue(withIdentifier: "PhotoSegue", sender: nil)
        }
        
        if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                self.performSegue(withIdentifier: "NameSegue", sender: nil)
            case 1:
                self.performSegue(withIdentifier: "GenderSegue", sender: nil)
            case 2:
                self.performSegue(withIdentifier: "WeightSegue", sender: nil)
            default:
                break
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Delegates
    
    // Photo Delegate
    func updatePhoto(_ fileName: String) {
        if let image = self.loadImageData(fileName: fileName) {
            self.photo = image
            self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        }
    }
    
    // Name Delegate
    func updateName(_ name: String) {
        self.pet?.name = name
        self.tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .automatic)
        
        self.setDatabaseValue(name, forKey: "name")
    }
    
    // Gender Delegate
    func updateGender(_ gender: Gender) {
        self.pet?.gender = gender
        self.tableView.reloadRows(at: [IndexPath(row: 1, section: 1)], with: .automatic)
        
        self.setDatabaseValue(gender.rawValue, forKey: "gender")
    }
    
    // Weight Delegate
    func updateWeight(_ weight: Double) {
        self.pet?.weight = weight
        self.tableView.reloadRows(at: [IndexPath(row: 2, section: 1)], with: .automatic)
        
        self.setDatabaseValue(weight, forKey: "weight")
    }
    
    // update the value for uid/pet/key on firebase
    func setDatabaseValue(_ value: Any?, forKey: String) {
        guard let uid = getCurrentUser() else {
            return
        }
        
        self.databaseRef.child(uid).child("pet").child(forKey).setValue(value)
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "PhotoSegue" {
            let controller = segue.destination as! PhotoViewController
            controller.photoDelegate = self
            controller.photo = self.photo
        }
        if segue.identifier == "NameSegue" {
            let controller = segue.destination as! NameTableViewController
            controller.nameDelegate = self
            controller.name = self.pet?.name
        }
        if segue.identifier == "GenderSegue" {
            let controller = segue.destination as! GenderTableViewController
            controller.genderDelegate = self
            controller.gender = self.pet?.gender
        }
        if segue.identifier == "WeightSegue" {
            let controller = segue.destination as! WeightTableViewController
            controller.weightDelegate = self
            controller.weight = self.pet?.weight
        }
    }
    

}
