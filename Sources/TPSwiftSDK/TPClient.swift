//
//  TPClient.swift
//  TouchPortalSwiftSDK
//
//  Created by kyle on 3/4/24.
//
// import Compression
import Foundation
import LoggerSwift
import NIOCore
import NIOPosix
// import SwiftUI

public class TPClient {
    private static var logger = Logger(current: TPClient.self)
    private var channel: Channel?
    static var currentHandler: MessageHandler?
    static var tpClient: TPClient?
    public var address: String
    public var port: Int
    public var plugin: Plugin?

    private var messageReceived: (([String: Any]) -> Void)?
    private var connected: ((Bool) -> Void)?
    public var onConnection: ((Bool) -> Void)? {
        get { connected }
        set(value) {
            connected = value
            TPClient.currentHandler?.connectedCallback = value
        }
    }

    private var info: ((Info) -> Void)?
    public var onInfo: ((Info) -> Void)? {
        get { info }
        set(value) {
            info = value
        }
    }

    private var closeRequest: (() -> Void)?
    public var onCloseRequest: (() -> Void)? {
        get { closeRequest }
        set(value) {
            closeRequest = value
        }
    }

    private var timeout: (() -> Void)?
    public var onTimeout: (() -> Void)? {
        get { timeout }
        set(value) {
            timeout = value
        }
    }

    public init(address: String = "127.0.0.1", port: Int = 12136) {
        TPClient.currentHandler = MessageHandler()
        self.address = address
        self.port = port
        messageReceived = { json in
            TPClient.logger.debug("Received message")
            if let type = json["type"] as? String {
                TPClient.logger.debug("message has type")
                switch type {
                case "info":
                    if let settings = json["settings"] as? [[String: Any]] {
                        self.handleSettings(settings: settings)
                    }
                    if let sdkVersion = json["sdkVersion"] as? Int,
                       let tpVersionString = json["tpVersionString"] as? String,
                       let tpVersionCode = json["tpVersionCode"] as? Int,
                       let pluginVersion = json["pluginVersion"] as? Int,
                       let status = json["status"] as? String
                    {
                        self.onInfo?(Info(sdkVersion: sdkVersion, tpVersionString: tpVersionString, tpVersionCode: tpVersionCode, pluginVersion: pluginVersion, status: status))
                    }
                case "setting":
                    TPClient.logger.debug("getting settings")
                    if let settings = json["values"] as? [[String: Any]] {
                        self.handleSettings(settings: settings)
                    }
                case "action", "down", "up":
                    TPClient.logger.debug("received action")
                    let actionId = json["actionId"] as? String
                    let type = json["type"] as? String
                    let data = json["data"] as? [[String: Any]]
                    let pluginId = json["pluginId"] as? String
                    let value = json["value"]
                    if actionId == nil {
                        return
                    }
                    var dataList: [ResponseData] = []
                    data?.forEach { temp in
                        let id = temp["id"] as? String
                        let value = temp["value"]
                        dataList.append(ResponseData(id: id, value: value))
                    }
                    let action = self.plugin?.getActionById(actionId: actionId!)
                    let response = Response(type: type, pluginId: pluginId, id: actionId, data: dataList, value: value)
                    if type == "action" { action?.onAction?(response) }
                    else if type == "up" { action?.onUpAction?(response) }
                    else if type == "down" { action?.onDownAction?(response) }
                case "closePlugin":
                    TPClient.logger.debug("Received close request")
                    self.onCloseRequest?()
                case "connectorChange":
                    TPClient.logger.debug("received connector change")
                    let connectorId = json["connectorId"] as? String
                    let type = json["type"] as? String
                    let data = json["data"] as? [[String: Any]]
                    let pluginId = json["pluginId"] as? String
                    let value = json["value"]

                    if connectorId == nil {
                        return
                    }
                    var dataList: [ResponseData] = []
                    data?.forEach { temp in
                        let id = temp["id"] as? String
                        let value = temp["value"]
                        dataList.append(ResponseData(id: id, value: value))
                    }
                    let connector = self.plugin?.getConnectorById(connectorId: connectorId!)
                    connector?.onConnectorChange?(Response(type: type, pluginId: pluginId, id: connectorId, data: dataList, value: value))
                case "listChange":
                    TPClient.logger.debug("received list change")
                    let instanceId = json["instanceId"] as? String
                    let type = json["type"] as? String
                    let values = json["values"] as? [[String: Any]]
                    let pluginId = json["pluginId"] as? String
                    let value = json["value"]
                    let actionId = json["actionId"] as? String
                    let listId = json["listId"] as? String
                    var dataList: [ResponseData] = []
                    values?.forEach { temp in
                        let id = temp["id"] as? String
                        let value = temp["value"]
                        dataList.append(ResponseData(id: id, value: value))
                    }
                    let action = self.plugin?.getActionById(actionId: actionId!)
                    action?.onListChange?(ListChangeResponse(instanceId: instanceId!, pluginId: pluginId!, value: value, values: dataList, type: type!, actionId: actionId!, listId: listId!))
                case "notificationOptionClicked":
                    TPClient.logger.debug("received notification click")
                    let notificationId = json["notificationId"] as? String
                    let type = json["type"] as? String
                    let optionId = json["optionId"] as? String
                    if notificationId == nil {
                        return
                    }
                    let notification = self.plugin?.getNotificationById(notificationId: notificationId!)
                    notification?.onNotificationClicked?(NotificationResponse(type: type!, notificationId: notificationId!, optionId: optionId!))
                case "broadcast":
                    let event = json["event"] as? String
                    let type = json["type"] as? String
                    let pageName = json["pageName"] as? String
                    let previousPageName = json["previousPageName"] as? String
                    let deviceIp = json["deviceIp"] as? String
                    let deviceName = json["deviceName"] as? String
                    if event == nil || type == nil { return }
                    let response = PageResponse(type: type!, event: event!, pageName: pageName, previousPageName: previousPageName, deviceIp: deviceIp, deviceName: deviceName)
                    self.plugin?.onPageChange?(response)
                default:
                    TPClient.logger.warning("Could not find match")
                    TPClient.logger.warning("\(json)")
                }
            } else {
                TPClient.logger.error("does not have type")
                TPClient.logger.error("\(json)")
            }
        }
        TPClient.currentHandler?.messageReceivedCallback = messageReceived
        TPClient.tpClient = self
    }

    func handleSettings(settings: [[String: Any]]) {
        var settingList: [SettingResponse] = []
        settings.forEach { setting in
            setting.forEach { (name: String, value: Any) in
                let response = SettingResponse(name: name, value: value)
                settingList.append(response)
                TPClient.tpClient?.plugin?.settings[name]?.onSettingChange?(response)
            }
        }
        TPClient.tpClient?.plugin?.onSettingsChange?(settingList)
    }

    public func start() {
        if plugin == nil {
            TPClient.logger.error("Cannot connect to Touch Portal without an Plugin class")
            return
        }
        TPClient.currentHandler?.pluginId = plugin?.pluginId
        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        let bootstrap = ClientBootstrap(group: group)
            .channelOption(ChannelOptions.socketOption(.tcp_nodelay), value: 1) // disables algo where it will try to send immediately rather than split into chunks, may still split into chunks, will need to test
            .channelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
            .channelInitializer { channel in
                if TPClient.currentHandler == nil {
                    TPClient.currentHandler = MessageHandler()
                    TPClient.currentHandler?.pluginId = self.plugin?.pluginId
                    TPClient.currentHandler?.messageReceivedCallback = self.messageReceived
                }
                return channel.pipeline.addHandler(TPClient.currentHandler!)
            }

        defer {
            try? group.syncShutdownGracefully()
        }

        do {
            TPClient.logger.debug("Trying to connect")
            channel = try bootstrap.connect(host: address, port: port).wait()
            try channel!.closeFuture.wait()
        } catch {
            TPClient.logger.error("Error: \(error)")
            timeout?()
        }
    }

    public static func setLoggerLevel(level: String) {
        logger.setLevel(level: level)
    }

    public static func getLoggerLevel() -> String {
        return logger.getLevel()
    }

//    public func actionReceived() {}
//    public func buildEntry() {}
}

class MessageHandler: ChannelInboundHandler {
    private static var logger = Logger(current: MessageHandler.self)
    typealias InboundIn = ByteBuffer
    typealias OutboundOut = ByteBuffer
    public var channel: Channel?
    public var pluginId: String?

    public var messageReceivedCallback: (([String: Any]) -> Void)?
    public var connectedCallback: ((Bool) -> Void)?

    public func channelInactive(context: ChannelHandlerContext) {
        if context.remoteAddress != nil {
            MessageHandler.logger.info("Disconnected from \(context.remoteAddress!)")
        }
        TPClient.tpClient?.onConnection?(false)
    }

    public func channelActive(context: ChannelHandlerContext) {
        if context.remoteAddress != nil {
            MessageHandler.logger.info("Connected to \(context.remoteAddress!)")
        }
        channel = context.channel
//        connectedCallback?(true)
        print("sending message")
        if pluginId == nil { MessageHandler.logger.error("Cannot pair to TP because pluginId is nil") }
        let pair = """
        {"type":"pair","id":"\(pluginId!)"}
        """

        sendMessage(message: pair + "\n")
        TPClient.tpClient?.onConnection?(true)
    }

    public func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let buffer = unwrapInboundIn(data)
        if let receivedString = buffer.getString(at: 0, length: buffer.readableBytes) {
            guard let jsonData = receivedString.data(using: .utf8) else {
                MessageHandler.logger.error("Error: Cannot convert string to Data")
                return
            }
            MessageHandler.logger.finer("\(jsonData)")
            do {
                if let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                    messageReceivedCallback?(jsonObject)
                }
            } catch {
                MessageHandler.logger.error("Error: \(error.localizedDescription)")
            }
        }
    }

    public func sendMessage(message: String) {
//        if channelHandlerContext == nil { return }
        if channel == nil { return }
        MessageHandler.logger.debug("Trying to send message: \(message)")
        if let myData = message.data(using: .utf8) {
            var buffer = channel!.allocator.buffer(capacity: myData.count)
            buffer.writeBytes(myData)
            channel!.writeAndFlush(buffer, promise: nil)
            MessageHandler.logger.debug("Message sent")
        }
    }

    public func errorCaught(context: ChannelHandlerContext, error: Error) {
        MessageHandler.logger.error("\(error)")
        context.close(promise: nil)
    }

    public static func setLoggerLevel(level: String) {
        logger.setLevel(level: level)
    }

    public static func getLoggerLevel() -> String {
        return logger.getLevel()
    }
}
