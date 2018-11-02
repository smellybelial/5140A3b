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
    
    var videoID: String = "tvw6nOEMYL4"
    @IBOutlet weak var videoView: YouTubePlayerView!
    let databaseRef: DatabaseReference = Database.database().reference().child("petstation").child("users")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.videoView.playerVars = ["playsinline":1] as YouTubePlayerView.YouTubePlayerParameters
        self.videoView.loadVideoID(self.videoID) //cP_x1QoQub8, l7K2XiXzrqo
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func getCurrentUserID() -> String? {
        guard let uid = Auth.auth().currentUser?.uid else {
            displayErrorMessage("No user found")
            return nil
        }
        return uid
    }
    
    @IBAction func play(_ sender: UIButton) {
        if sender.titleLabel?.text == "Pause" {
            sender.setTitle("Play", for: UIControl.State.normal)
            self.videoView.pause()
        } else {
            sender.setTitle("Pause", for: UIControl.State.normal)
            self.videoView.play()
        }
    }

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
