//
//  SavedData.swift
//  LFGERREAL
//
//  Created by Alex Hartwell on 1/18/16.
//  Copyright © 2016 SWARM. All rights reserved.
//

import Foundation


class SavedData {
    
    static var data: NSUserDefaults = NSUserDefaults.standardUserDefaults();
    
    static func saveData(key: String, value: String) {
        SavedData.data.setValue(value, forKey: key);
    }
    
    static func getData(key: String) -> String? {
        return SavedData.data.stringForKey(key);
    }
    
    
    
    
}