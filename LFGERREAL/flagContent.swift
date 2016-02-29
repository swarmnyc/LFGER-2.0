//
//  flagContent.swift
//  LFGER
//
//  Created by Alex Hartwell on 2/27/16.
//  Copyright © 2016 SWARM. All rights reserved.
//

import Foundation
import UIKit


class CommentCountView: BaseView {
    
    var commentImageView: UIImageView = UIImageView(image: UIImage(named: "comment")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate));
    var countLabel: UILabel = UILabel();
    var callback: (() -> ())?
    
    override func didLoad() {
        super.didLoad();
        
        self.addSubview(self.commentImageView);
        self.addSubview(self.countLabel);
        
        self.commentImageView.userInteractionEnabled = true;
        self.commentImageView.tintColor = Constants.tanColor;
        
        self.countLabel.textAlignment = NSTextAlignment.Center;
        self.countLabel.textColor = Constants.tanColor;
        self.countLabel.font = UIFont.systemFontOfSize(10);
        
        var tap: UITapGestureRecognizer = UITapGestureRecognizer();
        self.addGestureRecognizer(tap);
        tap.addTarget(self, action: "touched");
        
    }
    
    func touched() {
        self.callback?();
    }
    
    func setCount(count: Int) {
        self.countLabel.text = count.description;
    }
    
    override func updateConstraints() {
        
        self.commentImageView.snp_makeConstraints(closure: {
            make in
            make.edges.equalTo(self).inset(Constants.padding);
        })
        
        self.countLabel.snp_makeConstraints(closure: {
            make in
            make.left.equalTo(self.commentImageView);
            make.right.equalTo(self.commentImageView);
            make.top.equalTo(self.snp_centerY).offset(-Constants.padding * 0.75);
            make.height.equalTo(Constants.padding);
        })
        
        
        super.updateConstraints();
    }
    
    
}


class FlagContent: BaseView {
    
    var flagImageView: UIImageView = UIImageView(image: UIImage(named: "flag")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate));
    var flagLabel: UILabel = UILabel();
    var callback: (() -> ())?
    
    override func didLoad() {
        super.didLoad();
        self.addSubview(self.flagImageView);
        self.addSubview(self.flagLabel);
        
        self.flagImageView.contentMode = UIViewContentMode.ScaleAspectFit;
        self.flagImageView.userInteractionEnabled = true;
        self.flagImageView.tintColor = Constants.redColor;
    
        
        self.flagLabel.text = "Report";
        self.flagLabel.font = UIFont.systemFontOfSize(12);
        self.flagLabel.textAlignment = NSTextAlignment.Center;
        self.flagLabel.textColor = Constants.redColor;
        
        
    }
    
    
    func setUpTouchCallback(callback: (() -> ())) {
        var tap: UITapGestureRecognizer = UITapGestureRecognizer();
        tap.addTarget(self, action: "tapIt");
        self.addGestureRecognizer(tap);
        self.callback = callback;
    }
    
    func tapIt() {
        callback?();
    }
    
    override func updateConstraints() {
        super.updateConstraints();
        
        self.flagImageView.snp_makeConstraints(closure: {
            make in
            make.left.equalTo(self);
            make.right.equalTo(self);
            make.top.equalTo(self);
            make.bottom.equalTo(self).offset(-Constants.flagHeight * 0.33);
        })
        self.flagLabel.snp_makeConstraints(closure: {
            make in
            make.left.equalTo(self);
            make.right.equalTo(self);
            make.top.equalTo(self.flagImageView.snp_bottom);
            make.bottom.equalTo(self).offset(0);
        })
        
        
        
        
    }
    
    
}