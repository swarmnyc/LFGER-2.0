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
        "platform": submission.system.getPlatformShortName(),
        "gamerId": submission.username];
        
        request(.POST, "http://lfger-api.azurewebsites.net/lfgs", parameters: parameters, encoding: ParameterEncoding.JSON, headers: nil).responseJSON {
             response in
            if let JSON = response.result.value {
                if let dict = JSON as? NSDictionary {
                    callback(SubmissionService.JSONToSubmission(dict, isYours: true));
                }
                

            }
            
            
        };
            
    }
    
    static func getGamesPages(page: Int, callback: (([Submission]) -> ())) {
        let parameters: [String: String] = [
            "page": page.description];
        
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
    
    static func getGames(game: String, platform: String, page: Int, limit: Int, callback: (([Submission]) -> ())) {
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
        
        if (parameters == nil) {
            parameters = [String: String]();
        }
        
        if (limit == 0) {
            if (page > 0) {
                parameters!["page"] = page.description;
            }
        } else {
            parameters!["limit"] = limit.description;
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
    
    static func getPlatforms(callback: ([(String, String)] -> ())) {
        
        request(.GET, "http://lfger-api.azurewebsites.net/lfgs", parameters: nil, encoding: ParameterEncoding.URLEncodedInURL, headers: nil).responseJSON {
            response in
            print(response.request);
            if let json = response.result.value {
                print(json.count)
                if let count = json.count {
                    var platforms: [(String, String)] = [];
                    for (var i = 0; i < count; i++) {
                        let dict = json[i] as! NSDictionary;
                        platforms.append((dict["shortName"] as! String, dict["_id"] as! String));
                    }
                    
                    callback(platforms);
                }
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
    
    
    static func removeComment(lfgId: String, id: String, callback: (() -> ())) {
        print("delete URL = " + "http://lfger-api.azurewebsites.net/lfgs/" + lfgId + "/comments/" + id);
        request(.DELETE, "http://lfger-api.azurewebsites.net/lfgs/" + lfgId + "/comments/" + id).responseJSON(completionHandler: {
            response in
            print("delete comment response");
            print(response);
            
        });
        callback();
    }
    
    static func removeLFG(id: String, callback: (() -> ())) {
        
        request(.DELETE, "http://lfger-api.azurewebsites.net/lfgs/" + id);
        callback();
        
    }
    
    static func sendComment(subId: String, username: String, message: String, callback: (() -> ())) {
        
        request(.POST, "http://lfger-api.azurewebsites.net/lfgs/" + subId + "/comments", parameters: [
            "gamerId": username,
            "message": message
            ], encoding: ParameterEncoding.JSON, headers: nil).responseJSON(completionHandler: {
                response in
                print(response);
            });
        
    }
    
    
    
    static func ArrayToComments(lfgId: String, array: NSArray) -> [Comment] {
        var comments: [Comment] = [];
        for (var i = 0; i < array.count; i++) {
            if let commentJSON = array[i] as? NSDictionary {
                if let message = commentJSON["message"] as? String {
                    let timeS: String = commentJSON["createdAt"] as! String;
                    var time: NSDate = NSDate(fromString: timeS, format: DateFormat.Custom("yyyy-MM-dd'T'HH:mm:SS.SSS'Z'"));
                    let sourceDate = NSDate(timeIntervalSince1970: 3600 * 24 * 60);
                    let destinationTimeZone = NSTimeZone.localTimeZone();
                    let timeZoneOffset = Double(destinationTimeZone.secondsFromGMTForDate(sourceDate)) / 3600.0;
                    time = time.dateByAddingHours(Int(timeZoneOffset))
                    
                    comments.append(Comment(message: message, username: commentJSON["gamerId"] as! String, id: commentJSON["_id"] as! String, timeStamp: time, lfgId: lfgId));
                }
            }
        }
        
        return comments;
        
    }
    
    static func JSONToSubmission(json: NSDictionary, isYours: Bool) -> Submission {
            let username: String = json["gamerId"] as! String
            let game: String = json["game"] as! String;
            let message: String = json["message"] as! String;
            var platformShortName: String = "";
            if let platformDict = json["platform"] as? NSDictionary {
                platformShortName = platformDict["shortName"] as! String;
            }
            let timeS: String = json["createdAt"] as! String;
        
            var time: NSDate = NSDate(fromString: timeS, format: DateFormat.Custom("yyyy-MM-dd'T'HH:mm:SS.SSS'Z'"));
        
            let sourceDate = NSDate(timeIntervalSince1970: 3600 * 24 * 60);
            let destinationTimeZone = NSTimeZone.localTimeZone();
            let timeZoneOffset = Double(destinationTimeZone.secondsFromGMTForDate(sourceDate)) / 3600.0;
            time = time.dateByAddingHours(Int(timeZoneOffset))
            let system = SystemModel(shortName: platformShortName);
            let id: String = json["_id"] as! String;
        let comments: [Comment] = SubmissionService.ArrayToComments(id, array: json["comments"] as! NSArray);
            let submission = Submission(system: system, username: username, message: message, game: game, timeStamp: time, isYours: isYours, id: id, comments: comments);
            return submission;
    }
    
}