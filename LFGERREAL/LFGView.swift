//
//  LFGView.swift
//  LFGER
//
//  Created by Alex Hartwell on 1/16/16.
//  Copyright © 2016 SWARM. All rights reserved.
//

import Foundation
import UIKit
import YIInnerShadowView



class FancyTextField: UITextField {
    var gradients: YIInnerShadowView = YIInnerShadowView();

    func setUpGradients() {
        self.addSubview(self.gradients);
        self.font = UIFont.systemFontOfSize(15);
        self.textColor = UIColor(red: 0.365, green: 0.337, blue: 0.337, alpha: 1.00);
       self.endEditingView()
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews();
        
    }
    
    override func updateConstraints() {
            gradients.snp_remakeConstraints(closure: {
                make in
                make.edges.equalTo(self).inset(-1);
            })
        
        super.updateConstraints();
    }
    
    func setEditingView() {
        self.backgroundColor = UIColor(red: 0.686, green: 0.686, blue: 0.678, alpha: 1.00);
        self.gradients.shadowColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.00);
        self.gradients.shadowRadius = 6;
        self.gradients.shadowMask = YIInnerShadowMaskAll;
        self.gradients.shadowOpacity = 1;
    }
    
    func endEditingView() {
        self.backgroundColor = UIColor.clearColor();
        self.gradients.shadowColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.00);
        self.gradients.shadowRadius = 3;
        self.gradients.shadowMask = YIInnerShadowMaskAll;
        self.gradients.shadowOpacity = 1;
    }
    
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, Constants.padding, Constants.padding);
    }
    
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, Constants.padding, Constants.padding);

    }
    
    
}


class UILFGButton: UIButton {
    
    var noTouch: UIView = UIView();
    
    func setUpSelectionView() {
        
        self.addSubview(self.noTouch);
        self.noTouch.userInteractionEnabled = false;
        self.noTouch.snp_remakeConstraints(closure: {
            make in
            make.bottom.equalTo(self.imageView!);
            make.left.equalTo(self.imageView!);
            make.right.equalTo(self.imageView!);
            make.top.equalTo(self.imageView!.snp_centerY);
        })
        
        self.bringSubviewToFront(self.noTouch);
        
    }
    
    
}


class FancyTextView: UITextView {
    var gradients: YIInnerShadowView = YIInnerShadowView();
    
    func setUpGradients() {
        self.addSubview(self.gradients);
        self.textContainerInset = UIEdgeInsetsMake(Constants.padding, Constants.padding - 3, Constants.padding, Constants.padding - 2);

        self.textColor = UIColor(red: 0.365, green: 0.337, blue: 0.337, alpha: 1.00);
        self.font = UIFont.systemFontOfSize(15);
        self.endEditingView()
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews();
        
    }
    
    override func updateConstraints() {
        gradients.snp_remakeConstraints(closure: {
            make in
            make.top.equalTo(self).offset(-1);
            make.left.equalTo(self).offset(-1);
            make.height.equalTo(self.snp_height).offset(2);
            make.width.equalTo(self.snp_width).offset(2);
        })
        
        super.updateConstraints();
    }
    
    func setEditingView() {
        self.backgroundColor = UIColor(red: 0.686, green: 0.686, blue: 0.678, alpha: 1.00);
        self.gradients.shadowColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.00);
        self.gradients.shadowRadius = 6;
        self.gradients.shadowMask = YIInnerShadowMaskAll;
        self.gradients.shadowOpacity = 1;
    }
    
    func endEditingView() {
        self.backgroundColor = UIColor.clearColor();
        self.gradients.shadowColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.00);
        self.gradients.shadowRadius = 3;
        self.gradients.shadowMask = YIInnerShadowMaskAll;
        self.gradients.shadowOpacity = 1;
    }
    
    
    
}

class LFGView: BaseView, UITextFieldDelegate, UITextViewDelegate {
    
    var systemSelect: SystemSelect?
    var LFGButton: UILFGButton = UILFGButton();
    var gameInput: FancyTextField = FancyTextField();
    var nameInput: FancyTextField = FancyTextField();
    var message: FancyTextView = FancyTextView();
    
    var shareStrip: SocialShareStrip = SocialShareStrip();
    
    var namePlaceholder: String = "Username/PSN/GamerTag";
    var gamePlaceholder: String = "Game";
    var messagePlaceholder: String = "Let people know what's what";
    
    
    func setUpSystems(systems: [SystemModel], onChange: ((String, Int) -> ())) {
        

        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = UIScreen.mainScreen().bounds
        gradient.colors = [UIColor(red: 247/255.0, green: 247/255.0, blue: 247/255.0, alpha: 255).CGColor, UIColor(red: 208/255.0, green: 207/255.0, blue: 206/255.0, alpha: 255).CGColor]
        self.layer.insertSublayer(gradient, atIndex: 0)
        
        self.systemSelect = SystemSelect(systems: systems, onChange: onChange);
        self.addSubview(self.systemSelect!);
        
        
        
        self.gameInput.text = self.gamePlaceholder;
        self.gameInput.delegate = self;
        self.gameInput.setUpGradients();
        self.nameInput.text = self.namePlaceholder;
        
        let name = SavedData.getData("name:" + systems[0].getPlatformId());
        if let n = name {
            self.nameInput.text = n;
        }
        
        
        self.nameInput.delegate = self;
        self.nameInput.setUpGradients();
        self.gameInput.enabled = true;
        self.nameInput.enabled = true;
        self.setNeedsUpdateConstraints();
    }
    
    
    override func didLoad() {
        super.didLoad();
        
        
        self.LFGButton.setImage(UIImage(named: "lfg"), forState: UIControlState.Normal);
        self.LFGButton.setImage(UIImage(named: "lfgPressed"), forState: UIControlState.Highlighted);
        self.LFGButton.imageView!.contentMode = UIViewContentMode.ScaleAspectFit
        self.LFGButton.clipsToBounds = false;
        self.LFGButton.layer.masksToBounds = false;
        self.LFGButton.addTarget(nil, action: "submitIt", forControlEvents: .TouchUpInside);
        self.LFGButton.setUpSelectionView();
        
        self.message.text = self.messagePlaceholder;
        self.message.delegate = self;
        self.message.setUpGradients();
        
        
        self.addSubview(self.gameInput);
        self.addSubview(self.nameInput);
        self.addSubview(self.message);
        self.addSubview(self.shareStrip);
        self.addSubview(self.LFGButton);
    
        
    }
    
    func getSocialSites() -> [SocialSites] {
        var returnSites: [SocialSites] = [];
        if (self.shareStrip.facebook.selected) {
            returnSites.append(SocialSites.Facebook);
        }
        
        if (self.shareStrip.twitter.selected) {
            returnSites.append(SocialSites.Twitter);
        }
        
        return returnSites;
    }
    
    func getMessage() -> String {
        if (self.message.text == self.messagePlaceholder) {
            return "";
        } else {
            return self.message.text;
        }
    }
    
    func clearData() {
        self.message.text = self.messagePlaceholder;
        self.gameInput.text = self.gamePlaceholder;
    }
    
    override func layoutSubviews() {
        
        self.systemSelect?.snp_remakeConstraints(closure: {
            make in
            make.top.equalTo(self).offset(Constants.padding * 6);
            make.left.equalTo(self).offset(Constants.padding * 2);
            make.right.equalTo(self).offset(-Constants.padding * 2);
            let width = (UIScreen.mainScreen().bounds.width - (Constants.padding * 2));
            let height = (width / self.systemSelect!.background.image!.size.width) * self.systemSelect!.background.image!.size.height;
            make.height.equalTo(height);
        });
        
        if let sys = self.systemSelect {
            self.gameInput.snp_remakeConstraints(closure: {
                make in
                make.top.equalTo(sys.snp_bottom).offset(Constants.padding * 2);
                make.left.equalTo(self).offset(Constants.padding * 2);
                make.right.equalTo(self).offset(-Constants.padding * 2);
                make.height.equalTo(Constants.padding * 5);
                
            })
            
            self.nameInput.snp_remakeConstraints(closure: {
                make in
                make.top.equalTo(gameInput.snp_bottom).offset(Constants.padding);
                make.left.equalTo(self).offset(Constants.padding * 2);
                make.right.equalTo(self).offset(-Constants.padding * 2);
                make.height.equalTo(Constants.padding * 5);
                
            })
            
            self.message.snp_remakeConstraints(closure: {
                make in
                make.top.equalTo(self.nameInput.snp_bottom).offset(Constants.padding);
                make.left.equalTo(self).offset(Constants.padding * 2);
                make.right.equalTo(self).offset(-Constants.padding * 2);
                make.height.equalTo(UIScreen.mainScreen().bounds.height * 0.1);
            })
            
            self.shareStrip.snp_remakeConstraints(closure: {
                make in
                make.top.equalTo(self.message.snp_bottom).offset(Constants.padding);
                make.left.equalTo(self).offset(0);
                make.right.equalTo(self).offset(0);
                let sideWidth = (UIScreen.mainScreen().bounds.width - (4 * Constants.padding)) / 2;
                make.height.equalTo(sideWidth * 0.45);
            })
            
           
            
        }

        
        self.LFGButton.snp_remakeConstraints(closure: {
            make in
            make.bottom.equalTo(self).offset(-Constants.padding);
            make.centerX.equalTo(self.snp_centerX)
            make.width.equalTo(UIScreen.mainScreen().bounds.width * 0.35);
            make.top.equalTo(self.shareStrip.snp_bottom).offset(Constants.padding);
        })

        

        super.layoutSubviews();
    }
    
    func getGame() -> String {
        if (self.gameInput.text != self.gamePlaceholder) {
            return self.gameInput.text!
        } else {
            return "";
        }
    }
    
    
    func getSystemIndex() -> Int {
        return (self.systemSelect?.selectedIndex)!;
    }
    
    func getGamerTag() -> String {
        if (self.nameInput.text != self.namePlaceholder) {
            return self.nameInput.text!
        } else {
            return "";
        }
    }
    
    
    
    func textFieldDidBeginEditing(textField: UITextField) {
        let textF: FancyTextField = textField as! FancyTextField;
        textF.setEditingView();
        if (textField.text == self.gamePlaceholder || textField.text == self.namePlaceholder) {
            textField.text = "";
        }
        
        
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if (textField.text == "") {
            if (textField == self.gameInput) {
                textField.text = self.gamePlaceholder;
            } else {
                textField.text = self.namePlaceholder;
            }
        }
        
        
        
        
        let textF: FancyTextField = textField as! FancyTextField;
        textF.endEditingView();
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
        if (textView.text.characters.count > 100 && text != "") {
            return false;
        } else {
            if (text == "\n") {
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
    
}
