//
//  File.swift
//  
//
//  Created by kyle on 3/6/24.
//

import Foundation


class Configuration {
    var colorDark: String?
    var colorLight: String?
    var parentCategory: ParentCategory?
    
    init(colorDark: String? = nil, colorLight: String? = nil, parentCategory: ParentCategory? = nil) {
        self.colorDark = colorDark
        self.colorLight = colorLight
        self.parentCategory = parentCategory
    }
    
}

enum ParentCategory: String {
    case audio
    case streaming
    case content
    case homeautomation
    case social
    case games
    case misc
}
