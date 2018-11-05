//
//  PhotoViewController.swift
//  PetStation
//
//  Created by Xiaotian LIU on 3/11/18.
//  Copyright © 2018 Xiaotian LIU. All rights reserved.
//

import UIKit
import Firebase

class PhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var photo: UIImage!
    var photoDelegate: PhotoDelegate!
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var busy: UIActivityIndicatorView!
    var actionSheet: UIAlertController?
    
    let databaseRef = Database.database().reference().child("petstation").child("users")
    let storageRef = Storage.storage().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(self.displayOptions))
        
        if let photo = self.photo {
            self.photoView.image = photo
        } else {
            self.busy.startAnimating()
//            photoDelegate
        }
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let actionSheet = self.actionSheet {
            actionSheet.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func displayOptions() {
        self.actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        self.actionSheet!.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { (_) in
            self.takePhoto()
        }))
        self.actionSheet!.addAction(UIAlertAction(title: "Choose from Album", style: .default, handler: { (_) in
            self.chooseFromAlum()
        }))
        self.actionSheet!.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(self.actionSheet!, animated: true, completion: nil)
    }
    
    func takePhoto() {
        let controller = UIImagePickerController()
        guard UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) else {
            displayMessage("Camera unvailable", "Error")
            return
        }
        
        controller.sourceType = UIImagePickerController.SourceType.camera
        controller.allowsEditing = true
        controller.delegate = self
        self.present(controller, animated: true, completion: nil)
    }
    
    func chooseFromAlum() {
        let controller = UIImagePickerController()
        
        controller.sourceType = UIImagePickerController.SourceType.photoLibrary
        controller.allowsEditing = true
        controller.delegate = self
        self.present(controller, animated: true, completion: nil)
    }
    
    
    
    func savePhoto(_ pickedImage: UIImage?) {
        guard let image = pickedImage else {
            displayMessage("Cannot save until a photo has been taken!", "Error")
            return
        }
        
        guard let userID = Auth.auth().currentUser?.uid else {
            displayMessage("Cannot upload image until logged in", "Error")
            return
        }
        
        self.busy.startAnimating()
        
        // Preparing timestamp and image data
        let date = UInt(Date().timeIntervalSince1970)
        var data = Data()
        data = UIImage.jpegData(image)(compressionQuality: 0.1)!
        
        // Save image data to firebase storage
        let imageRef = storageRef.child("\(userID)/\(date)")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        imageRef.putData(data, metadata: metadata) { (metaData, error) in
            if error != nil {
                self.displayMessage("Could not upload image", "Error")
            } else {
                // get image downloadURL, and save it to firebase database
                imageRef.downloadURL(completion: { (url, error) in
                    // get image downloadURL in firebase storage
                    guard let downloadURL = url?.absoluteString else {
                        return
                    }
                    
                    // save to firebase database
                    self.databaseRef.child(userID).child("pet/photopath").setValue(downloadURL)
                    self.databaseRef.child(userID).child("pet/filepath").setValue("\(date)")
                    
                    self.photoView.image = image
                    self.busy.stopAnimating()
                    
                    let alertController = UIAlertController(title: "Success", message: "Image saved to Firebase", preferredStyle: UIAlertController.Style.alert)
                    self.present(alertController, animated: true, completion: {
                        let _ = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { (_) in
                            alertController.dismiss(animated: true, completion: nil)
                        })
                    })
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
        
        self.photoDelegate.updatePhoto("\(date)")
    }
    
    // MARK: - ImagePickerController Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.savePhoto(pickedImage)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        displayMessage("There was an error in getting the photo", "Error")
        self.dismiss(animated: true, completion: nil)
    }
    
    func displayMessage(_ message: String, _ title: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}
