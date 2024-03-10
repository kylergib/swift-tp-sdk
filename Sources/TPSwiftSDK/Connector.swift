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
    private var dataList: [ConnectorData]
    public var subCategory: Category?
    private var connectorChange: ((Response) -> Void)?
    public var onConnectorChange: ((Response) -> Void)? {
        get { connectorChange }
        set(value) {
            connectorChange = value
        }
    }
    
    public init(id: String, name: String, format: String,
         category: Category, dataList: [ConnectorData] = []) {
        self.id = id
        self.name = name
        self.format = format
        self.category = category
        self.dataList = dataList
    }
    public func addData(data: ConnectorData) {
        dataList.append(data)
    }
    public func getDataList() -> [ConnectorData] {
        return dataList
    }
    public func updateConnectorData(value: Any) {
        
    }
}


