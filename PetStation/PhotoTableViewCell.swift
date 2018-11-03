//
//  PhotoTableViewCell.swift
//  PetStation
//
//  Created by Xiaotian LIU on 3/11/18.
//  Copyright © 2018 Xiaotian LIU. All rights reserved.
//

import UIKit

class PhotoTableViewCell: UITableViewCell {

    @IBOutlet weak var photoView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
