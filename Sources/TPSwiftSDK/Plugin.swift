//
//  File.swift
//
//
//  Created by kyle on 3/5/24.
//

import Foundation

class Plugin {
    // LEFT OFF ON ENTRY
    var api: ApiVersion

    var version: Int
    var name: String
    var pluginId: String
    var configuration: Configuration?
    var pluginStartCommand: String?
    var pluginStartCmdWindows: String?
    var pluginStartCmdMac: String?
    var pluginStartCmdLinux: String?
    private var categories = [String: Category]()
    private var settings = [String: Setting]()

//    var actionCategories = [String: Category]()
    private var actions = [String: Action]() // TODO: replace with action class
//    var eventCategories = [String: Category]()
    private var events = [String: Event]() // TODO: replace with events class
//    var connectorCategories = [String: Category]()
    private var connectors = [String: Connector]() // TODO: replace with connector class
//    var stateCategories = [String: Category]()
    private var states = [String: State]() // TODO: replace with state class
    var subCategories: [String: Category]? // TODO: would this be an array of catogories? maybe child class of category

    init(api: ApiVersion, version: Int, name: String, pluginId: String) {
        self.api = api
        self.version = version
        self.name = name
        self.pluginId = pluginId
    }

    func addCategory(category: Category) {
        categories[category.id] = category
    }

    func addSetting(setting: Setting) {
        settings[setting.name] = setting
    }

    func addAction(action: Action) {
        actions[action.id] = action
    }

    func addEvent(event: Event) {
        events[event.id] = event
    }

    func addConnector(connector: Connector) {
        connectors[connector.id] = connector
    }

    func addState(state: State) {
        states[state.id] = state
    }
    func getActionById(actionId: String) -> Action? {
        return actions[actionId]
    }

    // TODO: add getters to get items from key/id
    func buildEntry() {
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

            // Specify the file path and name
            let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("entry.tp")

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
        connectorDict["data"] = [buildConnectorData(data: connector.data)]
        connectorDict["subCategory"] = connector.subCategory
        return connectorDict
    }

    private func buildConnectorData(data: ConnectorData) -> [String: Any] {
        // TODO: connectors can have moe than one data.
        var dataDict = [String: Any]()
        dataDict["id"] = data.id
        dataDict["label"] = data.label
        dataDict["type"] = data.dataType.rawValue
        dataDict["default"] = data.defaultValue
        dataDict["valueChoice"] = data.valueChoices
        return dataDict
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

enum ApiVersion: Int {
//    case v1 = 1
//    case v2 = 2
//    case v3 = 3
//    case v4 = 4
//    case v5 = 5
//    case v6 = 6
    case v7 = 7
}
