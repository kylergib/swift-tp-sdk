//
//  File.swift
//
//
//  Created by kyle on 3/10/24.
//

import Foundation

enum Util {
    static func dictToJsonString(dict: [String: Any]) -> String? {
        do {
            // Convert the dictionary into JSON data
            let jsonData = try JSONSerialization.data(withJSONObject: dict)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }

        } catch {
            print(error)
        }
        return nil
    }
}
