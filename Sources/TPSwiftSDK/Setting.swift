//
//  File.swift
//
//
//  Created by kyle on 3/5/24.
//

import Foundation
import LoggerSwift

public class Setting {
    private static var logger = Logger(current: Action.self)
    public var name: String
    public var valueDefault: String?
    private var settingType: SettingType
    public var type: SettingType {
        get { settingType }
        set(value) {
            settingType = value
        }
    }

    private var settingChange: ((SettingResponse) -> Void)?
    public var onSettingChange: ((SettingResponse) -> Void)? {
        get { settingChange }
        set(value) {
            settingChange = value
        }
    }

    public var maxLength: Int?
    public var isPassword: Bool?
    public var minValue: Int?
    public var maxValue: Int?
    public var readOnly: Bool?
    public var toolTip: ToolTip? // is an object in TP

    public init(name: String, type: SettingType, valueDefault: String? = nil, maxLength: Int? = nil, isPassword: Bool? = nil, minValue: Int? = nil, maxValue: Int? = nil, readOnly: Bool? = nil, toolTip: ToolTip? = nil) {
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

    public static func updateSetting(settingName: String, value: String) {
        if TPClient.tpClient == nil || TPClient.tpClient!.plugin == nil {
            logger.error("Cannot send update, because tpClient is nul or plugin is nil")
            return
        }

        var dict = [String: Any]()
        dict["type"] = "settingUpdate"
        dict["name"] = settingName
        dict["value"] = value

        if let jsonString = Util.dictToJsonString(dict: dict) {
            TPClient.currentHandler?.sendMessage(message: jsonString + "\n")
        }
    }

    public static func setLoggerLevel(level: String) {
        logger.setLevel(level: level)
    }

    public static func getLoggerLevel() -> String {
        return logger.getLevel()
    }
}

public enum SettingType: String {
    case text
    case number
}
