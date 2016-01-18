//
//  SERVICES.swift
//  LFGER
//
//  Created by Alex Hartwell on 1/16/16.
//  Copyright © 2016 SWARM. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON


class SubmissionService {
    
    static func submitGame(submission: Submission, callback: ((Submission) -> ())) {
        let parameters: [String: String] = [
        "game": submission.game,
        "message": submission.message,
        "platform": submission.system.getPlatformId(),
        "gamerId": submission.username];
        
        request(.POST, "http://lfger-api.azurewebsites.net/lfgs", parameters: parameters, encoding: ParameterEncoding.JSON, headers: nil).responseJSON {
             response in
            if let JSON = response.result.value {
                
                callback(submission);

            }
            
            
        };
            
    }
    
    static func getGames(game: String, platform: String, callback: (([Submission]) -> ())) {
        var parameters: [String: String]? = nil;
        if (game != "") {
            parameters = [
            "game": game
            ]
        }
        
        if (platform != "") {
            parameters = [
            "platform": platform
            ]
        }
        
        
        request(.GET, "http://lfger-api.azurewebsites.net/lfgs", parameters: parameters, encoding: ParameterEncoding.URLEncodedInURL, headers: nil).responseJSON {
            response in
            print(response.request);
            if let json = response.result.value {
                var submissions: [Submission] = [];
                print(json.count)
                if let count = json.count {
                    for (var i = 0; i < count; i++) {
                        
                        let sub = SubmissionService.JSONToSubmission(json[i] as! NSDictionary, isYours: false);
                        submissions.append(sub);
                    }
                    
                    callback(submissions);
                }
                
                
               // callback(submission);
                
            }
        }
        
        
    }
    
    static func sendEmail(email: String) {
        if (SavedData.getData("email") == email) {
            return;
        }
        
        request(.POST, "http://lfger-api.azurewebsites.net/users", parameters: ["email": email], encoding: ParameterEncoding.JSON, headers: nil).responseJSON(completionHandler: {
            response in
            
            print(response);
            
        })
        
        
    }
    
    static func removeLFG(id: String, callback: (() -> ())) {
        
        request(.DELETE, "http://lfger-api.azurewebsites.net/lfgs/" + id);
        callback();
        
    }
    
    static func JSONToSubmission(json: NSDictionary, isYours: Bool) -> Submission {
            let username: String = json["gamerId"] as! String
            let game: String = json["game"] as! String;
            let message: String = json["message"] as! String;
            let platformId: String = (json["platform"] as! NSDictionary)["_id"] as! String;
            let timeS: String = json["createdAt"] as! String;
            let time: NSDate = NSDate(fromString: timeS, format: DateFormat.Custom("yyyy-MM-DD'T'HH:mm:ss.SSS'Z'"));
            let system = SystemModel(id: platformId);
            let id: String = json["_id"] as! String;
        let submission = Submission(system: system, username: username, message: message, game: game, timeStamp: time, isYours: isYours, id: id);
        return submission;
    }
    
}