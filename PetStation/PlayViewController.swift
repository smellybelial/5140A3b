//
//  PlayViewController.swift
//  PetStation
//
//  Created by Xiaotian LIU on 24/10/18.
//  Copyright © 2018 Xiaotian LIU. All rights reserved.
//

import UIKit
import AVKit
import YouTubePlayer_Swift
import Firebase

enum Move: Int {
    case stop
    case forward
    case backward
    case right
    case left
}

class PlayViewController: UIViewController {
    
//    var uid: String?
    @IBOutlet weak var videoView: YouTubePlayerView!
    let databaseRef: DatabaseReference = Database.database().reference().child("petstation").child("users")
//    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        uid = getCurrentUser()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //uid = getCurrentUser()
        
        
        videoView.playerVars = ["playsinline":1] as YouTubePlayerView.YouTubePlayerParameters
        videoView.loadVideoID("tvw6nOEMYL4") //cP_x1QoQub8, l7K2XiXzrqo
        
    }
    
    func getCurrentUser() -> String? {
        guard let uid = Auth.auth().currentUser?.uid else {
            displayErrorMessage("No user found")
            return nil
        }
        return uid
    }
    
    @IBAction func play(_ sender: UIButton) {
        if sender.titleLabel?.text == "Play" {
            sender.setTitle("Pause", for: UIControl.State.normal)
            videoView.play()
        } else {
            sender.setTitle("Play", for: UIControl.State.normal)
            videoView.pause()
        }
    }

    @IBAction func up(_ sender: UIButton) {
        setDirection(.forward)
    }
    
    @IBAction func stopUp(_ sender: UIButton) {
        //after the button is release, set number to 0 to stop toy moving
        setDirection(.stop)
    }
    
    @IBAction func down(_ sender: Any) {
        setDirection(.backward)
    }
    
    @IBAction func stopDown(_ sender: Any) {
        setDirection(.stop)
    }
    
    @IBAction func right(_ sender: Any) {
        setDirection(.right)
    }
    
    @IBAction func stopRight(_ sender: Any) {
        setDirection(.stop)
    }
    
    @IBAction func left(_ sender: UIButton) {
        setDirection(.left)
    }
    
    @IBAction func stopLeft(_ sender: UIButton) {
        setDirection(.stop)
    }
    
    func setDirection(_ move: Move) {
//        self.ref.child("petstation/users/\(uid!)/toy/action").setValue(num)
        guard let uid = getCurrentUser() else {
            return
        }
        
        //this value will be stored in the firebase and pass to pi, then toy changes moving direction accordingly
        //0 = stop
        //1 = move forward
        //2 = move backward
        //3 = move right
        //4 = move left
        databaseRef.child(uid).child("toy/action").setValue(move.rawValue)
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
