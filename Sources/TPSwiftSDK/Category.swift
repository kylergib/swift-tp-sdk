//
//  File.swift
//
//
//  Created by kyle on 3/5/24.
//

import Foundation

public class Category {
    public var id: String
    public var name: String
    public var imagePath: String?


    public init(id: String, name: String, imagePath: String? = nil) {
        self.id = id
        self.name = name
        self.imagePath = imagePath
    }
}
