//
//  File.swift
//
//
//  Created by kyle on 3/6/24.
//

import Foundation

public class ActionResponse {
    public var type: String?
    public var pluginId: String?
    public var actionId: String?
    public var data: [ActionResponseData]?
    public var value: Any?

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

public class ActionResponseData {
    public var id: String?
    public var value: Any?
    
    init(id: String?, value: Any?) {
        self.id = id
        self.value = value
    }

}
