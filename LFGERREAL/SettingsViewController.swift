//
//  SettingsViewController.swift
//  LFGERREAL
//
//  Created by Alex Hartwell on 1/16/16.
//  Copyright © 2016 SWARM. All rights reserved.
//

import Foundation
import UIKit



class SettingsView: BaseView, UIGestureRecognizerDelegate {
    
    var aboutView: UITextView = UITextView();
    var emailLabel: UILabel = UILabel();
    var emailInput: UITextField = UITextField();
    var TOSLink: UITextView = UITextView();
    
    
    override func didLoad() {
        
        self.backgroundColor = UIColor.whiteColor();
        
        self.addSubview(self.aboutView);
        self.addSubview(self.emailLabel);
        self.addSubview(self.emailInput);
        self.addSubview(self.TOSLink);
        
        
        self.aboutView.editable = false;
        self.aboutView.text = "Drop us your email and we may send you free games through Stream, and on occasion send out mega import announcements.";
        let tosString = "tos + privacy policy";
        
        let tos: NSMutableAttributedString = NSMutableAttributedString(string: "tos + privacy policy");
        tos.addAttribute(NSLinkAttributeName, value: "http://lfger.com/tos.html", range: NSRange(location: 0, length: tosString.characters.count));
     
        TOSLink.attributedText = tos;
        TOSLink.textColor = UIColor.blackColor();
        self.TOSLink.editable = false;
        
        self.emailLabel.text = "email: "
        self.emailLabel.textColor = UIColor.blackColor();
        
        let tap = UITapGestureRecognizer();
        tap.delegate = self;
        self.addGestureRecognizer(tap);
        
        
        
    }
    
    
    override func updateConstraints() {
        
        self.aboutView.snp_remakeConstraints(closure: {
            make in
            make.top.equalTo(self).offset(Constants.padding);
            make.left.equalTo(self);
            make.right.equalTo(self);
            make.height.equalTo(UIScreen.mainScreen().bounds.height * 0.5);
        })
        
        self.emailLabel.snp_remakeConstraints(closure: {
            make in
            make.left.equalTo(self).offset(Constants.padding);
            make.top.equalTo(self.aboutView.snp_bottom).offset(Constants.padding);
            make.width.equalTo(50);
            make.height.equalTo(40);
        })
        
        self.emailInput.snp_remakeConstraints(closure: {
            make in
            make.top.equalTo(self.aboutView.snp_bottom).offset(Constants.padding);
            make.left.equalTo(self.emailLabel.snp_right).offset(Constants.padding);
            make.right.equalTo(self).offset(-Constants.padding);
            make.height.equalTo(40);
        })
        
        
        self.TOSLink.snp_remakeConstraints(closure: {
            make in
            make.bottom.equalTo(self).offset(-Constants.padding);
            make.width.equalTo(150);
            make.height.equalTo(50);
            make.centerX.equalTo(self.snp_centerX);
        })
        
        
        super.updateConstraints();
    }
    
    
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        self.emailInput.endEditing(true);
        return false
    }
    
    
    
    
}

class SettingsViewController: UIViewController {
    
    var settingsView: SettingsView = SettingsView();
    
    
    
    override func loadView() {
        super.loadView();
        self.view = settingsView;
        self.navigationController?.navigationBarHidden = false
        ;

    }
    
    
    
    
    
    
    
}