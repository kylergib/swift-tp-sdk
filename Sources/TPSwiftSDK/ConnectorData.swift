//
//  File.swift
//  
//
//  Created by kyle on 3/6/24.
//

import Foundation

public class ConnectorData {
    public var id: String
    public var dataType: ConnectorDataType = ConnectorDataType.choice
    public var label: String
    public var defaultValue: String
    public var valueChoices: [String]
    
    // TODO: add connector callback

    init(id: String, valueChoices: [String] = [], defaultValue: String = "") {
        self.id = id
        self.label = id
        self.valueChoices = valueChoices
        self.defaultValue = defaultValue
    }
}

public enum ConnectorDataType: String {
    case choice
}
