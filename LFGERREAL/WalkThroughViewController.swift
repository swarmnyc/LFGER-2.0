//
//  WalkThroughViewController.swift
//  LFGER
//
//  Created by Alex Hartwell on 1/18/16.
//  Copyright © 2016 SWARM. All rights reserved.
//

import Foundation
import UIKit


class WalkThroughViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var pageViewController: UIPageViewController = UIPageViewController();
    var contentImages = [
        "onboarding1",
        "onboarding2",
        "onboarding3"
    ]
   
    var index: Int = 0;
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createPageViewController()
        self.setupPageControl()
    }
    
    
    func createPageViewController() {
        
        self.pageViewController.dataSource = self;
        self.pageViewController.delegate = self;
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer();
        tap.addTarget(self, action: "nextPage");
        
        self.pageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil);

        if contentImages.count > 0 {
            let firstController = getItemController(0)!
            let startingViewControllers: NSArray = [firstController]
            pageViewController.setViewControllers(startingViewControllers as! [UIViewController], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
        }
        
        addChildViewController(pageViewController)
        self.view.addSubview(pageViewController.view)
        self.pageViewController.view.addGestureRecognizer(tap);
        pageViewController.didMoveToParentViewController(self)
        self.pageViewController.view.snp_remakeConstraints(closure: {
            make in
            make.edges.equalTo(self.view);
        })
        
    }
    
    func nextPage() {
        self.index++;
        
        if (index == 3) {
            self.dismissViewControllerAnimated(true, completion: nil);
            return;
        }
        
        let firstController = getItemController(self.index)!
        let startingViewControllers: NSArray = [firstController]
        pageViewController.setViewControllers(startingViewControllers as! [UIViewController], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
    }
    
    func setupPageControl() {
        let appearance = UIPageControl.appearance()
        appearance.pageIndicatorTintColor = UIColor.grayColor()
        appearance.currentPageIndicatorTintColor = UIColor.whiteColor()
        appearance.backgroundColor = UIColor.darkGrayColor()
    }
    
    // MARK: - UIPageViewControllerDataSource
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        let itemController = viewController as! PageItemController
        
        if itemController.itemIndex > 0 {
            return getItemController(itemController.itemIndex-1)
        }
        
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        let itemController = viewController as! PageItemController
        
        if itemController.itemIndex+1 < contentImages.count {
            return getItemController(itemController.itemIndex+1)
        }
        
        return nil
    }
    
    func getItemController(itemIndex: Int) -> PageItemController? {
        
        if itemIndex < contentImages.count {
            var pageItemController = PageItemController();
            pageItemController.itemIndex = itemIndex
            pageItemController.imageName = contentImages[itemIndex]
            return pageItemController
        }
        
        return nil
    }
    
    // MARK: - Page Indicator
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return contentImages.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
}



class PageItemController: UIViewController {
    
// MARK: - Variables
var itemIndex: Int = 0
var imageName: String = "" {

didSet {
    
        contentImageView.image = UIImage(named: imageName)
    
}
}

    var contentImageView: UIImageView = UIImageView();

// MARK: - View Lifecycle
override func viewDidLoad() {
    super.viewDidLoad()
    self.view.addSubview(self.contentImageView);
    contentImageView.image = UIImage(named: imageName)
    
    
    self.contentImageView.snp_remakeConstraints(closure: {
        make in
        make.edges.equalTo(self.view);
    })
    
    
}
}