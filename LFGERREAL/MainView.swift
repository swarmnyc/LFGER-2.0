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
    var goBackLink: UIButton = UIButton();
    var goToSettings: (() -> ())?
    var goBack: (() -> ())?
    var onTop: Bool = true;
    var title: UILabel = UILabel();
    var resultsTop: UIImageView = UIImageView(image: UIImage(named: "resultsTop")!);
    var resultsMid: UIImageView = UIImageView(image: UIImage(named: "resultsMid")!);
    var gamesListOffset: CGFloat = 0;

    
    func goToSettingsFunc(callback: (() -> ())) {
        self.goToSettings = callback;
    }
    
    func goBackFunc(callback: (() -> ())) {
        self.goBack = callback;
    }
    
   
    
    func setItUp(topView: UIView, bottomView: UIView) {
        self.topView = topView;
        self.bottomView = bottomView;
        
        self.backgroundColor = Constants.lightBackgroundColor;
        
        self.addSubview(self.topView);
        self.addSubview(self.resultsTop);
        self.addSubview(self.resultsMid);
        self.addSubview(self.bottomView);
        self.contentSize = CGSizeMake(UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height * 1.75);
        
        
        self.addSubview(self.grip);
        self.addSubview(self.goToGames);
        self.addSubview(self.goToLFG);
        self.bottomView.backgroundColor = UIColor.clearColor();
        
        self.resultsMid.contentMode = UIViewContentMode.ScaleToFill;
        self.resultsTop.contentMode = UIViewContentMode.ScaleToFill;
        self.resultsTop.backgroundColor = UIColor.clearColor();
        self.resultsTop.opaque = false;
        
        self.grip.contentMode = UIViewContentMode.ScaleAspectFit;
        
        self.goToGames.alpha = 0;
        self.goToGames.setTitle("LOOKING FOR GROUPS", forState: .Normal);
        self.goToGames.setTitleColor(UIColor.blackColor(), forState: .Normal);
        self.goToGames.backgroundColor = UIColor.clearColor();
        self.goToGames.addTarget(self, action: "goToTheGames", forControlEvents: .TouchUpInside);
        
        
        self.goToLFG.alpha = 0;
        self.goToLFG.setTitle("LOOKING FOR GAMERS", forState: .Normal);
        self.goToLFG.setTitleColor(UIColor.blackColor(), forState: .Normal);
        self.goToLFG.backgroundColor = UIColor.clearColor();
        self.goToLFG.addTarget(self, action: "goToTheGamers", forControlEvents: .TouchUpInside);
        
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer();
        tapGesture.addTarget(self, action: "removeKeyboard");
        tapGesture.delegate = self;
        self.addGestureRecognizer(tapGesture);
        
        self.canCancelContentTouches = true;
        
        self.settingsLink.setTitle("SETTINGS", forState: .Normal);
        self.settingsLink.setTitleColor(UIColor(red: 0.922, green: 0.906, blue: 0.867, alpha: 1.00), forState: .Normal);
        self.settingsLink.addTarget(self, action: "goToSettingsPage", forControlEvents: .TouchUpInside);
        self.addSubview(self.settingsLink);
        
        self.goBackLink.setTitle("BACK", forState: .Normal);
        self.goBackLink.setTitleColor(UIColor(red: 0.922, green: 0.906, blue: 0.867, alpha: 1.00), forState: .Normal);
        self.goBackLink.addTarget(self, action: "goBackALevel", forControlEvents: .TouchUpInside);
        self.goBackLink.alpha = 0;
        self.goBackLink.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left;
        self.addSubview(self.goBackLink);
        
        let text = "GAMERS";
        self.setTitleAttrText(text);
        self.addSubview(self.title);
        self.title.clipsToBounds = false;
        
        
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.alwaysBounceVertical = false;
        self.setNeedsUpdateConstraints();
        
        
    }
    
    
    func setTitleAttrText(text: String) {
        let attrString = NSMutableAttributedString(string: text);
        attrString.addAttributes([NSTextEffectAttributeName: NSTextEffectLetterpressStyle,
            NSForegroundColorAttributeName: UIColor(red: 0.922, green: 0.906, blue: 0.867, alpha: 1.00)], range: NSRange(location: 0, length: text.characters.count));
        self.title.attributedText = attrString;
        self.title.textAlignment = NSTextAlignment.Center;
        self.title.font = UIFont.systemFontOfSize(24);

    }
    
    func getTitleText() -> NSAttributedString {
        return self.title.attributedText!;
    }
    
    func goToSettingsPage() {
        self.goToSettings?();
    }
    
    func goBackALevel() {
        self.goBack?();
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
        
        self.resultsTop.snp_remakeConstraints(closure: {
            make in
            make.top.equalTo(self.topView.snp_bottom);
            make.left.equalTo(self);
            make.width.equalTo(UIScreen.mainScreen().bounds.width);
            make.height.equalTo(UIScreen.mainScreen().bounds.height * 0.05);
        })
        self.resultsMid.snp_remakeConstraints(closure: {
        make in
        make.top.equalTo(self.resultsTop.snp_bottom);
        make.left.equalTo(self);
        make.width.equalTo(UIScreen.mainScreen().bounds.width);
        make.height.equalTo(UIScreen.mainScreen().bounds.height * 1.4);
        })
        
        self.bottomView.snp_remakeConstraints(closure: {
            make in
            make.bottom.equalTo(self).offset(self.gamesListOffset);
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
            make.bottom.equalTo(self.goToLFG.snp_bottom).offset(-Constants.padding);
            make.right.equalTo(self.goToLFG.snp_right).offset(-Constants.padding);
            make.width.equalTo(100);
            make.height.equalTo(40);
        })
        
        
        self.goBackLink.snp_remakeConstraints(closure: {
            make in
            make.bottom.equalTo(self.goToLFG.snp_bottom).offset(-Constants.padding);
            make.left.equalTo(self.goToLFG.snp_left).offset(Constants.padding * 2);
            make.width.equalTo(100);
            make.height.equalTo(40);
        })
        self.title.snp_remakeConstraints(closure: {
            make in
            
            make.bottom.equalTo(self.bottomView.snp_top).offset(-1 * Constants.padding * 2);
            make.left.equalTo(self).offset(UIScreen.mainScreen().bounds.width / 3);
            make.width.equalTo(UIScreen.mainScreen().bounds.width / 3);
            make.height.equalTo(28);
        })
        
        super.updateConstraints();
    }
    
    
}