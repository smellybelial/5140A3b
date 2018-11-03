//
//  CameraViewController.swift
//  PetStation
//
//  Created by Xiaotian LIU on 3/11/18.
//  Copyright © 2018 Xiaotian LIU. All rights reserved.
//

import UIKit
import Firebase

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    let databaseRef = Database.database().reference().child("petstation").child("users")
    let storageRef = Storage.storage().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        self.navigationItem.rightBarButtonItem = 
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func takePhoto(_ sender: Any) {
        let controller = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            controller.sourceType = UIImagePickerController.SourceType.camera
        }
        else {
            controller.sourceType = UIImagePickerController.SourceType.photoLibrary
        }
        
        controller.allowsEditing = false
        controller.delegate = self
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func savePhoto(_ sender: Any) {
        guard let image = imageView.image else {
            displayMessage("Cannot save until a photo has been taken!", "Error")
            return
        }
        
        guard let userID = Auth.auth().currentUser?.uid else {
            displayMessage("Cannot upload image until logged in", "Error")
            return
        }
        
        let date = UInt(Date().timeIntervalSince1970)
        var data = Data()
//        data = UIImageJPEGRepresentation(image, 0.8)!
        data = UIImage.jpegData(image)(compressionQuality: 0.8)!
        
        let imageRef = storageRef.child("\(userID)/\(date)")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        imageRef.putData(data, metadata: metadata) { (metaData, error) in
            if error != nil {
                self.displayMessage("Could not upload image", "Error")
            } else {
//                let downloadURL = metaData!.downloadURL()!.absoluteString
                imageRef.downloadURL(completion: { (url, error) in
                    guard let downloadURL = url?.absoluteString else {
                        return
                    }
                    self.databaseRef.child(userID).child("pet/photopath").setValue(downloadURL)
                    self.databaseRef.child(userID).child("pet/filepath").setValue("\(date)")
                    self.displayMessage("Image saved to Firebase", "Success")
                })
            }
        }
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        
        if let pathComponent = url.appendingPathComponent("\(date)") {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            fileManager.createFile(atPath: filePath, contents: data, attributes: nil)
        }
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        displayMessage("There was an error in getting the photo", "Error")
        self.dismiss(animated: true, completion: nil)
    }
    
    func displayMessage(_ message: String,_ title: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }

}
