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
    var systems: [SystemModel] = [SystemModel(type: System.PC),SystemModel(type: System.PS4),SystemModel(type: System.XBOXONE)];
    var mainView: MainView = MainView();
    var lfgView: LFGView = LFGView();
    var gamesList: GamesListView = GamesListView();
    
    var gameListData: [Submission] = [];
    
    
    override func loadView() {
        super.loadView();
        self.view = self.mainView;
        self.mainView.goToSettingsFunc({
           self.navigationController?.pushViewController(SettingsViewController(), animated: true);
        });
        
        
        self.gamesList.registerClass(GamesListCell.self, forCellReuseIdentifier: GamesListCell.REUSE_ID);
        self.gamesList.backgroundColor = UIColor.whiteColor();
        self.gamesList.dataSource = self;
        self.gamesList.delegate = self;
        
        self.mainView.setItUp(self.lfgView, bottomView: self.gamesList);
        self.mainView.delegate = self;
        self.lfgView.setUpSystems(systems);
        
        
        self.navigationController?.navigationBarHidden = true;
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        self.navigationController?.navigationBarHidden = true;

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
        
        
        let submission: Submission = Submission(system: system, username: name, message: message,game: game, timeStamp: NSDate(), isYours: true, removeCallback: {
            submission in
            for (var i = self.gameListData.count - 1; i >= 0; i--) {
                if (self.gameListData[i].id == submission.id) {
                    self.gameListData.removeAtIndex(i);
                }
            }
            
            self.gamesList.reloadData();
            
            
        });
        self.gameListData.append(submission);
        submission.sendToServer();
        self.gamesList.reloadData();
        self.shareToSocial(sitesToShareOn, callback: {
            
            
            self.mainView.setContentOffset(CGPointMake(0, UIScreen.mainScreen().bounds.height), animated: true);
        });
        
        
    }
    
    
    func shareToSocial(var sites: [SocialSites], callback: (() -> ())) {
        
        if (sites.count == 0) {
            callback();
            return;
        }
        
        if (sites[0] == SocialSites.Twitter) {
            if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
                let vc = SLComposeViewController(forServiceType: SLServiceTypeTwitter);
                vc.completionHandler = {
                    result in
                    sites.removeAtIndex(0);
                    Background.runInMainThread({
                    self.shareToSocial(sites, callback: callback);
                    });
                }
            self.presentViewController(vc, animated: true, completion: nil);
            } else {
                sites.removeAtIndex(0);
                self.shareToSocial(sites, callback: callback);
                return
            }
        }
        if (sites[0] == SocialSites.Facebook) {
            if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook) {
            let vc = SLComposeViewController(forServiceType: SLServiceTypeFacebook);
                vc.completionHandler = {
                    result in
                    sites.removeAtIndex(0);
                    Background.runInMainThread({
                    self.shareToSocial(sites, callback: callback);
                    });
                }
            self.presentViewController(vc, animated: true, completion: nil);
            } else {
                sites.removeAtIndex(0);
                self.shareToSocial(sites, callback: callback);
                return
            }
        }
        
            
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 120;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.gameListData.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: GamesListCell = tableView.dequeueReusableCellWithIdentifier(GamesListCell.REUSE_ID) as! GamesListCell;
        cell.contentView.layer.borderWidth = 2;
        cell.contentView.layer.borderColor = UIColor.blackColor().CGColor;
        cell.setItUp(self.gameListData[indexPath.row]);
        cell.setNeedsUpdateConstraints();
        
        return cell;
    }
    
    
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        if (scrollView != self.mainView) {
            return;
        }
        
        
        if (targetContentOffset.memory.y > UIScreen.mainScreen().bounds.height / 2) {
            targetContentOffset.memory.y = UIScreen.mainScreen().bounds.height
        } else {
            targetContentOffset.memory.y = 0;
        }
        
        
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

    
    
 
}