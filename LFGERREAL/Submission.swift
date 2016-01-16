//
//  Submission.swift
//  LFGER
//
//  Created by Alex Hartwell on 1/16/16.
//  Copyright © 2016 SWARM. All rights reserved.
//

import Foundation

class Submission {
    
    var system: SystemModel = SystemModel(type: .PC);
    var username: String = "";
    var shouldShareFB: Bool = true;
    var shouldShareTwitter: Bool = true;
    var message: String = "";
    var timeStamp: NSDate = NSDate();
    var game: String = "";
    var isYours: Bool = false;
    var removeCallback: ((Submission) -> ())?
    var id: String = "";
    init() {
        
        
    }
    
    init(system: SystemModel, username: String, message: String, game: String, timeStamp: NSDate, isYours: Bool, removeCallback: ((Submission) -> ())) {
        self.system = system;
        self.username = username;
        self.message = message;
        self.game = game;
        self.timeStamp = timeStamp;
        self.isYours = isYours;
        self.id = randomAlphaNumericString(10);
        self.removeCallback = removeCallback;
    }
    
    func removeIt() {
        //call up to server and remove this
        self.removeCallback?(self);
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