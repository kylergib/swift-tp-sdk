//
//  File.swift
//  
//
//  Created by kyle on 3/10/24.
//

import Foundation

public class ListChangeResponse {
    public var instanceId: String // short id in TP API doc
    public var pluginId: String
    public var value: Any?
    public var values: [ResponseData]?
    public var type: String
    public var actionId: String
    public var listId: String
    
    public init(instanceId: String, pluginId: String, value: Any? = nil, values: [ResponseData]? = nil, type: String, actionId: String, listId: String) {
        self.instanceId = instanceId
        self.pluginId = pluginId
        self.value = value
        self.values = values
        self.type = type
        self.actionId = actionId
        self.listId = listId
    }
    
    
}
