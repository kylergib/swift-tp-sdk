//
//  File.swift
//
//
//  Created by kyle on 3/5/24.
//

import Foundation

public class Action {
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

    private var runAction: ((ActionResponse) -> Void)?
    public var onAction: ((ActionResponse) -> Void)? {
        get { runAction }
        set(value) {
            runAction = value
        }
    }

    init(id: String, name: String, type: ActionType, category: Category, executionType: ExecutionType? = nil, executionCmd: String? = nil) {
        self.id = id
        self.name = name
        self.type = type
        self.category = category
        self.executionType = executionType
        self.executionCmd = executionCmd
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
}

public enum ActionType: String {
    case execute // static
    case communicate // dynamic
}

public enum ExecutionType: String {
    case AppleScript
    case Bash
}

