//
//  LFGView.swift
//  LFGER
//
//  Created by Alex Hartwell on 1/16/16.
//  Copyright © 2016 SWARM. All rights reserved.
//

import Foundation
import UIKit


class LFGView: BaseView, UITextFieldDelegate, UITextViewDelegate {
    
    var systemSelect: SystemSelect?
    var LFGButton: UIButton = UIButton();
    var gameInput: UITextField = UITextField();
    var nameInput: UITextField = UITextField();
    var message: UITextView = UITextView();
    
    var shareStrip: SocialShareStrip = SocialShareStrip();
    
    var namePlaceholder: String = "Username/PSN/GamerTag";
    var gamePlaceholder: String = "Game";
    var messagePlaceholder: String = "Let people know what's what";
    
    func setUpSystems(systems: [SystemModel]) {
        
        self.backgroundColor = UIColor.whiteColor();
        self.systemSelect = SystemSelect(systems: systems);
        self.addSubview(self.systemSelect!);
        
        
        self.gameInput.text = self.gamePlaceholder;
        self.gameInput.delegate = self;
        self.nameInput.text = self.namePlaceholder;
        self.nameInput.delegate = self;
        self.gameInput.enabled = true;
        self.nameInput.enabled = true;
        self.setNeedsUpdateConstraints();
    }
    
    
    override func didLoad() {
        super.didLoad();
        
        
        self.LFGButton.setTitle("LFG", forState: .Normal);
        self.LFGButton.setTitleColor(UIColor.blackColor(), forState: .Normal);
        self.LFGButton.backgroundColor = UIColor.blueColor();
        self.LFGButton.clipsToBounds = true;
        self.LFGButton.layer.masksToBounds = true;
        self.LFGButton.addTarget(nil, action: "submitIt", forControlEvents: .TouchUpInside);
        
        
        self.message.text = self.messagePlaceholder;
        self.message.delegate = self;
        
        
        
        self.addSubview(self.gameInput);
        self.addSubview(self.nameInput);
        self.addSubview(self.message);
        self.addSubview(self.shareStrip);
        self.addSubview(self.LFGButton);
    
        
    }
    
    func getSocialSites() -> [SocialSites] {
        var returnSites: [SocialSites] = [];
        if (self.shareStrip.fbSwitch.on) {
            returnSites.append(SocialSites.Facebook);
        }
        
        if (self.shareStrip.twitterSwitch.on) {
            returnSites.append(SocialSites.Twitter);
        }
        
        return returnSites;
    }
    
    func getMessage() -> String {
        if (self.message.text == self.messagePlaceholder) {
            return "";
        } else {
            return self.message.text;
        }
    }
    
    override func layoutSubviews() {
        
        self.systemSelect?.snp_remakeConstraints(closure: {
            make in
            make.top.equalTo(self).offset(Constants.padding);
            make.left.equalTo(self).offset(Constants.padding);
            make.right.equalTo(self).offset(-Constants.padding);
            make.height.equalTo(Constants.padding * 8);
        });
        
        if let sys = self.systemSelect {
            self.gameInput.snp_remakeConstraints(closure: {
                make in
                make.top.equalTo(sys.snp_bottom).offset(Constants.padding);
                make.left.equalTo(self).offset(Constants.padding * 2);
                make.right.equalTo(self).offset(-Constants.padding * 2);
                make.height.equalTo(Constants.padding * 5);
                
            })
            
            self.nameInput.snp_remakeConstraints(closure: {
                make in
                make.top.equalTo(gameInput.snp_bottom).offset(Constants.padding * 2);
                make.left.equalTo(self).offset(Constants.padding * 2);
                make.right.equalTo(self).offset(-Constants.padding * 2);
                make.height.equalTo(Constants.padding * 5);
                
            })
            
            self.message.snp_remakeConstraints(closure: {
                make in
                make.top.equalTo(self.nameInput.snp_bottom).offset(Constants.padding * 2);
                make.left.equalTo(self).offset(Constants.padding * 2);
                make.right.equalTo(self).offset(-Constants.padding * 2);
                make.height.equalTo(Constants.padding * 18);
            })
            
            self.shareStrip.snp_remakeConstraints(closure: {
                make in
                make.top.equalTo(self.message.snp_bottom).offset(Constants.padding * 2);
                make.left.equalTo(self).offset(0);
                make.right.equalTo(self).offset(0);
                make.height.equalTo(Constants.padding * 12);
            })
            
           
            
        }

        
        self.LFGButton.snp_remakeConstraints(closure: {
            make in
            make.bottom.equalTo(self).offset(-Constants.padding * 12);
            make.centerX.equalTo(self.snp_centerX)
            make.width.equalTo(self.LFGButton.snp_height);
            make.top.equalTo(self.shareStrip.snp_bottom).offset(Constants.padding * 2);
            let item = self.LFGButton.snp_height;
            self.LFGButton.layer.cornerRadius = CGFloat(item.attributes.rawValue) / CGFloat(1.5)
        })

        
        
        super.layoutSubviews();
    }
    
    func getGame() -> String {
        if (self.gameInput.text != self.gamePlaceholder) {
            return self.gameInput.text!
        } else {
            return "";
        }
    }
    
    
    func getSystemIndex() -> Int {
        return (self.systemSelect?.selectedIndex)!;
    }
    
    func getGamerTag() -> String {
        if (self.nameInput.text != self.namePlaceholder) {
            return self.nameInput.text!
        } else {
            return "";
        }
    }
    
    
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if (textField.text == self.gamePlaceholder || textField.text == self.namePlaceholder) {
            textField.text = "";
        }
        
        
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if (textField.text == "") {
            if (textField == self.gameInput) {
                textField.text = self.gamePlaceholder;
            } else {
                textField.text = self.namePlaceholder;
            }
        }
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if (textView.text == self.messagePlaceholder) {
            textView.text = "";
        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if (textView.text.characters.count > 100) {
            return false;
        } else {
            return true;
        }
    }
  
    func textViewDidEndEditing(textView: UITextView) {
        if (textView.text == "") {
            textView.text = self.messagePlaceholder;
        }
    }
    
}
