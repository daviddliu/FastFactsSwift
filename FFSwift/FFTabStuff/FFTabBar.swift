//
//  FFTabBarD.swift
//  FFSwift
//
//  Created by David Liu on 9/24/15.
//  Copyright © 2015 David Liu. All rights reserved.
//

import UIKit
import RealmSwift

class FFTabBar: UITabBarController, UITabBarControllerDelegate{
    
    let realm = try! Realm()
    
    override func viewDidLoad(){
        super.viewDidLoad()
        setupTabBar()
        self.delegate = self
    }
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        // Random VC
        if viewController.tabBarItem.tag == 0 {
            let articleNumber = Int(arc4random_uniform(UInt32(GlobalDBValues.count)))
            let newRandomVC = UINavigationController(rootViewController: FFRandomArticleViewController(articleNumber: articleNumber, title: "Random"))
            let randomFF = UITabBarItem(title: "Random", image: UIImage(named: "fact_of_the_day.png"), tag: 0)
            newRandomVC.tabBarItem = randomFF
            randomFF.title = "Random"
            setUpNavController(newRandomVC, tabItem: randomFF)
            var VCs = tabBarController.viewControllers!
            VCs.removeAtIndex(0)
            VCs.insert(newRandomVC, atIndex: 0)
            tabBarController.setViewControllers(VCs, animated: false)
        }
            // Bookmarked
        else if viewController.tabBarItem.tag == 1 {
            let nav = viewController as! UINavigationController
            if let vc = nav.topViewController as? FFBookmarkedViewController{
                vc.bookmarksUpdated()
            }
        }
    }
    
    func setupTabBar(){
        
        let randomFF = UITabBarItem(title: "Random", image: UIImage(named: "fact_of_the_day.png"), tag: 0)
        let bookmarks = UITabBarItem(tabBarSystemItem: UITabBarSystemItem.Bookmarks, tag: 1)
        let fastFacts = UITabBarItem(title: "All Fast Facts", image: UIImage(named: "fast_facts.png"), tag: 2)
        let categories = UITabBarItem(title: "Categories", image: UIImage(named: "core.png"), tag: 3)
        let about = UITabBarItem(title: "About", image: UIImage(named: "tips.png"), tag: 4)
        let settings = UITabBarItem(title: "Settings", image: UIImage(named: "settings.png"), tag:5)
        
        //MARK: Random VC
        let number = Int(arc4random_uniform(UInt32(GlobalDBValues.count)))
        let randomFFVC = UINavigationController(rootViewController: FFRandomArticleViewController(articleNumber: number))
        randomFFVC.tabBarItem = randomFF
        
        let subjectVC = UINavigationController(rootViewController: FFSubjectViewController(name: "Categories"))
        setUpNavController(subjectVC, tabItem: categories)
        
        let allVC = UINavigationController(rootViewController: FFListViewController(name: "All Fast Facts"))
        setUpNavController(allVC, tabItem: fastFacts)
        
        let bookmarkVC = UINavigationController(rootViewController: FFBookmarkedViewController(name: "Bookmarked"))
        setUpNavController(bookmarkVC, tabItem: bookmarks)
        
        let aboutVC = UINavigationController(rootViewController: WebViewController(title: "About", htmlName: "about"))
        setUpNavController(aboutVC, tabItem: about)
        
        let settingsVC = UINavigationController(rootViewController: SettingsViewController())
        setUpNavController(settingsVC, tabItem: settings)
        
        self.moreNavigationController.navigationBar.barTintColor = UIColor(rgba: "#307ca5")
        self.moreNavigationController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.moreNavigationController.navigationBar.tintColor = UIColor.whiteColor()
        self.moreNavigationController.navigationBar.barStyle = UIBarStyle.Black;
        
        self.setViewControllers([randomFFVC, bookmarkVC, allVC, subjectVC, settingsVC, aboutVC], animated: false)
        self.selectedViewController = self.viewControllers?[2]
    }
    
    func setUpNavController(nav: UINavigationController, tabItem: UITabBarItem) -> UINavigationController{
        nav.navigationBar.barTintColor = UIColor(rgba: "#307ca5")
        nav.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        nav.navigationBar.tintColor = UIColor.whiteColor()
        nav.tabBarItem = tabItem
        nav.navigationBar.barStyle = UIBarStyle.Black;
        return nav
    }
    
    // Status Bar
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
}