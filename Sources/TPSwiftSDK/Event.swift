//
//  File.swift
//
//
//  Created by kyle on 3/6/24.
//

import Foundation

class Event {
    var id: String
    var name: String
    var format: String
    var category: Category
    var type: EventType = .communicate
    var valueChoices: [String]? //unsure if it can be a number
    var valueType: EventValueType
    var valueStateId: String
    var subCategory: Category?
    private var runEvent: ((ActionResponse) -> Void)?
    var onEvent: ((ActionResponse) -> Void)? {
        get { runEvent }
        set(value) {
            runEvent = value
        }
    }

    // subcategory
    init(id: String, name: String, format: String, category: Category,
         valueType: EventValueType, valueStateId: String, valueChoices: [String]? = nil)
    {
        self.id = id
        self.name = name
        self.format = format
        self.category = category
        self.valueType = valueType
        self.valueStateId = valueStateId
        self.valueChoices = valueChoices
    }
    
    
}

enum EventType: String {
    case communicate
}

enum EventValueType: String {
    case choice
    case text
}
