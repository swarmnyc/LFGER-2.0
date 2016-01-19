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
    var systemObject: SystemModel?
    var timeStamp: String = "";
    var time: NSDate = NSDate();
    var message: String = "";
    var submission: Submission = Submission();
    var messageView: UITextView = UITextView();
    var dateLabel: UILabel = UILabel();
    var onFilter: (([Submission], String) -> ())?
    var flag: UIButton = UIButton();
    var onFlag: ((Submission) -> ())?
    var visibleIndex: Int = 0;
    
    func setItUp(submission: Submission, visibleIndex: Int, scrollAmount: CGFloat, onFilter: (([Submission], String) -> ()), onFlag: ((Submission) -> ())) {
        self.submission = submission;
        self.name = submission.username;
        self.game = submission.game;
        self.system = submission.system.title;
        self.systemObject = submission.system;
        self.time = submission.timeStamp;
        self.message = submission.message;
        
        self.timeStamp = timeAgoSince(submission.timeStamp);
        let timeString: String = timeAgoSince(submission.timeStamp);
        self.dateLabel.text = timeString;
        self.dateLabel.textColor = UIColor(red: 0.922, green: 0.906, blue: 0.867, alpha: 1.00);
        self.dateLabel.font = UIFont.systemFontOfSize(12);
        self.dateLabel.textAlignment = NSTextAlignment.Right
        self.messageView.delegate = self;
        self.messageView.scrollEnabled = false;
        if (self.messageView.superview == nil) {
            self.contentView.addSubview(self.messageView);
            self.contentView.addSubview(self.dateLabel);
            self.contentView.addSubview(self.flag);
        }

        self.flag.setTitle("Report", forState: .Normal);
        self.flag.setTitleColor(UIColor(red: 0.922, green: 0.906, blue: 0.867, alpha: 1.00), forState: .Normal);
        self.flag.titleLabel!.font = UIFont.systemFontOfSize(12);
        self.flag.addTarget(self, action: "flagContent", forControlEvents: .TouchUpInside);
        self.flag.titleLabel!.textAlignment = NSTextAlignment.Right;
        self.flag.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        self.flag.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Right
        
        
        self.visibleIndex = visibleIndex;
        if (scrollAmount == 0) {
            self.alpha = 0;
            UIView.animateWithDuration(0.15 * Double(visibleIndex), animations: {
                self.alpha = 1;
            })
        }
        
        
        self.messageView.font = UIFont.systemFontOfSize(15);
        self.messageView.textColor = UIColor(red: 0.922, green: 0.906, blue: 0.867, alpha: 1.00);
        self.messageView.backgroundColor = UIColor.clearColor();
        if (submission.isYours) {
            self.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.2);
        } else {
            self.backgroundColor = UIColor.clearColor();
        }
        
        self.onFilter = onFilter;
        self.onFlag = onFlag;
        self.setText();
    }
    
    func flagContent() {
        
        self.onFlag?(self.submission);
        
    }
    
  
    
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        
        print(URL.description);
        
        print(URL.scheme);
        print(URL.host);
        
        if (URL.scheme == "username") {
           

            return false;
        }
        
        if (URL.scheme == "system") {
            print(URL.host!);
            SubmissionService.getGames("", platform: URL.host!, callback: {
                submissions in
                self.onFilter?(submissions, submissions[0].system.getTitleText());
            })
            
            return false;
        }
        
        if (URL.scheme == "game") {
            print(URL.host!);
            SubmissionService.getGames(URL.host!.stringByReplacingOccurrencesOfString("~~~", withString: " "), platform: "", callback: {
                submissions in
                self.onFilter?(submissions, URL.host!.stringByReplacingOccurrencesOfString("~~~", withString: " "));
            })
            return false;
        }
        
        return true;
    }
    
    
    
    func setText() {
        
        self.messageView.textColor = UIColor(red: 0.922, green: 0.906, blue: 0.867, alpha: 1.00);
        self.messageView.linkTextAttributes = [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue]
        
        
        let profileLink: String = self.systemObject!.getProfileLink(self.name);
        let name: NSMutableAttributedString = NSMutableAttributedString(string: "@" + self.name);
        name.addAttribute(NSLinkAttributeName, value: profileLink.stringByReplacingOccurrencesOfString(" ", withString: "%20"), range: NSRange(location: 0, length: self.name.characters.count + 1));
        
        let game: NSMutableAttributedString = NSMutableAttributedString(string: "#" + self.game);
        game.addAttribute(NSLinkAttributeName, value: "game://" + self.game.stringByReplacingOccurrencesOfString(" ", withString: "~~~"), range: NSRange(location: 0, length: self.game.characters.count + 1));
        
        let system: NSMutableAttributedString = NSMutableAttributedString(string: "#" + self.system);
        system.addAttribute(NSLinkAttributeName, value: "system://" + self.systemObject!.getPlatformShortName(), range: NSRange(location: 0, length: self.system.characters.count + 1));
        
        let fullText: NSMutableAttributedString = NSMutableAttributedString(attributedString: name);
        
        fullText.appendAttributedString(NSAttributedString(string: " is looking to play "));
        fullText.appendAttributedString(game);
        fullText.appendAttributedString(NSAttributedString(string: " on "));
        fullText.appendAttributedString(system);
        fullText.appendAttributedString(NSAttributedString(string: "\n\n" + self.message + "\n"));
        fullText.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 0.922, green: 0.906, blue: 0.867, alpha: 1.00), range: NSRange(location: 0, length: fullText.string.characters.count));
        
        fullText.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(14), range: NSRange(location: 0, length: fullText.string.characters.count));
        
        self.messageView.attributedText = fullText;
        self.messageView.editable = false;
        
        
        
        
    }
    
    
    override func updateConstraints() {
        if (self.messageView.superview != nil) {
            self.messageView.snp_makeConstraints(closure: {
                make in
                make.left.equalTo(self.contentView).offset(Constants.padding);
                make.right.equalTo(self.contentView).offset(Constants.padding * -14);
                make.top.equalTo(self.contentView);
                make.bottom.equalTo(self.contentView).offset(-Constants.padding);
            })
            
            
            
            self.dateLabel.snp_remakeConstraints(closure: {
                make in
                make.top.equalTo(self.messageView.snp_top).offset(Constants.padding * 1.3);
                make.right.equalTo(self).offset(-Constants.padding * 2);
                make.width.equalTo(100);
                make.height.equalTo(13);
            })
            
            self.flag.snp_makeConstraints(closure: {
                make in
                make.right.equalTo(self.dateLabel.snp_right);
                make.width.equalTo(60);
                make.height.equalTo(20);
                make.top.equalTo(self.dateLabel.snp_bottom);
            })
            
            
            
        }
        super.updateConstraints();
    }
    
    
    
    
    
}

