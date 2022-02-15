//
//  Message.swift
//  Chat App
//
//  Created by fahad on 26/11/2018.
//  Copyright © 2018 Fahad. All rights reserved.
//

import Foundation
import MessageKit

class Message {
    
    var id: String
    var toId: String
    var fromId: String
    var message: String
    var timeStamp: Double
    
//    var chatId: String
    
    init(id: String, toId: String, fromId: String, message: String, timeStamp: Double, chatId: String) {
        self.id = id
        self.toId = toId
        self.fromId = fromId
        self.message = message
        self.timeStamp = timeStamp
//        self.chatId = chatId
    }
    
    init(json: [String:Any]) {
        id = json["id"] as? String ?? ""
        toId = json["toId"] as! String
        fromId = json["fromId"] as! String
        message = json["message"] as! String
        timeStamp = Double("\(json["timeStamp"]!)")!
//        self.chatId = json["chatId"] as! String
    }
}


extension Message {
    
    func jsonData() -> [AnyHashable:Any] {
        return [ "id" : id,
                 "toId" : toId,
                 "fromId" : fromId,
                 "message" : message,
                 "timeStamp" : timeStamp]
    }
}


extension Message: MessageType {
    var sender: Sender {
        return Sender(id: fromId, displayName: "")
    }
    
    var messageId: String {
        return id
    }
    
    var sentDate: Date {
        return Date(timeIntervalSince1970: timeStamp)
    }
    
    var kind: MessageKind {
        return MessageKind.text(message)
    }
    
    
}
