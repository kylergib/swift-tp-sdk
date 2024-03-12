//
//  File.swift
//  
//
//  Created by kyle on 3/12/24.
//

import Foundation

public class PageResponse {
    public var type: String
    public var event: String
    public var pageName: String?
    public var previousPageName: String?
    public var deviceIp: String?
    public var deviceName: String?
    
    public init(type: String, event: String, pageName: String? = nil, previousPageName: String? = nil, deviceIp: String? = nil, deviceName: String? = nil) {
        self.type = type
        self.event = event
        self.pageName = pageName
        self.previousPageName = previousPageName
        self.deviceIp = deviceIp
        self.deviceName = deviceName
    }
}
