//
//  File.swift
//
//
//  Created by kyle on 3/6/24.
//

import Foundation

public class State {
    public var id: String
    public var type: StateType
    public var description: String
    public var defaultValue: String
    public var valueChoices: [String]
    public var parentGroup: String?
    public var category: Category
    public init(id: String, type: StateType, description: String, category: Category,
                defaultValue: String = "", valueChoices: [String] = [])
    {
        self.id = id
        self.type = type
        self.category = category
        self.description = description
        self.defaultValue = defaultValue
        self.valueChoices = valueChoices
    }

    public static func updateState(stateId: String, value: String) {
        if TPClient.tpClient == nil || TPClient.tpClient!.plugin == nil {
            print("Cannot send update, because tpClient is nul or plugin is nil")
            return
        }
        let message = """
        {"type":"stateUpdate","id":"\(stateId)","value":\(value)}
        """

        TPClient.currentHandler?.sendMessage(message: message + "\n")
    }
    public static func updateStateList(stateId: String, value: [String]) {
        if TPClient.tpClient == nil || TPClient.tpClient!.plugin == nil {
            print("Cannot send update, because tpClient is nul or plugin is nil")
            return
        }
        let message = """
        {"type":"stateListUpdate","id":"\(stateId)","value":\(value)}
        """

        TPClient.currentHandler?.sendMessage(message: message + "\n")
    }
    public static func updateChoiceList(choiceListId: String, value: [String]) {
        if TPClient.tpClient == nil || TPClient.tpClient!.plugin == nil {
            print("Cannot send update, because tpClient is nul or plugin is nil")
            return
        }
        let message = """
        {"type":"choiceUpdate","id":"\(choiceListId)","value":\(value)}
        """

        TPClient.currentHandler?.sendMessage(message: message + "\n")
    }
}

public enum StateType: String {
    case choice
    case text
}
