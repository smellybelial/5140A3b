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


class PlayViewController: UIViewController {
    
    var uid: String?
    @IBOutlet weak var videoView: YouTubePlayerView!
    let databaseRef : DatabaseReference = Database.database().reference().child("petstation").child("users")
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uid = getCurrentUser()
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

    //0 = stop
    //1 = move forward
    //2 = move backward
    //3 = move right
    //4 = move left
    @IBAction func up(_ sender: UIButton) {
        setDirection(1)
    }
    
    @IBAction func stopUp(_ sender: UIButton) {
        //after the button is release, set number to 0 to stop toy moving
        setDirection(0)
    }
    
    
    @IBAction func down(_ sender: Any) {
        setDirection(2)
    }
    
    
    @IBAction func stopDown(_ sender: Any) {
        setDirection(0)
    }
    
    
    
    @IBAction func right(_ sender: Any) {
        setDirection(3)
    }
    
    
    @IBAction func stopRight(_ sender: Any) {
        setDirection(0)
    }
    
    @IBAction func left(_ sender: UIButton) {
        //print("turn left")
        setDirection(4)
    }
    
    @IBAction func stopLeft(_ sender: UIButton) {
        //print("stop turning left")
        setDirection(0)
    }
    
    func setDirection(_ num: Int) {
//        self.ref.child("petstation/users/\(uid!)/toy/action").setValue(num)
        guard let uid = getCurrentUser() else {
            return
        }
        
        //this value will be stored in the firebase and pass to pi, then toy changes moving direction accordingly
        databaseRef.child(uid).child("toy/action").setValue(num)
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
