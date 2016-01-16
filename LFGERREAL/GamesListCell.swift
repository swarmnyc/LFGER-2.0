//
//  GamesListCell.swift
//  LFGERREAL
//
//  Created by Alex Hartwell on 1/16/16.
//  Copyright © 2016 SWARM. All rights reserved.
//

import Foundation
import UIKit


class GamesListCell: UITableViewCell, UITextViewDelegate {
    
    static var REUSE_ID = "GamesListCell";
    var name: String = "";
    var game: String = "";
    var system: String = "";
    var timeStamp: String = "";
    var time: NSDate = NSDate();
    var message: String = "";
    var submission: Submission = Submission();
    var messageView: UITextView = UITextView();
    var dateLabel: UILabel = UILabel();
    
    var flag: UIButton = UIButton();
    
    func setItUp(submission: Submission) {
        self.submission = submission;
        self.name = submission.username;
        self.game = submission.game;
        self.system = submission.system.title;
        self.time = submission.timeStamp;
        self.message = submission.message;
        self.timeStamp = self.time.toString(dateStyle: .ShortStyle, timeStyle: .ShortStyle);
        self.dateLabel.text = self.timeStamp;
        self.dateLabel.textColor = UIColor.blackColor();
        self.messageView.delegate = self;
        if (self.messageView.superview == nil) {
            self.contentView.addSubview(self.messageView);
            self.contentView.addSubview(self.dateLabel);
            self.contentView.addSubview(self.flag);
        }

        self.flag.setTitle("Flag Content", forState: .Normal);
        self.flag.setTitleColor(UIColor.blackColor(), forState: .Normal);
        self.flag.addTarget(self, action: "flagContent", forControlEvents: .TouchUpInside);
        
        
        self.messageView.font = UIFont.systemFontOfSize(15);
        self.messageView.backgroundColor = UIColor.clearColor();
        if (submission.isYours) {
            self.backgroundColor = UIColor.lightGrayColor();
        } else {
            self.backgroundColor = UIColor.whiteColor();
        }
        
        self.setText();
    }
    
    func flagContent() {
        
        self.submission.removeIt();
        
        
    }
    
  
    
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        
        
        if (URL.scheme == "username") {
            
            return false;
        }
        
        if (URL.scheme == "system") {
            
            
            return false;
        }
        
        if (URL.scheme == "game") {
            
            return false;
        }
        
        return true;
    }
    
    
    
    func setText() {
        
        self.messageView.textColor = UIColor.blackColor();
        self.messageView.linkTextAttributes = [NSForegroundColorAttributeName: UIColor.blueColor()]
        
        let name: NSMutableAttributedString = NSMutableAttributedString(string: "#" + self.name);
        name.addAttribute(NSLinkAttributeName, value: "username://" + self.name, range: NSRange(location: 0, length: self.name.characters.count));
        
        let game: NSMutableAttributedString = NSMutableAttributedString(string: "#" + self.game);
        game.addAttribute(NSLinkAttributeName, value: "game://" + self.game, range: NSRange(location: 0, length: self.game.characters.count));
        
        let system: NSMutableAttributedString = NSMutableAttributedString(string: "#" + self.system);
        system.addAttribute(NSLinkAttributeName, value: "system://" + self.name, range: NSRange(location: 0, length: self.system.characters.count));
        
        let fullText: NSMutableAttributedString = NSMutableAttributedString(attributedString: name);
        fullText.appendAttributedString(NSAttributedString(string: " is looking to play "));
        fullText.appendAttributedString(game);
        fullText.appendAttributedString(NSAttributedString(string: " on "));
        fullText.appendAttributedString(system);
        fullText.appendAttributedString(NSAttributedString(string: "\n" + self.message));
        
        self.messageView.attributedText = fullText;
        self.messageView.editable = false;
        
        
        
        
    }
    
    
    override func updateConstraints() {
        if (self.messageView.superview != nil) {
            self.messageView.snp_makeConstraints(closure: {
                make in
                make.left.equalTo(self.contentView).offset(Constants.padding);
                make.right.equalTo(self.contentView).offset(Constants.padding * -7);
                make.top.equalTo(self.contentView);
                make.bottom.equalTo(self.contentView);
            })
            
            self.dateLabel.snp_makeConstraints(closure: {
                make in
                make.left.equalTo(self.messageView.snp_right).offset(Constants.padding);
                make.right.equalTo(self.contentView).offset(Constants.padding * -1);
                make.top.equalTo(self.contentView);
                make.bottom.equalTo(self.contentView);
            })
            
            self.flag.snp_remakeConstraints(closure: {
                make in
                make.top.equalTo(self)
                make.right.equalTo(self);
                make.width.equalTo(100);
                make.height.equalTo(30);
            })
            
            
            
        }
        super.updateConstraints();
    }
    
    
    
    
    
}

