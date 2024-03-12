//
//  File.swift
//
//
//  Created by kyle on 3/6/24.
//

import Foundation
import LoggerSwift

public class Connector {
    private static var logger = Logger(current: Connector.self)
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
    public static func setLoggerLevel(level: String) {
            logger.setLevel(level: level)
        }

        public static func getLoggerLevel() -> String {
            return logger.getLevel()
        }
    public func addData(data: ConnectorData) {
        dataList.append(data)
    }
    public func getDataList() -> [ConnectorData] {
        return dataList
    }
    public static func updateConnectorData(connectorId: String, value: Int) {
        if (TPClient.tpClient == nil || TPClient.tpClient!.plugin == nil) {
            logger.error("Cannot send update, because tpClient is nul or plugin is nil")
            return
        }
        let message = """
        {"type":"connectorUpdate","connectorId":"pc_\(TPClient.tpClient!.plugin!.pluginId)_\(connectorId)","value":\(value)}
        """

        TPClient.currentHandler?.sendMessage(message: message + "\n")
    }
    
}


