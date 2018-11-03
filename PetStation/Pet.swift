//
//  Pet.swift
//  PetStation
//
//  Created by Xiaotian LIU on 3/11/18.
//  Copyright © 2018 Xiaotian LIU. All rights reserved.
//

import UIKit

enum Gender: String {
    case Male, Female, Other, Unknown
    init?(hashValue: Int) {
        switch hashValue {
        case 0:
            self.init(rawValue: "Male")
        case 1:
            self.init(rawValue: "Female")
        case 2:
            self.init(rawValue: "Other")
        default:
            self.init(rawValue: "Unknown")
        }
    }
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
