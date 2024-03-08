//
//  File.swift
//
//
//  Created by kyle on 3/5/24.
//

import Foundation

class Action {
    var id: String
    var name: String
    // name languages?
    var type: ActionType
    var category: Category
    var executionType: ExecutionType? // mac only, only AppleScript or Bash allowed
    var executionCmd: String? // path of execution
    // If you use %TP_PLUGIN_FOLDER% in the text above, it will be replaced with the path to the base plugin folder.
    private var dataList: [ActionData] = [] // TODO: finish
    private var actionLines: [ActionLine] = [] // TODO: line object
    var subCategoryId: String?

    private var runAction: ((ActionResponse) -> Void)?
    var onAction: ((ActionResponse) -> Void)? {
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
    func addData(data: ActionData) {
        dataList.append(data)
    }
    func addActionLine(actionLine: ActionLine) {
        actionLines.append(actionLine)
    }
    func getActionLines() -> [ActionLine] {
        return actionLines
    }
    func getData() -> [ActionData] {
        return dataList
    }
}

enum ActionType: String {
    case execute // static
    case communicate // dynamic
}

enum ExecutionType: String {
    case AppleScript
    case Bash
}

