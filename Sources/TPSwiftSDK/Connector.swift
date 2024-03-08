//
//  File.swift
//
//
//  Created by kyle on 3/6/24.
//

import Foundation

public class Connector {
    public var id: String
    public var name: String
    public var format: String
    public var category: Category
    public var data: ConnectorData
    public var subCategory: Category?
    
    private var runAction: ((ActionResponse) -> Void)?
        var onAction: ((ActionResponse) -> Void)? {
            get { runAction }
            set(value) {
                runAction = value
            }
        }
    
    public init(id: String, name: String, format: String,
         category: Category, data: ConnectorData) {
        self.id = id
        self.name = name
        self.format = format
        self.category = category
        self.data = data
    }
}


