//
//  Chat.swift
//  ChattyChatters
//
//  Created by Basheer Abdulmalik on 19/06/2023.
//

import Foundation

struct Chat {
    var userID: String
    var nickname: String
    var lastMessage: String
    var newMessagesCount: Int
    var time: String
    
    init(with userID: String, nickname: String, lastMessage: String, newMessagesCount: Int, time: String) {
        self.userID = userID
        self.nickname = nickname
        self.lastMessage = lastMessage
        self.newMessagesCount = newMessagesCount
        self.time = time
    }
}
