//
//  File.swift
//  
//
//  Created by kyle on 3/6/24.
//

import Foundation

class ConnectorData {
    var id: String
    var dataType: ConnectorDataType = ConnectorDataType.choice
    var label: String
    var defaultValue: String
    var valueChoices: [String]
    
    // TODO: add connector callback

    init(id: String, valueChoices: [String] = [], defaultValue: String = "") {
        self.id = id
        self.label = id
        self.valueChoices = valueChoices
        self.defaultValue = defaultValue
    }
}

enum ConnectorDataType: String {
    case choice
}
