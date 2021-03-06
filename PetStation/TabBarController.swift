//
//  TabBarController.swift
//  PetStation
//
//  Created by Xiaotian LIU on 25/10/18.
//  Copyright © 2018 Xiaotian LIU. All rights reserved.
//

import UIKit
import Firebase

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create a left BarButtonItem for logout
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.signout))
        
        // Create a right BarButtonItem for going to settings page
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icons8-settings-filled-50"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.settings))

    }
    
    // Sign out
    @objc func signout() {
        do {
            try Auth.auth().signOut()
            self.navigationController?.popViewController(animated: true)
        } catch {}
    }
    
    // Go to settings page
    @objc func settings() {
        performSegue(withIdentifier: "SettingsSegue", sender: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
