//
//  File.swift
//
//
//  Created by kyle on 3/5/24.
//

import Foundation

class ActionData {
    var id: String
    private var dataType: ActionDataType
    var type: ActionDataType {
        get { dataType }
        set(value) {
            dataType = value
        }
    }

    var valueChoices: [String]? // TODO: test and see if numbers work
    var extensions: [String]?
    /* This is a collection of extensions allowed to open. This only has effect when used with the file type.
     eg: "extensions": ["*.jpg","*.png",]
     */
    var allowDecimal: Bool?
    var minValue: Int?
    var maxValue: Int?

    init(id: String, type: ActionDataType, valueChoices: [String]? = nil, extensions: [String]? = nil, allowDecimal: Bool? = nil, minValue: Int? = nil, maxValue: Int? = nil) {
        self.id = id
        self.dataType = type
        self.valueChoices = valueChoices
        self.extensions = extensions
        self.allowDecimal = allowDecimal
        self.minValue = minValue
        self.maxValue = maxValue
    }
}

enum ActionDataType {
    case text(String)
    case number(Int)
    case bool(Bool)
    case choice(String)
    case file(String)
    case folder(String)
    case color(String)

    func getTypeAndValue() -> (type: String, defaultValue: Any) {
        switch self {
        case .text(let value):
            return ("text", value)
        case .number(let value):
            return ("number", value)
        case .bool(let value):
            return ("bool", value)
        case .choice(let value):
            return ("choice", value)
        case .file(let value):
            return ("file", value)
        case .folder(let value):
            return ("folder", value)
        case .color(let value):
            return ("color", value)
        }
    }
}
