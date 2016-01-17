//
//  SystemSelector.swift
//  LFGER
//
//  Created by Alex Hartwell on 1/16/16.
//  Copyright © 2016 SWARM. All rights reserved.
//

import Foundation
import UIKit


class SystemSelect: BaseView {
    
    var systemButtons: [SystemButton] = [];
    var selectedIndex: Int = 0;
    var background: UIImageView = UIImageView(image: UIImage(named: "systemBtn")!);
    
    convenience init(systems: [SystemModel]) {
        self.init();
        
        
        self.background.contentMode = UIViewContentMode.ScaleAspectFit;
        self.clipsToBounds = false;
        for (var i = 0; i < systems.count; i++) {
            let button = SystemButton();
            button.index = i;
            button.setEmbossedText(systems[i].title, color: UIColor(red: 0.408, green: 0.380, blue: 0.380, alpha: 1.00));
            button.setTitleColor(UIColor.blackColor(), forState: .Normal);
            button.addTarget(self, action: "systemPress:", forControlEvents: .TouchUpInside);
            button.clipsToBounds = false;
            button.setPosition();
            button.deselectButton();
            button.setUpView();
            self.systemButtons.append(button);
        }
        
        self.systemButtons[0].selectButton();
        
        self.didLoad();
        
    }
    
    func systemPress(sender: UIButton) {
        let sysButton: SystemButton? = sender as? SystemButton;
        if let b = sysButton {
            print("button " + b.index.description + " selected");
            for (var i = 0; i < self.systemButtons.count; i++) {
                if (i == b.index) {
                    self.systemButtons[i].selectButton();
                } else {
                    self.systemButtons[i].deselectButton();
                }
            }
            
        }
        UIApplication.sharedApplication().sendAction("resignFirstResponder", to:nil, from:nil, forEvent:nil)

    }
    
    
    override func didLoad() {
        super.didLoad();
        
        if (self.systemButtons.count == 0) {
            return;
        }
        
        self.addSubview(self.background);
        for (var i = 0; i < self.systemButtons.count; i++) {
            self.addSubview(self.systemButtons[i]);
        }
        
        
    }
    
    
    override func layoutSubviews() {
        
        self.background.snp_remakeConstraints(closure: {
            make in
            make.edges.equalTo(self);
        })
        
        for (var i = 0; i < self.systemButtons.count; i++) {
            if (i == 0) {
                self.systemButtons[i].snp_remakeConstraints(closure: {
                    make in
                    make.left.equalTo(self).offset(Constants.padding)
                    make.right.equalTo(self.systemButtons[i + 1].snp_left).offset(Constants.padding * -1);
                    make.top.equalTo(self.background).offset(-Constants.padding * 4);
                    make.bottom.equalTo(self.background);
                })
            } else if ( i == self.systemButtons.count - 1) {
                self.systemButtons[i].snp_remakeConstraints(closure: {
                    make in
                    make.left.equalTo(self.systemButtons[i - 1].snp_right).offset(Constants.padding)
                    make.right.equalTo(self).offset(Constants.padding * -1);
                    make.top.equalTo(self.background).offset(-Constants.padding * 4);
                    make.bottom.equalTo(self.background);
                    make.width.equalTo(self.systemButtons[i - 1]);
                })
            } else {
                self.systemButtons[i].snp_remakeConstraints(closure: {
                    make in
                    make.left.equalTo(self.systemButtons[i - 1].snp_right).offset(Constants.padding)
                    make.right.equalTo(self.systemButtons[i + 1].snp_left).offset(Constants.padding * -1);
                    make.top.equalTo(self.background).offset(-Constants.padding * 4);
                    make.bottom.equalTo(self.background);
                    make.width.equalTo(self.systemButtons[i - 1]);
                })
            }
            
            
        }
        
        super.layoutSubviews();
    }
    
    
    
}