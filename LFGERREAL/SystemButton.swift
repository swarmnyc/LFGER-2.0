//
//  SystemButton.swift
//  LFGER
//
//  Created by Alex Hartwell on 1/16/16.
//  Copyright © 2016 SWARM. All rights reserved.
//

import Foundation
import UIKit

class SystemButton: UIButton {
    var index: Int = 0;
    
    
    func selectButton() {
        self.backgroundColor = UIColor.whiteColor();
        
    }
    
    
    func deselectButton() {
        self.backgroundColor = UIColor.grayColor();
        
    }
    
}