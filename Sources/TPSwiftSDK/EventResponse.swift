//
//  File.swift
//  
//
//  Created by kyle on 3/6/24.
//

import Foundation


class EventResponse {
    var type: String
    var pluginId: String
    var actionId: String
    var dataId: String
    var value: Any
    
    init(type: String, pluginId: String, actionId: String,
         dataId: String, value: Any) {
        self.type = type
        self.pluginId = pluginId
        self.actionId = actionId
        self.dataId = dataId
        self.value = value
    }
}
