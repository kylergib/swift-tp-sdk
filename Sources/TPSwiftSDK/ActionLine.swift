//
//  File.swift
//
//
//  Created by kyle on 3/5/24.
//

import Foundation

public class ActionLine {
    public var language: String
    private var data: [String]
    private var suggestions: [String: Any]
    // TODO: API doc says optional for suggestions, but touch portal throws error if it is not included https://discord.com/channels/548426182698467339/1212257743256424458

    public init(language: String = "default", data: [String] = [], suggestions: [String: Any] = [String: Any]()) {
        self.language = language
        self.data = data
        self.suggestions = suggestions
    }

    public func addData(data: String) {
        self.data.append(data)
    }

    public func addSuggestion(key: String, value: Any) {
        suggestions[key] = value
    }

    public func getData() -> [String] {
        return data
    }

    public func getSuggestions() -> [String: Any] {
        return suggestions
    }
}
