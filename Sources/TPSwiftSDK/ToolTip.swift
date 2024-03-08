//
//  File.swift
//  
//
//  Created by kyle on 3/5/24.
//

import Foundation


public class ToolTip {
    
    public var title: String?
    public var body: String
    public var docUrl: String?
    
    init(body: String) {
        self.body = body
    }
}
