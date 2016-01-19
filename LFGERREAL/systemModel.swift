//
//  MODELS.swift
//  LFGER
//
//  Created by Alex Hartwell on 1/16/16.
//  Copyright © 2016 SWARM. All rights reserved.
//

import Foundation


enum System {
    case PC
    case PS4
    case XBOXONE
}

class SystemModel {
    var type: System = .PC
    var title: String = "";
    
    init(type: System) {
        self.type = type;
        self.title = self.getTitleText();
        
    }
    
    init (shortName: String) {
        self.type = self.getTypeFromShortName(shortName);
        self.title = self.getTitleText();

    }
    
    
    init(id: String) {
        self.type = self.getTypeFromId(id);
        self.title = self.getTitleText();
        
        
    }
    
    func getTitleText() -> String {
        switch(self.type) {
        case .PC:
            return "PC";
        case .PS4:
            return "PS4"
        case .XBOXONE:
            return "XBOX 1";
        }
        
    }
    
    func getTypeFromId(id: String) -> System {
        switch(id) {
        case "569c00279f9e981c18f77573":
            return .PC;
        case "569c00279f9e981c18f77574":
            return .PS4
        case "569c00279f9e981c18f77575":
            return .XBOXONE;
        default:
            return .PC
        }
        
    }
    
    func getTypeFromShortName(shortname: String) -> System {
        switch(shortname) {
        case "PC":
            return .PC;
        case "PS4":
            return .PS4
        case "XB1":
            return .XBOXONE;
        default:
            return .PC
        }
        
    }
    
    func getPlatformShortName() -> String {
        switch(self.type) {
        case .PC:
            return "PC";
        case .PS4:
            return "PS4";
        case .XBOXONE:
            return "XB1";
        }
        
        
    }
    
    func getProfileLink(name: String) -> String {
    switch(self.type) {
    case .PC:
        return "https://steamcommunity.com/search/?text=" + name + "&x=0&y=0";
    case .PS4:
        return "http://psnprofiles.com/" + name;
    case .XBOXONE:
        return "http://live.xbox.com/Profile?Gamertag=" + name;
    }
    
    
    
    }
    
    func getPlatformId() -> String {
        switch(self.type) {
        case .PC:
            return "569c00279f9e981c18f77573";
        case .PS4:
            return "569c00279f9e981c18f77574"
        case .XBOXONE:
            return "569c00279f9e981c18f77575";
        }
    }
    
    
}


