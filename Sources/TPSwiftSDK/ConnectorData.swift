//
//  File.swift
//  
//
//  Created by kyle on 3/6/24.
//

import Foundation

public class ConnectorData {
    public var id: String
    public var dataType: ConnectorDataType
    public var label: String
    public var defaultValue: String
    public var valueChoices: [String]
    

    public init(id: String, dataType: ConnectorDataType, valueChoices: [String] = [], defaultValue: String = "") {
        self.id = id
        self.label = id
        self.dataType = dataType
        self.valueChoices = valueChoices
        self.defaultValue = defaultValue
    }
}

public enum ConnectorDataType: String {
    case choice
    case text
    case number
}
