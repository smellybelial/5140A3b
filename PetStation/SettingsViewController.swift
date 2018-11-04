//
//  SettingsViewController.swift
//  PetStation
//
//  Created by Xiaotian LIU on 4/11/18.
//  Copyright © 2018 Xiaotian LIU. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let alertController = UIAlertController(title: "Error", message: "Hello", preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        alertController.addAction(UIAlertAction(title: "Pop", style: .cancel, handler: { (_) in
            self.navigationController?.popViewController(animated: true)
        }))
        
        self.present(alertController, animated: true, completion: nil)
//        self.present(alertController, animated: true, completion: {
//            alertController.dismiss(animated: true, completion: {self.navigationController?.popViewController(animated: true)})
//        })


        // Do any additional setup after loading the view.
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
