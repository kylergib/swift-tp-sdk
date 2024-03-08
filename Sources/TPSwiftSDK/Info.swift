//
//  File.swift
//  
//
//  Created by kyle on 3/8/24.
//

import Foundation

public class Info {
    public var sdkVersion: Int
    public var tpVersionString: String
    public var tpVersionCode: Int
    public var pluginVersion: Int
    public var status: String
    
    public init(sdkVersion: Int, tpVersionString: String, tpVersionCode: Int, pluginVersion: Int, status: String) {
        self.sdkVersion = sdkVersion
        self.tpVersionString = tpVersionString
        self.tpVersionCode = tpVersionCode
        self.pluginVersion = pluginVersion
        self.status = status
    }
    
}
