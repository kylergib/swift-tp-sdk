//
//  TPClient.swift
//  TouchPortalSwiftSDK
//
//  Created by kyle on 3/4/24.
//
// import Compression
import Foundation
import NIOCore
import NIOPosix
// import SwiftUI

public class TPClient {
    private var channel: Channel?
    static var currentHandler: MessageHandler?
    static var tpClient: TPClient?
    public var address: String
    public var port: Int
    public var plugin: Plugin?

    private var messageReceived: (([String: Any]) -> Void)?
    // TODO: add callback if it was unsuccessful connecting to TP and try again
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

//    init() {
//        currentHandler = MessageHandler()
//        address = "127.0.0.1" // default is local host, but in touch portal 4 you can go from a separate computer
//        port = 12136
//        messageReceived = { json in
//            var foundElement = false
//            print("message recieved: ")
//            print(json)
//            if let setting = json["settings"] as? [Any] {
//                self.onSettingsChange?(setting)
//                foundElement = true
//            }
//            if (!foundElement) {
//                print(json)
//            }
//        }
//        currentHandler?.messageReceivedCallback = messageReceived
//    }

    public init(address: String = "127.0.0.1", port: Int = 12136) {
        TPClient.currentHandler = MessageHandler()
        self.address = address
        self.port = port
        messageReceived = { json in
            if let type = json["type"] as? String {
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
                    print("getting settings")
                    if let settings = json["values"] as? [[String: Any]] {
                        self.handleSettings(settings: settings)
                    }
                case "action", "down", "up":
                    print("received action")
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
                    self.onCloseRequest?()
                case "connectorChange":
                    print("received connector change")
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
                    print("received list change")
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
                    print("received notification click")
                    let notificationId = json["notificationId"] as? String
                    let type = json["type"] as? String
                    let optionId = json["optionId"] as? String
                    if notificationId == nil {
                        return
                    }
                    let notification = self.plugin?.getNotificationById(notificationId: notificationId!)
                    notification?.onNotificationClicked?(NotificationResponse(type: type!, notificationId: notificationId!, optionId: optionId!))
                default:
                    print("Could not find match")
                    print(json)
                }
            } else {
                print("does not have type")
                print(json)
            }
        }
        TPClient.currentHandler?.messageReceivedCallback = messageReceived
        TPClient.tpClient = self
    }

    func handleSettings(settings: [[String: Any]]) {
        var settingList: [SettingResponse] = []
        settings.forEach { setting in
            setting.forEach { (name: String, value: Any) in
                settingList.append(SettingResponse(name: name, value: value))
            }
        }
        TPClient.tpClient?.plugin?.onSettingsChange?(settingList)
    }

    public func start() {
        if plugin == nil {
            print("Cannot connect to Touch Portal without an Entry class")
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
            channel = try bootstrap.connect(host: address, port: port).wait()
            try channel!.closeFuture.wait()
        } catch {
            print("Error: \(error)")
            timeout?()
        }
    }

//    public func actionReceived() {}
//    public func buildEntry() {}
}

class MessageHandler: ChannelInboundHandler {
    typealias InboundIn = ByteBuffer
    typealias OutboundOut = ByteBuffer
    public var channel: Channel?
    public var pluginId: String?

    public var messageReceivedCallback: (([String: Any]) -> Void)?
    public var connectedCallback: ((Bool) -> Void)?

    public func channelInactive(context: ChannelHandlerContext) {
        print("Disconnected from \(String(describing: context.remoteAddress))")
//        connectedCallback?(false)
        TPClient.tpClient?.onConnection?(false)
    }

    public func channelActive(context: ChannelHandlerContext) {
        print("connected to \(String(describing: context.remoteAddress))")
        channel = context.channel
//        connectedCallback?(true)
        print("sending message")
        if pluginId == nil { print("Cannot pair to TP because pluginId is nil") }
        var pair = """
        {"type":"pair","id":"\(pluginId!)"}
        """

        sendMessage(message: pair + "\n")
        TPClient.tpClient?.onConnection?(true)
    }

    public func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let buffer = unwrapInboundIn(data)
        if let receivedString = buffer.getString(at: 0, length: buffer.readableBytes) {
            guard let jsonData = receivedString.data(using: .utf8) else {
                print("Error: Cannot convert string to Data")
                return
            }
            print(jsonData)
            do {
                if let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                    messageReceivedCallback?(jsonObject)
                }
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }
    }

    public func sendMessage(message: String) {
//        if channelHandlerContext == nil { return }
        if channel == nil { return }
        print("past nil")
        if let myData = message.data(using: .utf8) {
            print("after mydata")
            var buffer = channel!.allocator.buffer(capacity: myData.count)
            buffer.writeBytes(myData)
            channel!.writeAndFlush(buffer, promise: nil)
            print("after send")
        }
    }

    public func errorCaught(context: ChannelHandlerContext, error: Error) {
        print("\(error)")
        context.close(promise: nil)
    }
}
