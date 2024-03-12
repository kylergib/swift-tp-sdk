//
//  File.swift
//
//
//  Created by kyle on 3/5/24.
//

import Foundation

public class ToolTip {
    public var title: String?
    public var body: String
    public var docUrl: String?

    public init(body: String, title: String? = nil, docUrl: String? = nil) {
        self.body = body
        self.title = title
        self.docUrl = docUrl
    }
}
