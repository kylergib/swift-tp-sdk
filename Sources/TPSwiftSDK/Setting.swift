//
//  File.swift
//
//
//  Created by kyle on 3/5/24.
//

import Foundation

class Setting {
    var name: String
    var valueDefault: String?
    private var settingType: SettingType
    var type: SettingType {
        get { settingType }
        set(value) {
            settingType = value
        }
    }

    var maxLength: Int?
    var isPassword: Bool?
    var minValue: Int?
    var maxValue: Int?
    var readOnly: Bool?
    var toolTip: ToolTip? // is an object in TP

    init(name: String, type: SettingType, valueDefault: String? = nil, maxLength: Int? = nil, isPassword: Bool? = nil, minValue: Int? = nil, maxValue: Int? = nil, readOnly: Bool? = nil, toolTip: ToolTip? = nil) {
        self.name = name
        self.settingType = type
        self.valueDefault = valueDefault
        self.maxLength = maxLength
        self.isPassword = isPassword
        self.minValue = minValue
        self.maxValue = maxValue
        self.readOnly = readOnly
        self.toolTip = toolTip
    }
}

enum SettingType: String {
    case text
    case number
}
