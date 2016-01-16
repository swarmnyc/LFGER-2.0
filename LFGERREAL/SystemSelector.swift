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
    
    var title: UILabel = UILabel();
    var systemButtons: [SystemButton] = [];
    var selectedIndex: Int = 0;
    
    convenience init(systems: [SystemModel]) {
        self.init();
        
        self.title.text = "System";
        self.title.clipsToBounds = false;
        self.title.textColor = UIColor.blackColor();
        for (var i = 0; i < systems.count; i++) {
            let button = SystemButton();
            button.index = i;
            button.setTitle(systems[i].title, forState: .Normal);
            button.setTitleColor(UIColor.blackColor(), forState: .Normal);
            button.addTarget(self, action: "systemPress:", forControlEvents: .TouchUpInside);
            button.clipsToBounds = false;
            button.deselectButton();
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
    }
    
    
    override func didLoad() {
        super.didLoad();
        
        self.addSubview(self.title);
        for (var i = 0; i < self.systemButtons.count; i++) {
            self.addSubview(self.systemButtons[i]);
        }
        
        
    }
    
    
    override func layoutSubviews() {
        
        self.title.snp_remakeConstraints {
            make in
            make.left.equalTo(self).offset(Constants.padding);
            make.right.equalTo(self).offset(Constants.padding * -1);
            make.top.equalTo(self).offset(Constants.padding);
            make.height.equalTo(Constants.padding * 3);
        }
        
        
        for (var i = 0; i < self.systemButtons.count; i++) {
            if (i == 0) {
                self.systemButtons[i].snp_remakeConstraints(closure: {
                    make in
                    make.left.equalTo(self).offset(Constants.padding)
                    make.right.equalTo(self.systemButtons[i + 1].snp_left).offset(Constants.padding * -1);
                    make.top.equalTo(self.title.snp_bottom).offset(Constants.padding);
                    make.height.equalTo(Constants.padding * 3);
                    make.width.equalTo(self.systemButtons[i + 1]);
                })
            } else if ( i == self.systemButtons.count - 1) {
                self.systemButtons[i].snp_remakeConstraints(closure: {
                    make in
                    make.left.equalTo(self.systemButtons[i - 1].snp_right).offset(Constants.padding)
                    make.right.equalTo(self).offset(Constants.padding * -1);
                    make.top.equalTo(self.title.snp_bottom).offset(Constants.padding);
                    make.height.equalTo(Constants.padding * 3);
                    make.width.equalTo(self.systemButtons[i - 1]);
                })
            } else {
                self.systemButtons[i].snp_remakeConstraints(closure: {
                    make in
                    make.left.equalTo(self.systemButtons[i - 1].snp_right).offset(Constants.padding)
                    make.right.equalTo(self.systemButtons[i + 1].snp_left).offset(Constants.padding * -1);
                    make.top.equalTo(self.title.snp_bottom).offset(Constants.padding);
                    make.height.equalTo(Constants.padding * 3);
                    make.width.equalTo(self.systemButtons[i - 1]);
                })
            }
            
            
        }
        
        super.layoutSubviews();
    }
    
    
    
}