//
//  File.swift
//
//
//  Created by kyle on 3/6/24.
//

import Foundation

class Connector {
    var id: String
    var name: String
    var format: String
    var category: Category
    var data: ConnectorData
    var subCategory: Category?
    
    private var runAction: ((ActionResponse) -> Void)?
        var onAction: ((ActionResponse) -> Void)? {
            get { runAction }
            set(value) {
                runAction = value
            }
        }
    // subcategory
    init(id: String, name: String, format: String,
         category: Category, data: ConnectorData) {
        self.id = id
        self.name = name
        self.format = format
        self.category = category
        self.data = data
    }
}


