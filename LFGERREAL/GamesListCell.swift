//
//  GamesListCell.swift
//  LFGERREAL
//
//  Created by Alex Hartwell on 1/16/16.
//  Copyright © 2016 SWARM. All rights reserved.
//

import Foundation
import UIKit


class SWRMSwipeTableViewCell: UITableViewCell {
    
    var swipeView: UIView = UIView();
    var swiper: UIPanGestureRecognizer = UIPanGestureRecognizer();
    var lastLocation: CGPoint = CGPointMake(-1000, -1000);
    var maxX: CGFloat = 75;
    var minX: CGFloat = -75;
    var centerX: CGFloat = 0;
    var originX: CGFloat = 0;
    var velocity: CGPoint = CGPoint();
    var transformX: CGFloat = 0;
    
    var openedLeft: (() -> ())?
    var openedRight: (() -> ())?
    
    var endTimer: NSTimer?
    
    func setUpSwiper() {
        self.swipeView.addGestureRecognizer(self.swiper);
        self.swiper.addTarget(self, action: "swiped:");
        self.swiper.delegate = self;
        self.contentView.addGestureRecognizer(self.swiper);
        self.clipsToBounds = true;
    }
    
    
    func swiped(gestureRecognizer: UIPanGestureRecognizer) {
        let location = gestureRecognizer.locationInView(self.contentView);
        self.velocity = gestureRecognizer.velocityInView(self.contentView);
        if (gestureRecognizer.state == UIGestureRecognizerState.Began) {
            self.lastLocation = location;
            return;
        }
        
        let xOffset = (location.x - self.lastLocation.x);
        if (xOffset < 0 && self.centerX == 0) {
            return;
        }
        let newTransformX = self.centerX + xOffset;
        if (abs(newTransformX - self.transformX) > 8) {
            self.transformX = newTransformX;
            UIView.animateWithDuration(0.08, animations: {
                let transform: CGAffineTransform = CGAffineTransformMakeTranslation(self.transformX, 0);
                self.contentView.transform = transform;
            })
        }
        
        
        
        if (gestureRecognizer.state == UIGestureRecognizerState.Ended) {
            self.end();
        }
    }
    
    
    func end() {
        var newX: CGFloat = 0;
        
        if (self.transformX > self.maxX) {
            newX = self.maxX;
            self.centerX = newX;
        } else if (self.centerX == self.originX && self.velocity.x > 0.15 && self.transformX > (self.maxX * 0.3)) {
            newX = self.maxX;
            self.centerX = newX;
        } else if (self.centerX == self.originX && self.velocity.x < -0.15 && self.transformX < (self.minX * 0.3)) {
            newX = self.minX;
            self.centerX = newX;
        } else if (self.centerX == self.maxX && self.velocity.x < 0) {
            newX = self.originX;
            self.centerX = self.originX;
        } else if (self.centerX == self.minX && self.velocity.x > 0) {
            newX = self.originX;
            self.centerX = self.originX;
        }
        
        
        UIView.animateWithDuration(0.3, animations: {
            let transform: CGAffineTransform = CGAffineTransformMakeTranslation(newX, 0);
            self.contentView.transform = transform;
            }, completion: self.opened);
        
    }
    
    func opened(done: Bool) {
        if (self.centerX == self.maxX) {
            self.openedLeft?();
        } else if (self.centerX == self.minX) {
            self.openedRight?();
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse();

        self.transformX = 0;
        self.centerX = self.originX;
        
        let transform: CGAffineTransform = CGAffineTransformMakeTranslation(self.transformX, 0);
        self.contentView.transform = transform;
    
    }
    
    override func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true;
    }
    
}

class ReportCell: SWRMSwipeTableViewCell {
    
    var reportIt: FlagContent = FlagContent();
    var onFlag: ((AnyObject) -> ())?

    
    func addReportButton() {
        self.addSubview(self.reportIt);
    }
    
    
    override func updateConstraints() {
        
        if (self.reportIt.superview != nil) {
            self.reportIt.snp_makeConstraints(closure: {
                make in
                make.left.equalTo(self).offset(Constants.padding * 2);
                make.centerY.equalTo(self.contentView.snp_centerY);
                make.height.equalTo(Constants.flagHeight);
                make.width.equalTo(self.reportIt.snp_height);
            });

        }
        super.updateConstraints();
    }
    
    
}



class MessageCell: GamesListCell {
   
    static var REUSE_ID_MESSAGE_CELL = "MessageCell";
    
    var comment: Comment?
    
    func setItUp(submission: Comment, visibleIndex: Int, scrollAmount: CGFloat, onFlag: ((AnyObject) -> ())) {
        self.minX = 0;
        self.comment = submission;
        self.name = submission.username;
        self.time = submission.timeStamp;
        self.message = submission.message;
        
        self.timeStamp = timeAgoSince(submission.timeStamp);
        let timeString: String = timeAgoSince(submission.timeStamp);
        self.dateLabel.text = timeString;
        self.dateLabel.textColor = Constants.tanColor;
        self.dateLabel.font = UIFont.systemFontOfSize(12);
        self.dateLabel.textAlignment = NSTextAlignment.Right
        self.messageView.delegate = self;
        self.messageView.scrollEnabled = false;
        if (self.messageView.superview == nil) {
            self.contentView.addSubview(self.messageView);
            self.contentView.addSubview(self.dateLabel);
            self.contentView.addSubview(self.hairline);
            self.hairline.backgroundColor = Constants.tanColor;

            self.setUpSwiper();
            self.addReportButton();
            self.bringSubviewToFront(self.contentView);
        }
        
        
        self.reportIt.setUpTouchCallback(self.flagContent);
        
        
        self.visibleIndex = visibleIndex;
        if (scrollAmount == 0) {
            self.alpha = 0;
            UIView.animateWithDuration(0.15 * Double(visibleIndex), animations: {
                self.alpha = 1;
            })
        }
        
        
        self.messageView.font = UIFont.systemFontOfSize(15);
        self.messageView.textColor = Constants.tanColor;
        self.messageView.backgroundColor = UIColor.clearColor();
        self.messageView.userInteractionEnabled = true;
        
        self.backgroundColor = UIColor.clearColor();
        self.contentView.backgroundColor = UIColor(red: 0.529, green: 0.494, blue: 0.494, alpha: 1.00);
        
        
        self.onFilter = nil;
        self.onFlag = onFlag;
        self.setText();
        self.setNeedsUpdateConstraints();
    }
    
    
    override func flagContent() {
        if let com = comment {
        self.onFlag?(com);
        }
    }
    
    override  func setText() {
        
        self.messageView.textColor = Constants.tanColor;
        self.messageView.linkTextAttributes = [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue]
        
        
        let name: NSMutableAttributedString = NSMutableAttributedString(string: "@" + self.name);
        
        
        let fullText: NSMutableAttributedString = NSMutableAttributedString(attributedString: name);
        
        fullText.appendAttributedString(NSAttributedString(string: ":\n\n" + self.message + "\n"));
        fullText.addAttribute(NSForegroundColorAttributeName, value: Constants.tanColor, range: NSRange(location: 0, length: fullText.string.characters.count));
        
        fullText.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(14), range: NSRange(location: 0, length: fullText.string.characters.count));
        fullText.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFontOfSize(14), range: NSRange(location: 0, length: self.name.characters.count + 1))
        self.messageView.attributedText = fullText;
        self.messageView.editable = false;
        
        
        
        
    }
    
    override func updateConstraints() {
        super.updateConstraints();
        
        if (messageView.superview != nil) {
            self.messageView.snp_updateConstraints(closure: {
                make in
                make.width.equalTo(UIScreen.mainScreen().bounds.width - (Constants.padding * 4));
                make.right.equalTo(self).offset(-Constants.padding * 2);
            })
        }
        
    }

    
}


class GamesListCell: ReportCell, UITextViewDelegate {
    
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
    var onFilter: ((String, String, [Submission], String) -> ())?
    var goToComment: ((Submission) -> ())?
    var visibleIndex: Int = 0;
    
    var hairline: UIView = UIView();
    var tapIt: UITapGestureRecognizer = UITapGestureRecognizer();
    var commentIcon: CommentCountView = CommentCountView();
    var clickedText: Bool = false;
    
    func setItUp(submission: Submission, visibleIndex: Int, scrollAmount: CGFloat, onFilter: ((String, String, [Submission], String) -> ()), onFlag: ((AnyObject) -> ()), goToComment: ((Submission) -> ())) {
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
        self.dateLabel.textColor = Constants.tanColor;
        self.dateLabel.font = UIFont.systemFontOfSize(12);
        self.dateLabel.textAlignment = NSTextAlignment.Right
        self.messageView.delegate = self;
        self.messageView.scrollEnabled = false;
        if (self.messageView.superview == nil) {
            self.contentView.addSubview(self.messageView);
            self.contentView.addSubview(self.dateLabel);
            self.contentView.addSubview(self.commentIcon);
            self.contentView.addSubview(self.hairline);
            
            self.hairline.backgroundColor = Constants.tanColor;
            
            self.setUpSwiper();
            self.addReportButton();
            self.bringSubviewToFront(self.contentView);
            
            self.tapIt.addTarget(self, action: "tapRecognize:");
            self.contentView.addGestureRecognizer(self.tapIt);
            self.tapIt.delegate = self;
        }

        self.commentIcon.setCount(submission.comments.count);
        let callback = {
            goToComment(self.submission);
        }
        self.commentIcon.callback = callback;
        
        
        self.reportIt.setUpTouchCallback(self.flagContent);
        
        
        self.visibleIndex = visibleIndex;
        if (scrollAmount == 0) {
            self.alpha = 0;
            UIView.animateWithDuration(0.15 * Double(visibleIndex), animations: {
                self.alpha = 1;
            })
        }
        
        
        self.messageView.font = UIFont.systemFontOfSize(15);
        self.messageView.textColor = Constants.tanColor;
        self.messageView.backgroundColor = UIColor.clearColor();
        self.messageView.userInteractionEnabled = true;
        if (submission.isYours) {
            self.backgroundColor = UIColor(red: 0.663, green: 0.635, blue: 0.635, alpha: 1.00);
            self.contentView.backgroundColor = UIColor(red: 0.663, green: 0.635, blue: 0.635, alpha: 1.00);

        } else {
            self.backgroundColor = UIColor.clearColor();
            self.contentView.backgroundColor = UIColor(red: 0.529, green: 0.494, blue: 0.494, alpha: 1.00);
        }
        
        
        self.onFilter = onFilter;
        self.onFlag = onFlag;
        self.setText();
        
        self.openedRight = {
            self.goToComment?(self.submission);
        }
        
    }
    
    func tapRecognize(sender: UITapGestureRecognizer) {
        if (sender.state == .Ended) { //because the gesture recognizer fires before the textView delegate methods we have to put it on a timer and check if the user is clicking a url
            NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "goToComments", userInfo: nil, repeats: false);
        }
        
      
    }
    
    func goToComments() {
        defer {
            self.clickedText = false;
        }
        
        if (self.clickedText) { //if they clicked a url don't show comments
            return;
        }
        
       
        self.commentIcon.callback?();
        
    }
    
    func flagContent() {
        
        self.onFlag?(self.submission);
        
    }
    
  
    
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        
        self.clickedText = true;
        
       
        
        if (URL.scheme == "username") {
           

            return false;
        }
        
        if (URL.scheme == "system") {
            print(URL.host!);
            SubmissionService.getGames("", platform: URL.host!, page: 0, limit: 0, callback: {
                submissions in
                self.onFilter?("", URL.host!, submissions, submissions[0].system.getTitleText());
            })
            
            return false;
        }
        
        if (URL.scheme == "game") {
            print(URL.host!);
            let game = URL.host!.stringByReplacingOccurrencesOfString("~~~", withString: " ")
            SubmissionService.getGames(game, platform: "", page: 0, limit: 0, callback: {
                submissions in
                self.onFilter?(game, "", submissions, URL.host!.stringByReplacingOccurrencesOfString("~~~", withString: " "));
            })
            return false;
        }
        
        return true;
    }
    
    
    
    func setText() {
        
        self.messageView.textColor = Constants.tanColor;
        self.messageView.font = UIFont.systemFontOfSize(14);
        self.messageView.linkTextAttributes = [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue]
        
        
        let profileLink: String = self.systemObject!.getProfileLink(self.name);
        let name: NSMutableAttributedString = NSMutableAttributedString(string: "@" + self.name);
        name.addAttribute(NSLinkAttributeName, value: profileLink.stringByReplacingOccurrencesOfString(" ", withString: "%20"), range: NSRange(location: 0, length: self.name.characters.count + 1));
        name.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFontOfSize(14), range: NSRange(location: 0, length: self.name.characters.count + 1))
        
        
        let game: NSMutableAttributedString = NSMutableAttributedString(string: "#" + self.game);
        game.addAttribute(NSLinkAttributeName, value: "game://" + self.game.stringByReplacingOccurrencesOfString(" ", withString: "~~~"), range: NSRange(location: 0, length: self.game.characters.count + 1));
        game.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFontOfSize(14), range: NSRange(location: 0, length: self.game.characters.count + 1))
        
        let system: NSMutableAttributedString = NSMutableAttributedString(string: "#" + self.system);
        system.addAttribute(NSLinkAttributeName, value: "system://" + self.systemObject!.getPlatformShortName(), range: NSRange(location: 0, length: self.system.characters.count + 1));
        system.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFontOfSize(14), range: NSRange(location: 0, length: self.system.characters.count + 1))
        let fullText: NSMutableAttributedString = NSMutableAttributedString(attributedString: name);
        
        let str = " is looking to play ";
        let looking = NSMutableAttributedString(string: str);
        looking.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(14), range: NSRange(location: 0, length: str.characters.count - 1));
        let str2 = " on ";
        let on = NSMutableAttributedString(string: str2);
        on.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(14), range: NSRange(location: 0, length: str2.characters.count - 1));
        let str3 = "\n\n" + self.message + "\n";
        let mess = NSMutableAttributedString(string: str3);
        mess.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(14), range: NSRange(location: 0, length: str3.characters.count - 1));

        
        fullText.appendAttributedString(looking);
        fullText.appendAttributedString(game);
        fullText.appendAttributedString(on);
        fullText.appendAttributedString(system);
        fullText.appendAttributedString(mess);
        fullText.addAttribute(NSForegroundColorAttributeName, value: Constants.tanColor, range: NSRange(location: 0, length: fullText.string.characters.count));
        
      
       
        self.messageView.attributedText = fullText;
        self.messageView.editable = false;
        
        
        
        
    }
    
    
    override func updateConstraints() {
        if (self.messageView.superview != nil) {
            
            self.contentView.snp_updateConstraints(closure: {
                make in
                make.left.equalTo(self).offset(Constants.padding);
                make.right.equalTo(self).offset(Constants.padding * -1);
                make.height.equalTo(self.frame.height);
                make.top.equalTo(self);
            })
            
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
            
            self.hairline.snp_remakeConstraints(closure: {
                make in
                make.bottom.equalTo(self.messageView.snp_bottom).offset(Constants.padding);
                make.left.equalTo(self.contentView);
                make.width.equalTo(self.contentView);
                make.height.equalTo(1);
            })
            
            
            if (self.commentIcon.superview != nil) {
                self.commentIcon.snp_makeConstraints(closure: {
                    make in
                    make.right.equalTo(self.dateLabel.snp_right);
                    make.width.equalTo(40);
                    make.height.equalTo(40);
                    make.top.equalTo(self.dateLabel.snp_bottom);
                })
            }
            
            
        }
        super.updateConstraints();
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse();
        self.commentIcon.callback = nil;
    }
    
    
    
    
    
}

