//
//  PlayViewController.swift
//  PetStation
//
//  Created by Xiaotian LIU on 24/10/18.
//  Copyright © 2018 Xiaotian LIU. All rights reserved.
//

import UIKit
import AVKit
import YouTubePlayer
import Firebase

enum Move: Int {
    case stop, forward, backward, right, left
}

enum CameraSwitch: String {
    case ON, OFF
}

class PlayViewController: UIViewController {
    
    var videoID: String = "tvw6nOEMYL4"
    @IBOutlet weak var videoView: YouTubePlayerView!
    let databaseRef: DatabaseReference = Database.database().reference().child("petstation").child("users")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
        self.videoView.playerVars = ["playsinline":1] as YouTubePlayerView.YouTubePlayerParameters
        self.loadVideo()
        
        //
        guard let uid = getCurrentUserID() else {
            return
        }
        self.databaseRef.child(uid).child("toy/cameraSwitch").onDisconnectSetValue(CameraSwitch.OFF.rawValue)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setCameraSwitch(.ON)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        setCameraSwitch(.OFF)
    }
    
    func loadVideo() {
        guard let uid = getCurrentUserID() else {
            return
        }
        
        self.databaseRef.child(uid).child("toy/videoID").observe(.value) { (snapshot) in
            guard let value = snapshot.value as? String else {
                return
            }
            
            self.videoID = value
            self.videoView.loadVideoID(self.videoID)

        }
    }
    
    func getCurrentUserID() -> String? {
        guard let uid = Auth.auth().currentUser?.uid else {
            displayErrorMessage("No user found")
            return nil
        }
        return uid
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if UIDevice.current.orientation.isLandscape {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            self.tabBarController?.tabBar.isHidden = true
        } else {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            self.tabBarController?.tabBar.isHidden = false
        }
    }
    
//    @IBAction func play(_ sender: UIButton) {
//        if sender.titleLabel?.text == "Pause" {
//            sender.setTitle("Play", for: UIControl.State.normal)
//            self.videoView.pause()
//        } else {
//            sender.setTitle("Pause", for: UIControl.State.normal)
//            self.videoView.play()
//        }
//    }

    // touch down UP button to move forward
    @IBAction func up(_ sender: UIButton) {
        setDirection(.forward)
    }
    
    // release UP button to stop
    @IBAction func stopUp(_ sender: UIButton) {
        setDirection(.stop)
    }
    
    // touch down DOWN button to move backward
    @IBAction func down(_ sender: Any) {
        setDirection(.backward)
    }
    
    // release DOWN button to stop
    @IBAction func stopDown(_ sender: Any) {
        setDirection(.stop)
    }
    
    // touch down RIGHT button to turn right
    @IBAction func right(_ sender: Any) {
        setDirection(.right)
    }
    
    // release RIGHT button to stop
    @IBAction func stopRight(_ sender: Any) {
        setDirection(.stop)
    }
    
    // touch down LEFT button to turn left
    @IBAction func left(_ sender: UIButton) {
        setDirection(.left)
    }
    
    // release LEFT button to stop
    @IBAction func stopLeft(_ sender: UIButton) {
        setDirection(.stop)
    }
    
    func setDirection(_ move: Move) {
        guard let uid = getCurrentUserID() else {
            return
        }
        
        //this value will be stored in the firebase and pass to pi, then toy changes moving direction accordingly
        //0 = stop
        //1 = move forward
        //2 = move backward
        //3 = move right
        //4 = move left
        self.databaseRef.child(uid).child("toy/action").setValue(move.rawValue)
    }
    
    func setCameraSwitch(_ cameraSwitch: CameraSwitch) {
        guard let uid = getCurrentUserID() else {
            return
        }
        
        self.databaseRef.child(uid).child("toy/cameraSwitch").setValue(cameraSwitch.rawValue)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func displayErrorMessage(_ errorMessage: String) {
        let alertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }

}
