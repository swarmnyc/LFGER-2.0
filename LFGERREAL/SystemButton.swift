//
//  SystemButton.swift
//  LFGER
//
//  Created by Alex Hartwell on 1/16/16.
//  Copyright © 2016 SWARM. All rights reserved.
//

import Foundation
import UIKit

class SystemButton: UIButton {
    var index: Int = 0;
    var selectedImage: UIImageView = UIImageView(image: UIImage(named: "systemBtnOn")!);
    var titleText: String = "";
    func setPosition() {
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center;
        self.contentVerticalAlignment = UIControlContentVerticalAlignment.Top;
        
    }
    
    func setEmbossedText(text: String, color: UIColor) {
        self.titleText = text;
        let attrString = NSMutableAttributedString(string: text);
        attrString.addAttributes([NSTextEffectAttributeName: NSTextEffectLetterpressStyle,
            NSForegroundColorAttributeName: color], range: NSRange(location: 0, length: text.characters.count));
        self.setAttributedTitle(attrString, forState: .Normal);
    }
    
    func setUpView() {
        if (selectedImage.superview != nil) {
            return;
        }
        self.selectedImage.contentMode = UIViewContentMode.ScaleAspectFit;
        self.addSubview(self.selectedImage);
        self.selectedImage.snp_remakeConstraints(closure: {
            make in
            make.centerX.equalTo(self.snp_centerX);
            make.height.equalTo(self.selectedImage.image!.size.height);
            make.width.equalTo(self.selectedImage.image!.size.width);
            make.centerY.equalTo(self.snp_centerY).offset(Constants.padding * 4);
        })

    }
    
    func selectButton() {
        self.backgroundColor = UIColor.clearColor();
        self.selectedImage.alpha = 1;
        self.setEmbossedText(self.titleText, color: Constants.redColor)
        
    }
    
    
    func deselectButton() {
        self.backgroundColor = UIColor.clearColor();
        self.selectedImage.alpha = 0;
        self.setEmbossedText(self.titleText, color: UIColor(red: 0.408, green: 0.380, blue: 0.380, alpha: 1.00))

    }
    
}