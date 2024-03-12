//
//  File.swift
//
//
//  Created by kyle on 3/5/24.
//

import Foundation
import LoggerSwift

public class Action {
    private static var logger = Logger(current: Action.self)
    public var id: String
    public var name: String
    // name languages?
    public var type: ActionType
    public var category: Category
    public var executionType: ExecutionType? // mac only, only AppleScript or Bash allowed
    public var executionCmd: String? // path of execution
    // If you use %TP_PLUGIN_FOLDER% in the text above, it will be replaced with the path to the base plugin folder.
    private var dataList: [ActionData] = [] // TODO: finish
    private var actionLines: [ActionLine] = [] // TODO: line object
    public var subCategoryId: String?
    public var hasHoldFunctionality: Bool = false

    private var runAction: ((Response) -> Void)?
    public var onAction: ((Response) -> Void)? {
        get { runAction }
        set(value) {
            runAction = value
        }
    }

    private var upAction: ((Response) -> Void)?
    public var onUpAction: ((Response) -> Void)? {
        get { upAction }
        set(value) {
            upAction = value
        }
    }

    private var downAction: ((Response) -> Void)?
    public var onDownAction: ((Response) -> Void)? {
        get { downAction }
        set(value) {
            downAction = value
        }
    }

    private var listChange: ((ListChangeResponse) -> Void)?
    public var onListChange: ((ListChangeResponse) -> Void)? {
        get { listChange }
        set(value) {
            listChange = value
        }
    }

    public init(id: String, name: String, type: ActionType, category: Category, executionType: ExecutionType? = nil, executionCmd: String? = nil) {
        self.id = id
        self.name = name
        self.type = type
        self.category = category
        self.executionType = executionType
        self.executionCmd = executionCmd
    }

    public static func setLoggerLevel(level: String) {
        logger.setLevel(level: level)
    }

    public static func getLoggerLevel() -> String {
        return logger.getLevel()
    }

    public func addData(data: ActionData) {
        dataList.append(data)
    }

    public func addActionLine(actionLine: ActionLine) {
        actionLines.append(actionLine)
    }

    public func getActionLines() -> [ActionLine] {
        return actionLines
    }

    public func getData() -> [ActionData] {
        return dataList
    }

    public static func updateActionList(actionDataId: String, value: [String], actionId: String) {
        if TPClient.tpClient == nil || TPClient.tpClient!.plugin == nil {
            logger.error("Cannot send update, because tpClient is nul or plugin is nil")
            return
        }
        var dict = [String: Any]()
        dict["type"] = "choiceUpdate"
        dict["id"] = actionDataId
        dict["instanceId"] = actionId
        dict["value"] = value

        if let jsonString = Util.dictToJsonString(dict: dict) {
            TPClient.currentHandler?.sendMessage(message: jsonString + "\n")
        }
    }
}

public enum ActionType: String {
    case execute // static
    case communicate // dynamic
}

public enum ExecutionType: String {
    case AppleScript
    case Bash
}
