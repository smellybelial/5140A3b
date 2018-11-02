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
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: UIBarButtonItem.Style.plain, target: self, action: #selector(TabBarController.signout))
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icons8-settings-filled-50"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(TabBarController.settings))

        // Do any additional setup after loading the view.
    }
    
    @objc func signout() {
        do {
            try Auth.auth().signOut()
        } catch {}
        
        self.navigationController?.popViewController(animated: true)
    }
    
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
