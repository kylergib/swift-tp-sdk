//
//  File.swift
//  
//
//  Created by kyle on 3/10/24.
//

import Foundation

public class TPNotification {
    public var id: String
    public var title: String
    public var message: String
    public var options: [NotifcationOption]
    
    private var notificationClicked: ((NotificationResponse) -> Void)?
    public var onNotificationClicked: ((NotificationResponse) -> Void)? {
        get { notificationClicked }
        set(value) {
            notificationClicked = value
        }
    }
    
    public init(id: String, title: String, message: String, options: [NotifcationOption]) {
        self.id = id
        self.title = title
        self.message = message
        self.options = options
        TPNotification.createNotification(notificationId: id, title: title, message: message, options: options)
    }
    public static func createNotification(notificationId: String, title: String, message: String, options: [NotifcationOption]) {
        if options.count < 1 {
            print("atleast 1 option is required")
            return
        }
        var optionList = [[String: Any]]()
        options.forEach { option in
            var dict = [String: Any]()
            dict["id"] = option.id
            dict["title"] = option.title
            optionList.append(dict)
        }
        
        let message = """
        {"type":"showNotification","notificationId":"\(notificationId)","title":"\(title)","msg":"\(message)","options": \(optionList)}
        """
        
        TPClient.currentHandler?.sendMessage(message: message + "\n")
    }
    
    
    
}

public class NotifcationOption {
    public var id: String
    public var title: String
    
    public init(id: String, title: String) {
        self.id = id
        self.title = title
    }
}

public class NotificationResponse {
    public var type: String
    public var notificationId: String
    public var optionId: String
    
    public init(type: String, notificationId: String, optionId: String) {
        self.type = type
        self.notificationId = notificationId
        self.optionId = optionId
    }
}
