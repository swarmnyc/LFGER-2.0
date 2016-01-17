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


class SocialShareButton: BaseView {
    
    var unselectedView: UIImageView = UIImageView(image: UIImage(named: "socialBtnBlack")!);
    var selectedView: UIImageView = UIImageView(image: UIImage(named: "socialBtnBlue")!);
    var label: UILabel = UILabel();
    var selected: Bool = false;
    var type: SocialSites = SocialSites.Facebook;
    
    override func didLoad() {
        super.didLoad();
        
        self.label.textAlignment = NSTextAlignment.Center;
        self.label.font = UIFont.systemFontOfSize(13);
        self.unselectedView.contentMode = UIViewContentMode.ScaleAspectFit;
        self.selectedView.contentMode = UIViewContentMode.ScaleAspectFit;
        self.selectedView.alpha = 0;
        self.selectedView.userInteractionEnabled = true;
        self.unselectedView.userInteractionEnabled = true;
        let tap: UITapGestureRecognizer = UITapGestureRecognizer();
        tap.addTarget(self, action: "didTap");
        self.addGestureRecognizer(tap);
//        self.label.addGestureRecognizer(tap);
//        self.unselectedView.addGestureRecognizer(tap);
//        self.selectedView.addGestureRecognizer(tap);
        self.addSubview(self.unselectedView);
        self.addSubview(self.selectedView);
        self.addSubview(self.label);
    }
    
    func setUpSite(site: SocialSites, text: String) {
        self.type = site;
        
        self.label.text = text;
        
    }
    
    func didTap() {
        if (selected) {
            selected = false;
            self.selectedView.alpha = 0;
            self.unselectedView.alpha = 1;
        } else {
            selected = true;
            self.selectedView.alpha = 1;
            self.unselectedView.alpha = 0;
        }
        
        UIApplication.sharedApplication().sendAction("resignFirstResponder", to:nil, from:nil, forEvent:nil)

        
        self.setNeedsLayout();
        self.setNeedsDisplay();
    }
    
    
    override func updateConstraints() {
        
        self.selectedView.snp_remakeConstraints(closure: {
            make in
            make.edges.equalTo(self);
        })
        self.unselectedView.snp_remakeConstraints(closure: {
            make in
            make.edges.equalTo(self);
        })
        self.layoutIfNeeded();
        
        self.label.snp_remakeConstraints(closure: {
            make in
            make.right.equalTo(self);
            make.bottom.equalTo(self.selectedView.snp_centerY).offset(Constants.padding);
            let width = (UIScreen.mainScreen().bounds.width - (4 * Constants.padding)) / 2
            make.height.equalTo(Constants.padding * 2);
            make.left.equalTo(self).offset(Double(width) * 0.25);
        })
        
        super.updateConstraints();
    }
    
    
}

class SocialShareStrip: BaseView {
    
    var facebook: SocialShareButton = SocialShareButton();
    var twitter: SocialShareButton = SocialShareButton();
  
    override func didLoad() {
        super.didLoad();
        
        self.facebook.type = SocialSites.Facebook;
        self.twitter.type = SocialSites.Twitter;
        self.facebook.label.text = "Facebook";
        self.twitter.label.text = "Twitter";
        
        self.addSubview(self.facebook);
        self.addSubview(self.twitter);
        
        self.backgroundColor = UIColor.clearColor();
        
    }
    
    override func updateConstraints() {
        
        self.facebook.snp_remakeConstraints(closure: {
            make in
            make.left.equalTo(self).offset(Constants.padding * 2);
            make.top.equalTo(self).offset(0);
            make.width.equalTo((UIScreen.mainScreen().bounds.width - (5 * Constants.padding)) / 2);
            make.height.equalTo(self.snp_height);
        });
        
        self.twitter.snp_remakeConstraints(closure: {
            make in
            make.left.equalTo(self.facebook.snp_right).offset(Constants.padding);
            make.top.equalTo(self).offset(0);
            make.width.equalTo((UIScreen.mainScreen().bounds.width - (5 * Constants.padding)) / 2);
            make.height.equalTo(self.snp_height);
        })
        
        
        
        super.updateConstraints();
    }
    
    
}