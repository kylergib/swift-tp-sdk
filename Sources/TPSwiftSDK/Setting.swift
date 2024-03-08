//
//  File.swift
//
//
//  Created by kyle on 3/5/24.
//

import Foundation

public class Setting {
    public var name: String
    public var valueDefault: String?
    private var settingType: SettingType
    public var type: SettingType {
        get { settingType }
        set(value) {
            settingType = value
        }
    }

    public var maxLength: Int?
    public var isPassword: Bool?
    public var minValue: Int?
    public var maxValue: Int?
    public var readOnly: Bool?
    public var toolTip: ToolTip? // is an object in TP

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

public enum SettingType: String {
    case text
    case number
}
