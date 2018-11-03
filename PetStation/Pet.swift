//
//  Pet.swift
//  PetStation
//
//  Created by Xiaotian LIU on 3/11/18.
//  Copyright © 2018 Xiaotian LIU. All rights reserved.
//

import UIKit

enum Gender {
    case Male, Female, Other, Unknown
}

class Pet: NSObject {
    var name: String = "Anonymous"
    var gender: Gender = .Unknown
    var weight: Double = 0.0
    
    init(name: String, gender: Gender, weight: Double) {
        self.name = name
        self.gender = gender
        self.weight = weight
    }
}
