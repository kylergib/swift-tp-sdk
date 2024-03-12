//
//  File.swift
//
//
//  Created by kyle on 3/6/24.
//

import Foundation

public class Response {
    public var type: String?
    public var pluginId: String?
    public var id: String?
    public var data: [ResponseData]?
    public var value: Any?

    public init(type: String? = nil, pluginId: String? = nil, id: String? = nil,
                data: [ResponseData]? = nil, value: Any? = nil)
    {
        self.type = type
        self.pluginId = pluginId
        self.id = id
        self.data = data
        self.value = value
    }
}

public class ResponseData {
    public var id: String?
    public var value: Any?

    public init(id: String?, value: Any?) {
        self.id = id
        self.value = value
    }
}
