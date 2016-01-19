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
    var oldData: [([Submission], String)] = [];
    override func loadView() {
        super.loadView();
        self.view = self.mainView;
        self.mainView.goToSettingsFunc({
           self.navigationController?.pushViewController(SettingsViewController(), animated: true);
        });
        self.mainView.goBackFunc({
            if (self.oldData.count > 0) {
                self.gameListData = self.oldData[self.oldData.count - 1].0;
                self.animateOutCells({
                    self.gamesList.reloadData();
                    self.mainView.setTitleAttrText(self.oldData[self.oldData.count - 1].1)
                    self.oldData.removeAtIndex(self.oldData.count - 1);
                    if (self.oldData.count == 0) {
                        self.mainView.goBackLink.alpha = 0;
                    }
                });
                
            }
            
        })
        
        
        
        
        self.gamesList.registerClass(GamesListCell.self, forCellReuseIdentifier: GamesListCell.REUSE_ID);
        self.gamesList.backgroundColor = UIColor.clearColor();
        self.gamesList.dataSource = self;
        self.gamesList.delegate = self;
        self.gamesList.separatorStyle = UITableViewCellSeparatorStyle.None;
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
        
        
        self.navigationController?.navigationBarHidden = true;
        
    }
    
    
    func getNewData() {
        SubmissionService.getGames("", platform: "", callback: {
            submissions in
            if (self.oldData.count == 0) {
                
                
                if (self.gameListData.count == 0) {
                    self.gameListData = submissions;
                    self.gamesList.reloadData();
                } else if (submissions[0].getNameAndGameJoined() != self.gameListData[0].getNameAndGameJoined()) {
                    var numberAdded = 0;
                    var reachedOldData = false;
                    var i = 0;
                    var starting = 0;
                    while (reachedOldData == false) {
                        if (submissions[i].getNameAndGameJoined() != self.gameListData[starting].getNameAndGameJoined()) {
                            numberAdded++;
                            self.gameListData.insert(submissions[i], atIndex: 0);
                            starting++;
                        } else {
                            reachedOldData = true;
                        }
                        
                        i++;
                        if (i == numberAdded) {
                            reachedOldData = true;
                        }
                    }
                    
                    self.gamesList.beginUpdates();
                    var indexPaths: [NSIndexPath] = []
                    for (var i = 0; i < numberAdded; i++) {
                        indexPaths.append(NSIndexPath(forRow: i, inSection: 0));
                    }
                    self.gamesList.insertRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Middle);
                    
                    self.gameListData = submissions;
                    self.gamesList.endUpdates();
                }
            } else {
                self.oldData[0].0 = submissions;
            }
        })
        
        
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
        
        
        let submission: Submission = Submission(system: system, username: name, message: message,game: game, timeStamp: NSDate(), isYours: true, id: "");
        if (self.oldData.count > 0) {
            self.gameListData = self.oldData[0].0;
            self.title = self.oldData[0].1;
            self.oldData = [];
        }
        self.gameListData.insert(submission, atIndex: 0);
        submission.sendToServer();
        self.gamesList.reloadData();
        self.shareToSocial(submission, sites: sitesToShareOn, callback: {
            SubmissionService.submitGame(submission, callback: {
                submission in
                self.lfgView.clearData();
                self.mainView.setContentOffset(CGPointMake(0, UIScreen.mainScreen().bounds.height * 0.85), animated: true);
                self.mainView.onTop = false;
                
            })
        });
        
        
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
        let tv = UITextView()
        tv.text = self.gameListData[indexPath.row].message;
        tv.font = UIFont.systemFontOfSize(15);
        let size = tv.sizeThatFits(CGSizeMake(UIScreen.mainScreen().bounds.width - Constants.padding * 15, CGFloat.max));
        return Constants.padding * 7 + size.height;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.gameListData.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell: GamesListCell = tableView.dequeueReusableCellWithIdentifier(GamesListCell.REUSE_ID) as! GamesListCell;
        
        cell.setItUp(self.gameListData[indexPath.row], visibleIndex: indexPath.row, scrollAmount: tableView.contentOffset.y, onFilter: {
            submissions, text in
            self.filterData(submissions, text: text);
            
            }, onFlag: {
                submission in
                for (var i = self.gameListData.count - 1; i >= 0; i--) {
                    if (self.gameListData[i].id == submission.id) {
                        submission.removeIt();
                        self.gameListData.removeAtIndex(i);
                        self.gamesList.reloadData();
                        return;
                    }
                }
        });
        cell.setNeedsUpdateConstraints();
        
        return cell;
    }
    
    
    
    
    func filterData(submissions: [Submission], text: String) {
        self.oldData.append((self.gameListData, self.mainView.getTitleText().string));
        
        self.animateOutCells({
            self.mainView.goBackLink.alpha = 1;
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
        self.getNewData();
    }
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        if (scrollView != self.mainView) {
            return;
        }
        
        
        if (targetContentOffset.memory.y > UIScreen.mainScreen().bounds.height / 2) {
            targetContentOffset.memory.y = UIScreen.mainScreen().bounds.height
            self.mainView.onTop = false;
        } else {
            targetContentOffset.memory.y = 0;
            self.mainView.onTop = true;
        }
        
        
        
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
    

class GamesListView: UITableView {
    
   
    
    override func updateConstraints() {
        

        
        super.updateConstraints();
    }
    
 
}