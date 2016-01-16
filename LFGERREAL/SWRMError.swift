//
//  SWRMError.swift
//  LFGERREAL
//
//  Created by Alex Hartwell on 1/16/16.
//  Copyright © 2016 SWARM. All rights reserved.
//

import Foundation
import UIKit


class SWRMErrorSimple: NSObject, UIAlertViewDelegate {
    var alert = UIAlertController()
    var messageText:String?
    var flaggedUser:String?
    var lobbyID: String?
    
    var inputCompletion: ((String) -> Void)?
    var hitOk: ((String) -> ())?
    
    init(alertTitle: String, alertText: String) {
        super.init();
        let rootVC = UIApplication.sharedApplication().keyWindow!.rootViewController
        alert.title = alertTitle
        alert.message = alertText
        
        alert.addAction(UIAlertAction(title: "Got It", style: UIAlertActionStyle.Default, handler: {
            action in
            rootVC?.dismissViewControllerAnimated(true, completion: nil);
            return
        }));
        rootVC?.presentViewController(alert, animated: true, completion: nil);
        
    }
    
    
    
    init(alertTitle: String, alertText: String, networkRequest: Bool) {
        super.init();
        
        let rootVC = UIApplication.sharedApplication().keyWindow!.rootViewController
        
        alert.title = alertTitle
        alert.message = alertText
        alert.addAction(UIAlertAction(title: "Got It", style: UIAlertActionStyle.Default, handler: {
            action in
            rootVC?.dismissViewControllerAnimated(true, completion: nil);
            return
        }));
        rootVC?.presentViewController(alert, animated: true, completion: nil);
        
        
    }
    
    init(alertTitle: String, alertText: String, alertStyle: UIAlertViewStyle) {
        super.init();
        let rootVC = UIApplication.sharedApplication().keyWindow!.rootViewController
        alert = UIAlertController(title: alertTitle, message: alertText, preferredStyle: UIAlertControllerStyle.Alert);
        
        
        alert.addTextFieldWithConfigurationHandler({
            textField in
            
            
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: {
            action in
            rootVC?.dismissViewControllerAnimated(true, completion: nil);
            return
        }));
        
        alert.addAction(UIAlertAction(title: "Submit", style: UIAlertActionStyle.Default, handler: {
            action in
            rootVC?.dismissViewControllerAnimated(true, completion: nil);
            var name = self.alert.textFields![0].text
            self.inputCompletion?(name!);
            
            return
        }));
        
    }
    
    func showIt(message: String, user: String) {
        let rootVC = UIApplication.sharedApplication().keyWindow!.rootViewController
        
        rootVC?.presentViewController(alert, animated: true, completion: nil);
        
        
    }
    
    
    
}