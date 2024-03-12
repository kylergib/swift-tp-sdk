//
//  File.swift
//
//
//  Created by kyle on 3/6/24.
//

import Foundation

public class EventResponse {
    public var type: String
    public var pluginId: String
    public var actionId: String
    public var dataId: String
    public var value: Any

    public init(type: String, pluginId: String, actionId: String,
                dataId: String, value: Any)
    {
        self.type = type
        self.pluginId = pluginId
        self.actionId = actionId
        self.dataId = dataId
        self.value = value
    }
}
