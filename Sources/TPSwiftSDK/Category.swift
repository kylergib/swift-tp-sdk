//
//  File.swift
//
//
//  Created by kyle on 3/5/24.
//

import Foundation

class Category {
    var id: String
    var name: String
    var imagePath: String?


    init(id: String, name: String, imagePath: String? = nil) {
        self.id = id
        self.name = name
        self.imagePath = imagePath
    }
}
