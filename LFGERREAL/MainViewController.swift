//
//  ViewController.swift
//  LFGER
//
//  Created by Alex Hartwell on 1/16/16.
//  Copyright © 2016 SWARM. All rights reserved.
//

import UIKit
import Social

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {

    var submission: Submission = Submission();
    var systems: [SystemModel] = [SystemModel(type: System.PC),SystemModel(type: System.XBOXONE), SystemModel(type: System.PS4)];
    var mainView: MainView = MainView();
    var lfgView: LFGView = LFGView();
    var gamesList: GamesListView = GamesListView();
    
    var gameListData: [Submission] = [];
    var oldData: [([Submission], String, Int, String, String)] = []; //submissions, title, page, currGame, currPlatform
    
    var commentsData: [Comment] = [];
    var submissionShowingCommentFor: Submission = Submission();
    
    var showingComments: Bool = false;
    var page: Int = 0;
    var currentGame: String = "";
    var currentPlatform: String = "";
    var gettingPage: Bool = false;
    
    var limit: Int = 20;
    
    var submitDebounce: Bool = false;
    
    
    func resetViewToLFGS() {
        self.gamesList.hideCommenter();
        self.gamesList.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        self.showingComments = false;
    }
    
    
    func setGamesListToHistoryAtIndex(index: Int, callback: (() -> ())) {
        self.gameListData = self.oldData[index].0;
        self.currentGame = self.oldData[index].3;
        self.currentPlatform = self.oldData[index].4;
        self.page = self.oldData[index].2;
        self.animateOutCells({
            self.gamesList.reloadData();
            self.mainView.setTitleAttrText(self.oldData[index].1)
            self.oldData.removeAtIndex(index);
            if (self.oldData.count == 0) {
                UIView.animateWithDuration(0.3, animations: {
                    self.mainView.goBackLink.alpha = 0;    
//                    self.mainView.goBackLink.transform = CGAffineTransformMakeTranslation(-200, 0);
                });
            }
            callback();
            
        });
    }
    
    override func loadView() {
        super.loadView();
        self.view = self.mainView;
        self.mainView.goToSettingsFunc({
           self.navigationController?.pushViewController(SettingsViewController(), animated: true);
        });
        self.mainView.goBackFunc({
            if (self.oldData.count > 0) {
                self.resetViewToLFGS();
//                self.oldData.count - 1
                self.setGamesListToHistoryAtIndex(self.oldData.count - 1, callback: {
                     NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "getNewData", userInfo: nil, repeats: false);
                })
                
            }
            
        })
        
        
        
        
        self.gamesList.registerClass(GamesListCell.self, forCellReuseIdentifier: GamesListCell.REUSE_ID);
        self.gamesList.registerClass(MessageCell.self, forCellReuseIdentifier: MessageCell.REUSE_ID_MESSAGE_CELL);

        self.gamesList.backgroundColor = UIColor.clearColor();
        self.gamesList.dataSource = self;
        self.gamesList.delegate = self;
        self.gamesList.separatorStyle = UITableViewCellSeparatorStyle.None;
        self.gamesList.separatorColor = UIColor(red: 0.290, green: 0.271, blue: 0.271, alpha: 1.00)
        self.gamesList.allowsSelection = false;
        self.mainView.setItUp(self.lfgView, bottomView: self.gamesList);
        self.mainView.delegate = self;
        self.lfgView.setUpSystems(systems, onChange: {
            platformId, oldIndex in
            
            if (self.lfgView.getGamerTag() == "") {
                return
            }
            
            SavedData.saveData("name:" + self.systems[oldIndex].getPlatformId(), value: self.lfgView.getGamerTag());
            
            let name = SavedData.getData("name:" + platformId);
            print("ON CHANGE!!!! ");
            print(name);
            if let n = name {
                self.lfgView.nameInput.text = n;
            }
        });
        
        
        NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: "getNewData", userInfo: nil, repeats: true);
        
        
        self.gamesList.setUpCommenter();
        
        self.navigationController?.navigationBarHidden = true;
        
    }
    
    
    func getNextPage() {
        if (self.gettingPage || self.showingComments) {
            return;
        }
        self.page++;
        self.gettingPage = true;
        SubmissionService.getGames(self.currentGame, platform: self.currentPlatform, page: self.page, limit: 0, callback: {
            submissions in
            if (submissions.count == 0) {
                self.page--;
            }
            self.gamesList.beginUpdates();
            var start = self.gameListData.count;
            var indexPaths: [NSIndexPath] = [];
            for (var i = 0; i < submissions.count; i++) {
                let num = start + i;
                indexPaths.append(NSIndexPath(forRow: num, inSection: 0));
            }
            if (indexPaths.count > 0) {
                self.gamesList.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Middle);
                self.gameListData += submissions;
            }
            self.gamesList.endUpdates();
            NSTimer.scheduledTimerWithTimeInterval(0.75, target: self, selector: "gettingPageFalse", userInfo: nil, repeats: false);

        });

        
    }
    
    func gettingPageFalse() {
        self.gettingPage = false;
    }
    
    
    func getNewData() {
        
        if (self.showingComments) {
            return;
        }
        
        let game = self.currentGame;
        let platform = self.currentPlatform;
        SubmissionService.getGames(self.currentGame, platform: self.currentPlatform, page: self.page, limit: self.limit * self.page, callback: {
            submissions in
            if (self.currentPlatform != platform || self.currentGame != game) {
                return;
            }
            
            self.updateComments(submissions);
                if (self.gameListData.count == 0) {
                    self.gameListData = submissions;
                    self.gamesList.reloadData();
                } else if (self.gameListData.count > submissions.count) {
                    self.gameListData = submissions;
                    self.gamesList.reloadData();
                } else if (submissions[0].getNameAndGameJoined() != self.gameListData[0].getNameAndGameJoined()) {
                    var numberAdded = 0;
                    var reachedOldData = false;
                    var i = 0;
                    var starting = 0;
                    let oldCount = self.gameListData.count;

                    while (reachedOldData == false) {
                        if (submissions[i].getNameAndGameJoined() != self.gameListData[starting].getNameAndGameJoined()) {
                            numberAdded++;
                            self.gameListData.insert(submissions[i], atIndex: 0);
                            starting++;
                        } else {
                            reachedOldData = true;
                        }
                        
                        i++;
                        if (i == submissions.count) {
                            reachedOldData = true;
                        }
                    }
                    
                    if (numberAdded > 0 || (oldCount + numberAdded == self.gameListData.count)) {
                        self.gamesList.beginUpdates();
                        var indexPaths: [NSIndexPath] = []
                        for (var i = 0; i < numberAdded; i++) {
                            indexPaths.append(NSIndexPath(forRow: i, inSection: 0));
                        }
                        self.gamesList.insertRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Middle);
                        self.gamesList.endUpdates();
                    }
                    
                    
                }
            
        })
        
        
    }
    
    func updateComments(newSubmissions: [Submission]) {
            for (var i = 0; i < self.gameListData.count; i++) {
                for (var p = 0; p < newSubmissions.count; p++) {
                    let old = self.gameListData[i];
                    let new = newSubmissions[p];
                    if old.id == new.id {
                        old.comments = new.comments;
                    }
                }
            }
            
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        self.navigationController?.navigationBarHidden = true;
        
        
        self.getNewData();
        

    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
        self.lfgView.setNeedsUpdateConstraints();
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    func submitIt() {
        
        if (self.mainView.onTop == false) {
            return;
        }
        
        let systemIndex = self.lfgView.getSystemIndex();
        let system: SystemModel = systems[systemIndex];
        let game = lfgView.getGame();
        let name = lfgView.getGamerTag();
        let sitesToShareOn: [SocialSites] = lfgView.getSocialSites();
        let message: String = lfgView.getMessage();
        
        if (game == "" || name == "") {
            
            let _ = SWRMErrorSimple(alertTitle: "NOPE", alertText: "You have to give us your gamertag and the game you want to play");
            return;
        }
        
        
        let submission: Submission = Submission(system: system, username: name, message: message,game: game, timeStamp: NSDate(), isYours: true, id: "", comments: []);
        
        if (self.submitDebounce) {
            return;
        }
        self.submitDebounce = true;

        
        let finishSubmission = {
            self.gamesList.hideCommenter();
            UIView.animateWithDuration(0.2, animations: {
                self.mainView.contentOffset = CGPointMake(0, UIScreen.mainScreen().bounds.height * 0.85);
                }, completion: {
                    done in
                    self.submitDebounce = false;
                    self.gamesList.beginUpdates();
                    self.gamesList.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Top);
                    self.gameListData.insert(submission, atIndex: 0);
                    self.gamesList.endUpdates();
                    self.shareToSocial(submission, sites: sitesToShareOn, callback: {
                        SubmissionService.submitGame(submission, callback: {
                            submission in
                            self.lfgView.clearData();
                            self.mainView.onTop = false;
                            if (self.gameListData[0].message == submission.message) {
                                self.gameListData[0].id = submission.id;
                            }
                        });
                    });
                    
            });
        }
        
        let checkForOldData = {
            if (self.oldData.count > 0) { //remove any filters that are set
                self.setGamesListToHistoryAtIndex(0, callback: {
                    self.oldData = [];
                    UIView.animateWithDuration(0.3, animations: {
                        self.mainView.goBackLink.alpha = 0;
                    });
//                    self.mainView.goBackLink.alpha = 0;
                    finishSubmission();
                });
            } else {
                finishSubmission();
            }
        }
        
        
        
        if (self.showingComments) {
            self.gamesList.hideCommenter();
            self.showingComments = false;
            self.gamesList.reloadData();
            checkForOldData();
        } else {
            checkForOldData();
        }
     
        
        
    }
    
    
    func shareToSocial(submission: Submission, var sites: [SocialSites], callback: (() -> ())) {
        
        if (sites.count == 0) {
            callback();
            return;
        }
        
        if (sites[0] == SocialSites.Twitter) {
            if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
                let vc = SLComposeViewController(forServiceType: SLServiceTypeTwitter);
                vc.setInitialText("Play " + submission.game + " with me(" + submission.username + ")" + " on " + submission.system.title + "!!!!\n\n" + submission.message + "\n\n" + "http://lfger.com/");
                vc.completionHandler = {
                    result in
                    sites.removeAtIndex(0);
                    Background.runInMainThread({
                        self.shareToSocial(submission, sites: sites, callback: callback);
                    });
                }
            self.presentViewController(vc, animated: true, completion: nil);
            } else {
                sites.removeAtIndex(0);
                self.shareToSocial(submission, sites: sites, callback: callback);
                return
            }
        }
        if (sites[0] == SocialSites.Facebook) {
            if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook) {
            let vc = SLComposeViewController(forServiceType: SLServiceTypeFacebook);
                vc.setInitialText("Play " + submission.game + " with me(" + submission.username + ")" + " on " + submission.system.title + "!!!!\n\n" + submission.message + "\n\n" + "http://lfger.com/");
                vc.completionHandler = {
                    result in
                    sites.removeAtIndex(0);
                    Background.runInMainThread({
                    self.shareToSocial(submission, sites: sites, callback: callback);
                    });
                }
            self.presentViewController(vc, animated: true, completion: nil);
            } else {
                sites.removeAtIndex(0);
                self.shareToSocial(submission, sites: sites, callback: callback);
                return
            }
        }
        
            
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (self.showingComments) {
            let tv = UITextView()
            tv.text = self.commentsData[indexPath.row].message;
            tv.font = UIFont.systemFontOfSize(15);
            let size = tv.sizeThatFits(CGSizeMake(UIScreen.mainScreen().bounds.width - Constants.padding * 6, CGFloat.max));
            return Constants.padding * 10 + size.height;
        } else {
        let tv = UITextView()
            tv.text = self.gameListData[indexPath.row].message;
            tv.font = UIFont.systemFontOfSize(15);
            let size = tv.sizeThatFits(CGSizeMake(UIScreen.mainScreen().bounds.width - Constants.padding * 16, CGFloat.max));
            return Constants.padding * 10 + size.height;
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.showingComments == false) {
            return self.gameListData.count;
        } else {
            return self.commentsData.count;
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (self.showingComments == false) {
            return self.getLFGCell(indexPath, tableView: tableView)
        } else {
            return self.getCommentCell(indexPath, tableView: tableView);
        }
        
    }
    
  
    
    
    func getCommentCell(indexPath: NSIndexPath, tableView: UITableView) -> UITableViewCell {
        let cell: MessageCell = tableView.dequeueReusableCellWithIdentifier(MessageCell.REUSE_ID_MESSAGE_CELL) as! MessageCell;
        cell.setItUp(self.commentsData[indexPath.row], visibleIndex: indexPath.row, scrollAmount: tableView.contentOffset.y, onFlag: {
            com in
            if let comment = com as? Comment {
                comment.removeIt();
                for (var i = self.commentsData.count - 1; i > 0; i--) {
                    if (comment.id == self.commentsData[i].id) {
                        self.commentsData.removeAtIndex(i);
                    }
                }
                self.gamesList.reloadData();
            }
            
        })
    
        
        return cell;
    }
    
    
    func getLFGCell(indexPath: NSIndexPath, tableView: UITableView) -> UITableViewCell {
        let cell: GamesListCell = tableView.dequeueReusableCellWithIdentifier(GamesListCell.REUSE_ID) as! GamesListCell;
        
        cell.setItUp(self.gameListData[indexPath.row], visibleIndex: indexPath.row, scrollAmount: tableView.contentOffset.y, onFilter: self.filterData, onFlag: self.flagIt, goToComment: self.goToComments);
        cell.setNeedsUpdateConstraints();
        
        return cell;
    }
    
    
    func flagIt(sub: AnyObject) {
        if let submission = sub as? Submission {
            for (var i = self.gameListData.count - 1; i >= 0; i--) {
                if (self.gameListData[i].id == submission.id) {
                    submission.removeIt();
                    self.gameListData.removeAtIndex(i);
                    self.gamesList.reloadData();
                    return;
                }
            }

        }
    }
    
    
    func goToComments(submission: Submission) {
        self.oldData.append((self.gameListData, self.mainView.getTitleText().string, self.page, self.currentGame, self.currentPlatform));

        self.animateOutCells({
            UIView.animateWithDuration(0.3, animations: {
                self.mainView.goBackLink.alpha = 1;
            });
//            self.mainView.goBackLink.alpha = 1;
            self.commentsData = submission.comments;
            self.submissionShowingCommentFor = submission;
            self.showingComments = true;
            self.gamesList.contentInset = UIEdgeInsetsMake(0, 0, Constants.commenterViewHeight, 0);
            self.gamesList.reloadData();
            self.mainView.setTitleAttrText("@" + submission.username);
            
            let platformId = submission.system.getPlatformId()
            var name = SavedData.getData("name:" + platformId);
            if (name == nil) {
                name = "";
            }
            if (name == "" || name?.stringByReplacingOccurrencesOfString(" ", withString: "") == "") {
                name = "";
            }
            self.gamesList.showCommenter(name!);
            self.gamesList.commenterView.sendComment = self.submitComment;
        });
    }
    
    func submitComment(var username: String, message: String) {
        if (username == "Your Username/PSN/Gamertag" || username.stringByReplacingOccurrencesOfString(" ", withString: "") == "") {
            username = "anonymous";
        }
        
        if (message == self.gamesList.commenterView.messagePlaceholder || message.stringByReplacingOccurrencesOfString(" ", withString: "") == "") {
            let _ = SWRMErrorSimple(alertTitle: "NOPE", alertText: "You need to write a message!");
            return;
        }
        
        SubmissionService.sendComment(self.submissionShowingCommentFor.id, username: username, message: message, callback: {
            //do something
        });
        let comment = Comment(message: message, username: username, id: "", timeStamp: NSDate(), lfgId: self.submissionShowingCommentFor.id);
        self.commentsData.append(comment);
        self.gamesList.reloadData();
        self.gamesList.scrollToRowAtIndexPath(NSIndexPath(forRow: self.commentsData.count - 1, inSection: 0), atScrollPosition: .Bottom, animated: true);
    }
    
    func filterData(game: String, platform: String, submissions: [Submission], text: String) {
        self.oldData.append((self.gameListData, self.mainView.getTitleText().string, self.page, self.currentGame, self.currentPlatform));
        self.currentGame = game;
        self.currentPlatform = platform;
        self.animateOutCells({
            self.page = 0;
            UIView.animateWithDuration(0.3, animations: {
                self.mainView.goBackLink.alpha = 1;
            });
//            self.mainView.goBackLink.alpha = 1;
            self.gameListData = submissions;
            self.gamesList.reloadData();
            self.mainView.setTitleAttrText(text);
//            self.animateCellsIn();
        });
        
        
    }
    
    func animateOutCells(callback: (() -> ())) {
        var cells: [GamesListCell] = self.gamesList.visibleCells as! [GamesListCell];
        cells = self.sortCells(cells);
        
        for (var i = 0; i < cells.count; i++) {
            if (i == cells.count - 1) {
                UIView.animateWithDuration(0.15 * Double(i), animations: {
                    cells[i].alpha = 0;
                    }, completion: {
                        done in
                        self.gamesList.setContentOffset(CGPoint(x: 0,y: 0), animated: false);
                        callback()
                });
            } else {
            UIView.animateWithDuration(0.15 * Double(i), animations: {
                cells[i].alpha = 0;
            });
            }
        }
        
        if (cells.count == 0) {
            callback();
        }
    }
    
    func sortCells(cells: [GamesListCell]) -> [GamesListCell] {
        var newArray: [GamesListCell] = [];
        
        for (var i = 0; i < cells.count; i++) {
            if (newArray.count == 0) {
                newArray.append(cells[i]);
            } else {
                var added = false;
                for (var p = 0; p < newArray.count; p++) {
                    if (cells[i].visibleIndex < newArray[p].visibleIndex && added == false) {
                        newArray.insert(cells[i], atIndex: p);
                        added = true;
                    }
                }
                if (added == false) {
                    newArray.append(cells[i]);
                }
            }
        }
        
        return newArray;
    }
    
    
    func animateCellsIn() {
        var cells: [GamesListCell] = self.gamesList.visibleCells as! [GamesListCell];
        cells = self.sortCells(cells);
        
        for (var i = 0; i < cells.count; i++) {
            if (i == cells.count - 1) {
                cells[i].alpha = 0;
                UIView.animateWithDuration(0.25 * Double(i), animations: {
                    cells[i].alpha = 1;
                    }, completion: {
                        done in

                });
            } else {
                
                UIView.animateWithDuration(0.25 * Double(i), animations: {
                    cells[i].alpha = 1;
                });
            
            
            }
        }
        
        

    }
    
    func scrollViewWillBeginDecelerating(scrollView: UIScrollView) {
        
       // self.getNewData();
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (scrollView.contentOffset.y > scrollView.contentSize.height * 0.75) {
            self.getNextPage();
        }
    }
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        if (scrollView != self.mainView) {
            return;
        }
        
        
        
        if (velocity.y < 0) {
            targetContentOffset.memory.y = 0;
            self.mainView.onTop = true;
        } else if (velocity.y > 0) {
            targetContentOffset.memory.y = UIScreen.mainScreen().bounds.height
            self.mainView.onTop = false;
            if (self.showingComments == false) {
                self.gamesList.hideCommenter();
            }
        } else {
        
        
        if (targetContentOffset.memory.y > UIScreen.mainScreen().bounds.height / 2) {
            targetContentOffset.memory.y = UIScreen.mainScreen().bounds.height
            self.mainView.onTop = false;
            if (self.showingComments == false) {
                self.gamesList.hideCommenter();
            }
        } else {
            targetContentOffset.memory.y = 0;
            self.mainView.onTop = true;
        }
        
        }
        
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent;
    }
    
}




class BaseView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        didLoad()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        didLoad()
    }
    
    func didLoad() {
        //Place your initialization code here
    }
    
}


class Commenter: BaseView, UITextViewDelegate, UITextFieldDelegate {
    
    var input: FancyTextView = FancyTextView();
    var usernameInput: FancyTextField = FancyTextField();
    var submit: UIButton = UIButton();
    var messagePlaceholder: String = "Your Message..."
    var namePlaceholder: String = "Anonymous";
    var sendComment: ((String, String) -> ())?
    
    
    
    override func didLoad() {
        super.didLoad();
        
        self.layer.shadowColor = Constants.darkBackgroundColor.CGColor;
        self.layer.shadowRadius = 3;
        self.layer.shadowOffset = CGSizeMake(0, -3);
        self.layer.shadowOpacity = 1;
        self.clipsToBounds = false;
        self.layer.masksToBounds = false;
        self.addSubview(self.input);
        self.addSubview(self.usernameInput);
        self.addSubview(self.submit);
        
        self.usernameInput.delegate = self;
        self.input.delegate = self;
        self.input.setUpGradients();
        self.usernameInput.setUpGradients();
        
        self.usernameInput.text = self.namePlaceholder;
        self.input.text = self.messagePlaceholder;
        self.submit.setTitle("Submit", forState: .Normal);
        self.submit.setTitleColor(Constants.darkBackgroundColor, forState: .Normal);
        self.submit.addTarget(self, action: "sendIt", forControlEvents: UIControlEvents.TouchUpInside);
        
        self.backgroundColor = Constants.lightBackgroundColor;
        
        
        
    }
    
    func sendIt() {
        self.sendComment?(self.usernameInput.text!, self.input.text!);
        self.input.text = self.messagePlaceholder;
        self.input.endEditing(true);
        self.usernameInput.endEditing(true);
    }
    
    
    override func updateConstraints() {
        
        self.input.snp_remakeConstraints(closure: {
            make in
            make.bottom.equalTo(self).offset(-Constants.padding);
            make.left.equalTo(self).offset(Constants.padding);
            make.width.equalTo(UIScreen.mainScreen().bounds.width * 0.7);
            make.height.equalTo(75);
        })
        
        
        self.usernameInput.snp_remakeConstraints(closure: {
            make in
            make.bottom.equalTo(self.input.snp_top).offset(-Constants.padding);
            make.left.equalTo(self).offset(Constants.padding);
            make.width.equalTo(input.snp_width);
            make.height.equalTo(35);
        })
        
        self.submit.snp_remakeConstraints(closure: {
            make in
            make.right.equalTo(self).offset(Constants.padding * -1);
            make.width.equalTo(UIScreen.mainScreen().bounds.width * 0.25);
            make.height.equalTo(self.input);
            make.top.equalTo(self.input);
        })
        
        super.updateConstraints();
    }
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let offset = scrollView.contentOffset;
        self.input.gradients.transform = CGAffineTransformMakeTranslation(0, offset.y);
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        let textF: FancyTextView = textView as! FancyTextView;
        textF.setEditingView();
        if (textView.text == self.messagePlaceholder) {
            textView.text = "";
        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        print(text);
        if (textView.text.characters.count > 150 && text != "") {
            if (text == "\n") {
                textView.resignFirstResponder();
            }
            return false;
        } else {
            if (text == "\n") {
                textView.resignFirstResponder();
                return false;
            }
            return true;
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        let textF: FancyTextView = textView as! FancyTextView;
        textF.endEditingView();
        if (textView.text == "") {
            textView.text = self.messagePlaceholder;
        }
    }
    
    
    func textFieldDidBeginEditing(textField: UITextField) {
        let textF: FancyTextField = textField as! FancyTextField;
        textF.setEditingView();
        textField.text = "";
        
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if (textField.text == "") {
            
            textField.text = self.namePlaceholder;
            
        }
        
        
        
        
        let textF: FancyTextField = textField as! FancyTextField;
        textF.endEditingView();
    }
    

    
}
    

class GamesListView: UITableView {
    
    var commenterView: Commenter = Commenter();
    var commenterBottomOffset: CGFloat = 0;
    var isCommenting: Bool = false;
    
    func hideCommenter() {
        self.isCommenting = false;
        self.commenterView.input.endEditing(true);
        self.commenterView.usernameInput.endEditing(true);
        UIView.animateWithDuration(0.3, animations: {
            let transform: CGAffineTransform = CGAffineTransformMakeTranslation(0, Constants.commenterViewHeight + 10);
            self.commenterView.transform = transform;
        })
    }
    
    func showCommenter(username: String) {
        self.isCommenting = true;
        self.commenterView.namePlaceholder = username;
        if username == "" {
            self.commenterView.namePlaceholder = "Your Username/PSN/Gamertag";
        }
        self.commenterView.usernameInput.text = self.commenterView.namePlaceholder;
        UIView.animateWithDuration(0.3, animations: {
            let transform: CGAffineTransform = CGAffineTransformMakeTranslation(0, 0);
            self.commenterView.transform = transform;
        })
    }
    
    func setUpCommenter() {
        self.addSubview(self.commenterView);
        self.hideCommenter();
        self.setNeedsUpdateConstraints();
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardChange:", name: UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardHide", name: UIKeyboardWillHideNotification, object: nil);

    }
    
    
    func keyboardHide() {
        if (self.isCommenting == false) {
            return;
        }
        self.commenterBottomOffset = 0;
        UIView.animateWithDuration(0.3, animations: {
            let transform: CGAffineTransform = CGAffineTransformMakeTranslation(0, self.commenterBottomOffset);
            self.commenterView.transform = transform;
        })
    }
    
    func keyboardChange(notification: NSNotification) {
        if (self.isCommenting == false) {
            return;
        }
        if let userInfo = notification.userInfo {
            if let keyboardSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                let height = keyboardSize.height;
                self.commenterBottomOffset = -1 * height;
                self.setNeedsUpdateConstraints();
                
                UIView.animateWithDuration(0.3, animations: {
                    let transform: CGAffineTransform = CGAffineTransformMakeTranslation(0, self.commenterBottomOffset);
                    self.commenterView.transform = transform;
                })
            }
            
        }
      
    }
    
    override func updateConstraints() {
        if (self.commenterView.superview != nil) {
                self.commenterView.snp_remakeConstraints(closure: {
                    make in
                    make.bottom.equalTo(self.superview!.snp_bottom).offset(0);
                    make.left.equalTo(self)
                    make.right.equalTo(self);
                    make.height.equalTo(Constants.commenterViewHeight);
                    make.width.equalTo(UIScreen.mainScreen().bounds.width);
                })
            
       
        }
        
        super.updateConstraints();
    }
    
 
}