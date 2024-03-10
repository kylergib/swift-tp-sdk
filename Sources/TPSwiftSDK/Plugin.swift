//
//  File.swift
//
//
//  Created by kyle on 3/5/24.
//

import Foundation

public class Plugin {
    // LEFT OFF ON ENTRY
    public var api: ApiVersion

    public var version: Int
    public var name: String
    public var pluginId: String
    public var configuration: Configuration?
    public var pluginStartCommand: String?
    public var pluginStartCmdWindows: String?
    public var pluginStartCmdMac: String?
    public var pluginStartCmdLinux: String?
    public var categories = [String: Category]()
    public var settings = [String: Setting]()

//    public var actionCategories = [String: Category]()
    public var actions = [String: Action]() // TODO: replace with action class
//    public var eventCategories = [String: Category]()
    public var events = [String: Event]() // TODO: replace with events class
//    public var connectorCategories = [String: Category]()
    public var connectors = [String: Connector]() // TODO: replace with connector class
//    public var stateCategories = [String: Category]()
    public var states = [String: State]() // TODO: replace with state class
    public var subCategories: [String: Category]? // TODO: would this be an array of catogories? maybe child class of category
    public var notifications = [String: TPNotification]()
    
    private var settingsChange: (([SettingResponse]) -> Void)?
    public var onSettingsChange: (([SettingResponse]) -> Void)? {
        get { settingsChange }
        set(value) {
            settingsChange = value
        }
    }

    public init(api: ApiVersion, version: Int, name: String, pluginId: String) {
        self.api = api
        self.version = version
        self.name = name
        self.pluginId = pluginId
    }

    public func addCategory(category: Category) {
        categories[category.id] = category
    }

    public func addSetting(setting: Setting) {
        settings[setting.name] = setting
    }

    public func addAction(action: Action) {
        actions[action.id] = action
    }

    public func addEvent(event: Event) {
        events[event.id] = event
    }

    public func addConnector(connector: Connector) {
        connectors[connector.id] = connector
    }
    public func addNotification(notification: TPNotification) {
        notifications[notification.id] = notification
    }

    public func addState(state: State) {
        states[state.id] = state
    }

    public func getActionById(actionId: String) -> Action? {
        return actions[actionId]
    }
    public func getConnectorById(connectorId: String) -> Connector? {
        return connectors[connectorId]
    }
    public func getNotificationById(notificationId: String) -> TPNotification? {
        return notifications[notificationId]
    }

    public func buildEntry(folderURL: URL, fileName: String) {
//        print("starting build")
        var rootDict = [String: Any]()
        rootDict["api"] = api.rawValue
        rootDict["version"] = version
        rootDict["name"] = name
        rootDict["id"] = pluginId
        rootDict["configuration"] = buildConfiguration()
        rootDict["plugin_start_cmd"] = pluginStartCommand
        rootDict["plugin_start_cmd_windows"] = pluginStartCmdWindows
        rootDict["plugin_start_cmd_mac"] = pluginStartCmdMac
        rootDict["plugin_start_cmd_linux"] = pluginStartCmdLinux
        rootDict["settings"] = buildSettings()
        rootDict["categories"] = buildCategories()
//        print(rootDict)
        do {
            // Convert the dictionary into JSON data
            let jsonData = try JSONSerialization.data(withJSONObject: rootDict, options: .prettyPrinted)

            // Define the folder URL and file name
//            let folderURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//            let fileName = "entry.tp" // Your file name

            // Create the full file URL by appending the file name to the folder URL
            let fileURL = folderURL.appendingPathComponent(fileName)

            // Check if the folder exists and create it if it doesn't
            if !FileManager.default.fileExists(atPath: folderURL.path) {
                do {
                    try FileManager.default.createDirectory(atPath: folderURL.path, withIntermediateDirectories: true, attributes: nil)
                    print("Folder created at \(folderURL.path)")
                } catch {
                    print("Error creating folder: \(error)")
                    return
                }
            } else {
                print("Folder already exists.")
            }

            // Write the JSON data to the file
            try jsonData.write(to: fileURL, options: .atomic)
            print("File saved: \(fileURL)")
        } catch {
            print("Error serializing JSON: \(error)")
        }
    }

    private func buildConfiguration() -> [String: Any]? {
        var config = [String: Any]()
        config["colorDark"] = configuration?.colorDark
        config["colorLight"] = configuration?.colorLight
        config["parentCategory"] = configuration?.parentCategory?.rawValue

        return config
    }

    private func buildSettings() -> [[String: Any]] {
        var settingList = [[String: Any]]()
        settings.forEach { (_: String, value: Setting) in
            var settingDict = [String: Any]()
            settingDict["name"] = value.name
            settingDict["default"] = value.valueDefault
            settingDict["type"] = value.type.rawValue
            settingDict["maxLength"] = value.maxLength
            settingDict["isPassword"] = value.isPassword
            settingDict["minValue"] = value.minValue
            settingDict["maxValue"] = value.maxValue
            settingDict["readOnly"] = value.readOnly

            var toolTipDict = [String: Any]()
            toolTipDict["title"] = value.toolTip?.title
            toolTipDict["body"] = value.toolTip?.body
            toolTipDict["docUrl"] = value.toolTip?.docUrl

            settingDict["toolTip"] = toolTipDict
            settingList.append(settingDict)
        }
        return settingList
    }

    private func buildCategories() -> [Any] {
        // a dictionary to store actions based off of category ID
        var categoryActionSeperator = [String: [Any]]()
        actions.forEach { (_: String, action: Action) in
            let categoryId = action.category.id
            let actionBuild = buildAction(action: action)
            categoryActionSeperator[categoryId, default: []].append(actionBuild)
        }

        // a dictionary to store events based off of category ID
        var categoryEventSeperator = [String: [Any]]()
        events.forEach { (_: String, event: Event) in
            let categoryId = event.category.id
            let eventBuild = buildEvent(event: event)
            categoryEventSeperator[categoryId, default: []].append(eventBuild)
        }

        // a dictionary to store connectors based off of category ID
        var categoryConnectorSeperator = [String: [Any]]()
        connectors.forEach { (_: String, connector: Connector) in
            let categoryId = connector.category.id
            let connectorBuild = buildConnector(connector: connector)
            categoryConnectorSeperator[categoryId, default: []].append(connectorBuild)
        }

        // a dictionary to store states based off of category ID
        var categoryStateSeperator = [String: [Any]]()
        states.forEach { (_: String, state: State) in
            let categoryId = state.category.id
            let stateBuild = buildState(state: state)
            categoryStateSeperator[categoryId, default: []].append(stateBuild)
        }
        var categoryList = [Any]()
        categories.forEach { (_: String, category: Category) in
            var catDict = [String: Any]()
            catDict["id"] = category.id
            catDict["name"] = category.name
            catDict["imagePath"] = category.imagePath

            var catActions = categoryActionSeperator[category.id] ?? []
            catDict["actions"] = catActions

            var catEvents = categoryEventSeperator[category.id] ?? []
            catDict["events"] = catEvents

            var catConnectors = categoryConnectorSeperator[category.id] ?? []
            catDict["connectors"] = catConnectors

            var catStates = categoryStateSeperator[category.id] ?? []
            catDict["states"] = catStates
            categoryList.append(catDict)
        }
        return categoryList
    }

    private func buildAction(action: Action) -> [String: Any] {
        var actionDict = [String: Any]()
        actionDict["id"] = action.id
        actionDict["name"] = action.name
        actionDict["type"] = action.type.rawValue
        actionDict["executionType"] = action.executionType?.rawValue
        actionDict["execution_cmd"] = action.executionCmd
        actionDict["lines"] = buildActionLine(actionLines: action.getActionLines())
        actionDict["data"] = buildActionData(actionDatas: action.getData())
        return actionDict
    }

    private func buildActionData(actionDatas: [ActionData]) -> [[String: Any]] {
        var list = [[String: Any]]()
        actionDatas.forEach { actionData in
            var dict = [String: Any]()
            dict["id"] = actionData.id
            let result = actionData.type.getTypeAndValue()
            dict["type"] = result.type
            dict["default"] = result.defaultValue
            dict["valueChoices"] = actionData.valueChoices
            dict["extensions"] = actionData.extensions
            dict["allowDecimals"] = actionData.allowDecimal
            dict["minValue"] = actionData.minValue
            dict["maxValue"] = actionData.maxValue
            list.append(dict)
        }

        return list
    }

    private func buildActionLine(actionLines: [ActionLine]) -> [String: Any] {
        var actionArray = [Any]()
//        line["action"] =
        actionLines.forEach { actionLine in
            var actionLineDict = [String: Any]()
            actionLineDict["language"] = actionLine.language
            var lineFormatArray = [[String: String]]()
            actionLine.getData().forEach { line in
                lineFormatArray.append(["lineFormat": line])
            }
            actionLineDict["data"] = lineFormatArray
            actionLineDict["suggestions"] = actionLine.getSuggestions()
            actionArray.append(actionLineDict)
        }
        return ["action": actionArray]
    }

    private func buildEvent(event: Event) -> [String: Any] {
        var eventDict = [String: Any]()
        eventDict["id"] = event.id
        eventDict["name"] = event.name
        eventDict["format"] = event.format
        eventDict["type"] = event.type.rawValue
        eventDict["valueChoices"] = event.valueChoices
        eventDict["valueType"] = event.valueType.rawValue
        eventDict["valueStateId"] = event.valueStateId
        eventDict["subCategory"] = event.subCategory
        return eventDict
    }

    private func buildConnector(connector: Connector) -> [String: Any] {
        var connectorDict = [String: Any]()
        connectorDict["id"] = connector.id
        connectorDict["name"] = connector.name
        connectorDict["format"] = connector.format
        connectorDict["data"] = buildConnectorData(connectorDatas: connector.getDataList())
        connectorDict["subCategory"] = connector.subCategory
        return connectorDict
    }

    private func buildConnectorData(connectorDatas: [ConnectorData]) -> [[String: Any]] {
        // TODO: connectors can have moe than one data.
        var list = [[String: Any]]()
        connectorDatas.forEach { data in
            var dataDict = [String: Any]()
            dataDict["id"] = data.id
            dataDict["label"] = data.label
            dataDict["type"] = data.dataType.rawValue
            dataDict["default"] = data.defaultValue
            dataDict["valueChoice"] = data.valueChoices
            list.append(dataDict)
        }
        return list
    }

    private func buildState(state: State) -> [String: Any] {
        var stateDict = [String: Any]()
        stateDict["id"] = state.id
        stateDict["type"] = state.type.rawValue
        stateDict["desc"] = state.description
        stateDict["default"] = state.defaultValue
        stateDict["valueChoices"] = state.valueChoices
        stateDict["parentGroup"] = state.parentGroup
        return stateDict
    }
    
}

public enum ApiVersion: Int {
//    case v1 = 1
//    case v2 = 2
//    case v3 = 3
//    case v4 = 4
//    case v5 = 5
//    case v6 = 6
    case v7 = 7
}
