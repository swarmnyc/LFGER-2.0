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
    
    
}


