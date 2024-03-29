//
//  Submission.swift
//  LFGER
//
//  Created by Alex Hartwell on 1/16/16.
//  Copyright © 2016 SWARM. All rights reserved.
//

import Foundation

class Comment {
    var message: String = "";
    var username: String = "";
    var id: String = "";
    var timeStamp: NSDate = NSDate();
    var lfgId: String = "";
    
    init(message: String, username: String, id: String, timeStamp: NSDate, lfgId: String) {
        self.message = message;
        self.username = username;
        self.id = id;
        self.timeStamp = timeStamp;
        self.lfgId = lfgId;
    }
    
    func removeIt() {
        SubmissionService.removeComment(self.lfgId, id: self.id, callback: {});
    }
    
}


class Submission {
    var system: SystemModel = SystemModel(type: .PC);
    var username: String = "";
    var shouldShareFB: Bool = true;
    var shouldShareTwitter: Bool = true;
    var message: String = "";
    var timeStamp: NSDate = NSDate();
    var game: String = "";
    var isYours: Bool = false;
    var id: String = "";
    var comments: [Comment] = [];
    init() {
        
        
    }
    
    init(system: SystemModel, username: String, message: String, game: String, timeStamp: NSDate, isYours: Bool, id: String, comments: [Comment]) {
        self.system = system;
        self.username = username;
        self.message = message;
        self.game = game;
        self.timeStamp = timeStamp;
        self.isYours = isYours;
        self.id = id;
        self.comments = comments;
        
        self.comments.insert(Comment(message: self.message, username: self.username, id: "", timeStamp: self.timeStamp, lfgId: self.id), atIndex: 0);
        
    }
    
    func removeIt() {
        SubmissionService.removeLFG(self.id, callback: {});
        
    }
    func getNameAndGameJoined() -> String {
        return self.username + self.message + self.game;
    }
    
    func sendToServer() {
        
    }
    
    
    
}


func randomAlphaNumericString(length: Int) -> String {
    
    let allowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    let allowedCharsCount = UInt32(allowedChars.characters.count)
    var randomString = ""
    
    for _ in (0..<length) {
        let randomNum = Int(arc4random_uniform(allowedCharsCount))
        let newCharacter = allowedChars[allowedChars.startIndex.advancedBy(randomNum)]
        randomString += String(newCharacter)
    }
    
    return randomString
}