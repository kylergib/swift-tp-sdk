//
//  File.swift
//  
//
//  Created by kyle on 3/6/24.
//

import Foundation


public class Configuration {
    public var colorDark: String?
    public var colorLight: String?
    public var parentCategory: ParentCategory?
    
    public init(colorDark: String? = nil, colorLight: String? = nil, parentCategory: ParentCategory? = nil) {
        self.colorDark = colorDark
        self.colorLight = colorLight
        self.parentCategory = parentCategory
    }
    
}

public enum ParentCategory: String {
    case audio
    case streaming
    case content
    case homeautomation
    case social
    case games
    case misc
}
