//
//  MainView.swift
//  LFGER
//
//  Created by Alex Hartwell on 1/16/16.
//  Copyright © 2016 SWARM. All rights reserved.
//

import Foundation
import UIKit






class MainView: UIScrollView, UIGestureRecognizerDelegate {
    
    var topView: UIView = UIView();
    var bottomView: UIView = UIView();
    var grip: UIImageView = UIImageView(image: UIImage(named: "grip")!);
    var goToGames: UIButton = UIButton();
    var goToLFG: UIButton = UIButton();
    var settingsLink: UIButton = UIButton();
    var goToSettings: (() -> ())?
    var onTop: Bool = true;
    
    func goToSettingsFunc(callback: (() -> ())) {
        self.goToSettings = callback;
    }
    
    func setItUp(topView: UIView, bottomView: UIView) {
        self.topView = topView;
        self.bottomView = bottomView;
        
        self.backgroundColor = UIColor.whiteColor();
        
        self.addSubview(self.topView);
        self.addSubview(self.bottomView);
        self.contentSize = CGSizeMake(UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height * 1.75);
        
        self.addSubview(self.goToGames);
        self.addSubview(self.goToLFG);
        self.addSubview(self.grip);
        self.grip.contentMode = UIViewContentMode.ScaleAspectFit;
        
        self.goToGames.alpha = 0;
        self.goToGames.setTitle("LOOKING FOR GROUPS", forState: .Normal);
        self.goToGames.setTitleColor(UIColor.blackColor(), forState: .Normal);
        self.goToGames.backgroundColor = UIColor.grayColor();
        self.goToGames.addTarget(self, action: "goToTheGames", forControlEvents: .TouchUpInside);
        
        
        self.goToLFG.alpha = 0;
        self.goToLFG.setTitle("LOOKING FOR GAMERS", forState: .Normal);
        self.goToLFG.setTitleColor(UIColor.blackColor(), forState: .Normal);
        self.goToLFG.backgroundColor = UIColor.grayColor();
        self.goToLFG.addTarget(self, action: "goToTheGamers", forControlEvents: .TouchUpInside);
        
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer();
        tapGesture.addTarget(self, action: "removeKeyboard");
        tapGesture.delegate = self;
        self.addGestureRecognizer(tapGesture);
        
        self.canCancelContentTouches = true;
        
        self.settingsLink.setTitle("Settings", forState: .Normal);
        self.settingsLink.setTitleColor(UIColor.blackColor(), forState: .Normal);
        self.settingsLink.addTarget(self, action: "goToSettingsPage", forControlEvents: .TouchUpInside);
        self.addSubview(self.settingsLink);
        
        
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.alwaysBounceVertical = false;
        self.setNeedsUpdateConstraints();
    }
    
    
    func goToSettingsPage() {
        self.goToSettings?();
    }
    
    
    func goToTheGames() {
        self.setContentOffset(CGPointMake(0, UIScreen.mainScreen().bounds.height), animated: true);
    }
    
    func goToTheGamers() {
        self.setContentOffset(CGPointMake(0,0), animated: true);
    }
    
    func removeKeyboard() {
        self.endEditing(true);
    }
    
    
    override func updateConstraints() {
        
        
        self.topView.snp_remakeConstraints(closure: {
            make in
            make.top.equalTo(self);
            make.left.equalTo(self);
            make.width.equalTo(UIScreen.mainScreen().bounds.width);
            make.height.equalTo(UIScreen.mainScreen().bounds.height);
        })
        self.bottomView.snp_remakeConstraints(closure: {
            make in
            make.bottom.equalTo(self);
            make.left.equalTo(self);
            make.width.equalTo(UIScreen.mainScreen().bounds.width);
            make.height.equalTo(UIScreen.mainScreen().bounds.height * 0.75);
            make.top.equalTo(self.goToLFG.snp_bottom);
        })
        
        
        self.grip.snp_remakeConstraints(closure: {
            make in
            make.centerY.equalTo(self.topView.snp_bottom).offset(-1 * UIScreen.mainScreen().bounds.height * 0.065);
            make.centerX.equalTo(self.bottomView.snp_centerX);
            make.width.equalTo(UIScreen.mainScreen().bounds.width * 0.15);
            make.height.equalTo(UIScreen.mainScreen().bounds.height * 0.2);
        })
        
        self.goToGames.snp_remakeConstraints(closure: {
            make in
            make.bottom.equalTo(self.topView.snp_bottom);
            make.left.equalTo(self);
            make.width.equalTo(UIScreen.mainScreen().bounds.width);
            make.height.equalTo(75);
        })
        self.goToLFG.snp_remakeConstraints(closure: {
            make in
            make.top.equalTo(self.goToGames.snp_bottom);
            make.left.equalTo(self);
            make.width.equalTo(UIScreen.mainScreen().bounds.width);
            make.height.equalTo(75);
        })
        
        self.settingsLink.snp_remakeConstraints(closure: {
            make in
            make.bottom.equalTo(self.goToLFG.snp_bottom);
            make.right.equalTo(self.goToLFG.snp_right).offset(-Constants.padding);
            make.width.equalTo(100);
            make.height.equalTo(40);
        })
        
        super.updateConstraints();
    }
    
    
}