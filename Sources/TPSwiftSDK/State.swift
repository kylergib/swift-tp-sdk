//
//  File.swift
//  
//
//  Created by kyle on 3/6/24.
//

import Foundation


class State {
    var id: String
    var type: StateType
    var description: String
    var defaultValue: String
    var valueChoices: [String]
    var parentGroup: String?
    var category: Category
    init(id: String, type: StateType, description: String, category: Category,
         defaultValue: String = "", valueChoices: [String] = []) {
        self.id = id
        self.type = type
        self.category = category
        self.description = description
        self.defaultValue = defaultValue
        self.valueChoices = valueChoices
    }
}


enum StateType: String {
    case choice
    case text
}
