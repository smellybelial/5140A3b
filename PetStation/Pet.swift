//
//  Pet.swift
//  PetStation
//
//  Created by Xiaotian LIU on 3/11/18.
//  Copyright © 2018 Xiaotian LIU. All rights reserved.
//

import UIKit

enum Gender: Int {
    case Male, Female, Other, Unknown
}

class Pet: NSObject {
    var name: String
    var gender: Gender
    var weight: Double
    
    init(name: String, gender: Gender, weight: Double) {
        self.name = name
        self.gender = gender
        self.weight = weight
    }
    
    convenience override init() {
        self.init(name: "Anonymous", gender: .Unknown, weight: 0.0)
    }
}
