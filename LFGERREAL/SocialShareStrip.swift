//
//  SocialShareStrip.swift
//  LFGER
//
//  Created by Alex Hartwell on 1/16/16.
//  Copyright © 2016 SWARM. All rights reserved.
//

import Foundation
import UIKit

enum SocialSites {
    case Twitter
    case Facebook
}

class SocialShareStrip: BaseView {
    
    var facebookLabel: UILabel = UILabel();
    var twitterLabel: UILabel = UILabel();
    var fbSwitch: UISwitch = UISwitch();
    var twitterSwitch: UISwitch = UISwitch();
  
    override func didLoad() {
        super.didLoad();
        
        self.addSubview(self.facebookLabel);
        self.addSubview(self.twitterLabel);
        self.addSubview(self.fbSwitch);
        self.addSubview(self.twitterSwitch);
        
        
        self.facebookLabel.text = "Facebook"
        self.twitterLabel.text = "Twitter";
        
        self.backgroundColor = UIColor.grayColor();
        
    }
    
    override func updateConstraints() {
        
        self.facebookLabel.snp_remakeConstraints(closure: {
            make in
            make.left.equalTo(self).offset(Constants.padding);
            make.top.equalTo(self).offset(Constants.padding);
            make.width.equalTo(UIScreen.mainScreen().bounds.width * 0.75);
            make.bottom.equalTo(self.snp_centerY).offset(-Constants.padding);
        });
        
        self.twitterLabel.snp_remakeConstraints(closure: {
            make in
            make.left.equalTo(self).offset(Constants.padding);
            make.top.equalTo(self.snp_centerY).offset(Constants.padding);
            make.width.equalTo(UIScreen.mainScreen().bounds.width * 0.75);
            make.bottom.equalTo(self).offset(-Constants.padding);
        })
        
        self.fbSwitch.snp_remakeConstraints(closure: {
            make in
            make.left.equalTo(self.facebookLabel.snp_right);
            make.right.equalTo(self)
            make.top.equalTo(self.facebookLabel);
            make.bottom.equalTo(self.facebookLabel);
        })
        
        self.twitterSwitch.snp_remakeConstraints(closure: {
            make in
            make.left.equalTo(self.twitterLabel.snp_right);
            make.right.equalTo(self)
            make.top.equalTo(self.twitterLabel);
            make.bottom.equalTo(self.twitterLabel);
        })
        
        
        super.updateConstraints();
    }
    
    
}