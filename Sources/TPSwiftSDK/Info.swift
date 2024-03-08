//
//  File.swift
//  
//
//  Created by kyle on 3/8/24.
//

import Foundation

class Info {
    var sdkVersion: Int
    var tpVersionString: String
    var tpVersionCode: Int
    var pluginVersion: Int
    var status: String
    
    init(sdkVersion: Int, tpVersionString: String, tpVersionCode: Int, pluginVersion: Int, status: String) {
        self.sdkVersion = sdkVersion
        self.tpVersionString = tpVersionString
        self.tpVersionCode = tpVersionCode
        self.pluginVersion = pluginVersion
        self.status = status
    }
    
}
