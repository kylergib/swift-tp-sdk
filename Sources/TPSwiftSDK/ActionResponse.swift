//
//  File.swift
//
//
//  Created by kyle on 3/6/24.
//

import Foundation

class ActionResponse {
    var type: String?
    var pluginId: String?
    var actionId: String?
    var data: [ActionResponseData]?
    var value: Any?

    init(type: String? = nil, pluginId: String? = nil, actionId: String? = nil,
         data: [ActionResponseData]? = nil, value: Any? = nil)
    {
        self.type = type
        self.pluginId = pluginId
        self.actionId = actionId
        self.data = data
        self.value = value
    }
}

class ActionResponseData {
    var id: String?
    var value: Any?
    
    init(id: String?, value: Any?) {
        self.id = id
        self.value = value
    }

}
