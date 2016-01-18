//
//  SettingsViewController.swift
//  LFGERREAL
//
//  Created by Alex Hartwell on 1/16/16.
//  Copyright © 2016 SWARM. All rights reserved.
//

import Foundation
import UIKit



class SettingsView: BaseView, UIGestureRecognizerDelegate, UITextFieldDelegate {
    
    var aboutView: UITextView = UITextView();
    var emailLabel: UILabel = UILabel();
    var emailInput: FancyTextField = FancyTextField();
    var TOSLink: UITextView = UITextView();
    var keyboardHeight: CGFloat = 178;
    
    override func didLoad() {
        
        self.backgroundColor = UIColor.whiteColor();
        
        
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = UIScreen.mainScreen().bounds
        gradient.colors = [UIColor(red: 247/255.0, green: 247/255.0, blue: 247/255.0, alpha: 255).CGColor, UIColor(red: 208/255.0, green: 207/255.0, blue: 206/255.0, alpha: 255).CGColor]
        self.layer.insertSublayer(gradient, atIndex: 0)
        
        self.addSubview(self.aboutView);
        self.addSubview(self.emailLabel);
        self.addSubview(self.emailInput);
        self.addSubview(self.TOSLink);
        
    
        
        self.emailInput.setUpGradients();
        self.aboutView.editable = false;
        self.aboutView.text = "Drop us your email and we may send you free games through Stream, and on occasion send out mega import announcements.";
        self.aboutView.backgroundColor = UIColor.clearColor();
        self.aboutView.font = UIFont.systemFontOfSize(18);
        self.aboutView.textColor = UIColor(red: 0.529, green: 0.494, blue: 0.494, alpha: 1.00);
        let tosString = "tos + privacy policy";
        
        
        let tos: NSMutableAttributedString = NSMutableAttributedString(string: "tos + privacy policy");
        tos.addAttribute(NSLinkAttributeName, value: "http://lfger.com/tos.html", range: NSRange(location: 0, length: tosString.characters.count));
     
        TOSLink.attributedText = tos;
        TOSLink.textColor = UIColor.blackColor();
        self.TOSLink.editable = false;
        self.TOSLink.backgroundColor = UIColor.clearColor();
        self.TOSLink.textAlignment = NSTextAlignment.Center;
        self.emailLabel.text = "Email: "
        self.emailLabel.textColor = UIColor(red: 0.529, green: 0.494, blue: 0.494, alpha: 1.00);

        
        
        self.emailInput.becomeFirstResponder();
        
        let tap = UITapGestureRecognizer();
        tap.delegate = self;
        self.addGestureRecognizer(tap);
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardUp:", name: UIKeyboardWillShowNotification, object: nil);
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardIsUp:", name: UIKeyboardDidShowNotification, object: nil);
        
        
    }

    func keyboardUp(userInfo: NSNotification) {
        
        let size = userInfo.userInfo![UIKeyboardFrameEndUserInfoKey]?.CGRectValue;
        if let s = size {
            self.keyboardHeight = s.height;
            self.setNeedsUpdateConstraints();
            
        }
    }
    
    func keyboardIsUp(userInfo: NSNotification) {
        let email: String? = SavedData.getData("email");
        if let e = email {
            self.emailInput.text = e;
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews();
        
        var topCorrect = (self.aboutView.bounds.size.height - self.aboutView.contentSize.height * self.aboutView.zoomScale) / 2;
        topCorrect = ( topCorrect < 0.0 ? 0.0 : topCorrect );
        self.aboutView.transform = CGAffineTransformMakeTranslation(0, topCorrect);
        
    }
    
    override func updateConstraints() {
        if (self.keyboardHeight == 0) {
            super.updateConstraints();
            return;
        }
        self.aboutView.snp_remakeConstraints(closure: {
            make in
            make.top.equalTo(self).offset(0);
            make.left.equalTo(self).offset(Constants.padding * 2);
            make.right.equalTo(self).offset(-Constants.padding * 2);
            make.bottom.equalTo(self.emailLabel.snp_top);
        })
        
        
        
        self.emailLabel.snp_remakeConstraints(closure: {
            make in
            make.left.equalTo(self).offset(Constants.padding * 2);
            make.bottom.equalTo(self.TOSLink.snp_top).offset(-Constants.padding * 2);
            make.right.equalTo(self).offset(-Constants.padding * 2);
            make.height.equalTo(40);
            make.width.greaterThanOrEqualTo(65);
        })
        
        self.emailInput.snp_remakeConstraints(closure: {
            make in
            make.bottom.equalTo(self.TOSLink.snp_top).offset(-Constants.padding * 2);
            make.right.equalTo(self).offset(-Constants.padding * 2);
            make.left.equalTo(self.emailLabel.snp_right).offset(Constants.padding);
            make.width.equalTo(UIScreen.mainScreen().bounds.width * 0.7);
            make.height.equalTo(40);
        })
        
        
        self.TOSLink.snp_remakeConstraints(closure: {
            make in
            make.bottom.equalTo(self).offset(-Constants.padding - self.keyboardHeight);
            make.width.equalTo(UIScreen.mainScreen().bounds.width);
            make.height.equalTo(50);
            make.centerX.equalTo(self.snp_centerX);
        })
        
    
        
        super.updateConstraints();
    }
    
    
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
//        self.emailInput.endEditing(true);
        return false
    }
    
    
    
   
    
}

class SettingsViewController: UIViewController, UITextFieldDelegate {
    
    var settingsView: SettingsView = SettingsView();
    
    
    
    override func loadView() {
        super.loadView();
        self.view = settingsView;
        self.navigationController?.navigationBarHidden = false;

        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.529, green: 0.494, blue: 0.494, alpha: 1.00);
        self.navigationController?.navigationBar.translucent = false;
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor();
        self.navigationController?.navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor();
        UINavigationBar.appearance().tintColor = UIColor.whiteColor();
        self.title = "SETTINGS";
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSTextEffectAttributeName: NSTextEffectLetterpressStyle];
        self.settingsView.emailInput.delegate = self;
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        UINavigationBar.appearance().tintColor = UIColor.whiteColor();

    }
    
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        self.settingsView.emailInput.setEditingView();
        return true;
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        self.settingsView.emailInput.endEditingView();
        if (isValidEmail(self.settingsView.emailInput.text!)) {
            SubmissionService.sendEmail(self.settingsView.emailInput.text!);
            SavedData.saveData("email", value: self.settingsView.emailInput.text!);
        }
    }

    func isValidEmail(testStr:String) -> Bool {
        // println("validate calendar: \(testStr)")
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    
    
    
    
    
    
}