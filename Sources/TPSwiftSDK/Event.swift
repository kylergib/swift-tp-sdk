//
//  File.swift
//
//
//  Created by kyle on 3/6/24.
//

import Foundation

public class Event {
    public var id: String
    public var name: String
    public var format: String
    public var category: Category
    public var type: EventType = .communicate
    public var valueChoices: [String]? //unsure if it can be a number
    public var valueType: EventValueType
    public var valueStateId: String
    public var subCategory: Category?
    private var runEvent: ((ActionResponse) -> Void)?
    public var onEvent: ((ActionResponse) -> Void)? {
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

public enum EventType: String {
    case communicate
}

public enum EventValueType: String {
    case choice
    case text
}
