//
//  File.swift
//  
//
//  Created by kyle on 3/8/24.
//

import Foundation


public class SettingResponse {
    public var name: String
    public var value: Any
    
    public init(name: String, value: Any) {
        self.name = name
        self.value = value
    }
}
