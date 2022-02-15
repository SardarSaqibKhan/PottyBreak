//
//  Chat.swift
//  Chat App
//
//  Created by fahad on 26/11/2018.
//  Copyright © 2018 Fahad. All rights reserved.
//

import Foundation

class Chat {
    
    var id: String
    var user1Id: String
    var user2Id: String
    var lastMessage: String
    var timeStamp: Double
    
    var timeString: String {
        let date = Date(timeIntervalSince1970: timeStamp)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        formatter.locale = Locale.current
        return formatter.string(from: date)
    }
    
    init(id: String, user1Id: String, user2Id: String, lastMessageId: String, timeStamp: Double) {
        self.id = id
        self.user1Id = user1Id
        self.user2Id = user2Id
        self.lastMessage = lastMessageId
        self.timeStamp = timeStamp
    }
    
    init(json: [String:Any]) {
        id = json["id"] as? String ?? ""
        user1Id = json["user1Id"] as! String
        user2Id = json["user2Id"] as! String
        lastMessage = json["lastMessageId"] as! String
        timeStamp = Double("\(json["timeStamp"]!)")!
    }
}


extension Chat {
    
    func jsonData() -> [AnyHashable:Any] {
        return [ "user1Id" : user1Id,
                 "user2Id" : user2Id,
                 "lastMessageId" : lastMessage,
                 "timeStamp" : timeStamp]
    }
    
    func partnerId(forUserId id: String) -> String {
        return user1Id == id ? user2Id : user1Id
    }
}
