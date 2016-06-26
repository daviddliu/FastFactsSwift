//
//  FFRandomArticleViewController.swift
//  Fast Facts
//
//  Created by David Liu on 10/1/15.
//  Copyright © 2015 David Liu. All rights reserved.
//

import UIKit
import RealmSwift
import MessageUI

class FFRandomArticleViewController: UIViewController, UIWebViewDelegate, UIGestureRecognizerDelegate, MFMailComposeViewControllerDelegate{
    
    var articleNumber: Int!
    var articleView: UIWebView!
    var bookmarked: Bool!
    var bookmarkedArticles: [Int]!
    var workingTitle: String?
    var nav: UINavigationController!
    var tab: UITabBarController!
    var curFramePosition: Double!
    var showStatusBar: Bool = true
    var fontSize: CGFloat = 14.0
    
    init(articleNumber: Int, title: String? = nil, randomArticle: Bool = false, highlighted: Bool = false, query: String? = nil){
        self.articleNumber = articleNumber
        
        self.workingTitle = "FF #\(self.articleNumber)"

        let userDefaults = NSUserDefaults.standardUserDefaults()
        self.bookmarkedArticles = userDefaults.arrayForKey("bookmarked") as? [Int] ?? [Int]()
        let recentlyViewedArticles = userDefaults.arrayForKey("recentlyViewed") as? [Int] ?? [Int]()
        userDefaults.setObject(addToRecentlyViewed(recentlyViewedArticles, articleNumber: self.articleNumber), forKey: "recentlyViewed")
        userDefaults.synchronize()
        
        if self.bookmarkedArticles.contains(self.articleNumber){
            self.bookmarked = true
        }
        else{
            self.bookmarked = false
        }
        
        super.init(nibName: nil, bundle: nil);
        self.navigationController?.navigationBar.topItem?.title = self.workingTitle
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.hidesBarsOnSwipe = true
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        //MARK: configure navBar and toolBar
        super.viewDidLoad()
        curFramePosition = 0.0 //Not hidden
        self.navigationController?.view.frame.origin.y = 0
        let emailButton = UIBarButtonItem(image: UIImage(named: "message.png"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("sendEmail:"))
        self.navigationItem.rightBarButtonItem = emailButton
        
        // MARK: Bookmark
        var bookmarkIcon: String = ""
        if (self.bookmarked == true){
            bookmarkIcon = "bookmarked.png"
        }
        else{
            bookmarkIcon = "bookmark.png"
        }
        let bookMarkButton = UIBarButtonItem(image: UIImage(named: bookmarkIcon), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("toggleBookmark:"))
        self.navigationItem.leftBarButtonItems = [bookMarkButton]
        
        //MARK: load HTML file
        self.articleView = UIWebView(frame: CGRectMake(0, 0, self.view.viewWidth, self.view.viewHeight))
        self.articleView.sizeToFit()
        self.articleView.delegate = self
        if let articleHTMLPath = NSBundle.mainBundle().URLForResource(String(self.articleNumber), withExtension: "html"){
            let request: NSURLRequest = NSURLRequest(URL: articleHTMLPath)
            self.articleView.loadRequest(request)
        }
        self.navigationController?.barHideOnSwipeGestureRecognizer.addTarget(self, action: "didSwipe:")
        let zoomer = UIPinchGestureRecognizer(target: self, action: "pinchToZoom:")
        zoomer.delegate = self
        self.articleView.addGestureRecognizer(zoomer)
        
        self.view.addSubview(self.articleView)
        
        // Logging
        let appDelegate  = UIApplication.sharedApplication().delegate as! AppDelegate
        let viewController = appDelegate.window!.rootViewController! as! FFTabBar
        var activeTab = viewController.tabBar.selectedItem!.title
        if activeTab == nil{
            // Bookmarks doesn't have a title
            activeTab = "Bookmarks"
        }
        trackArticleOpened(self.articleNumber, active: activeTab!)
    }
    
    func didSwipe(swipe: UIPanGestureRecognizer){
        updateNavBar()
    }
    
    func updateNavBar(){
        // Visible to hidden
        // Why 64? I guess the status bar isn't considered hidden or something when highlighted is on. Honestly I have no idea.
        if curFramePosition == 0 && self.navigationController?.navigationBar.frame.origin.y < 0{
            curFramePosition = -44
            showStatusBar = false
            prefersStatusBarHidden()
            setNeedsStatusBarAppearanceUpdate()
        }
        // Hidden to visible
        else if curFramePosition == -44 && self.navigationController?.navigationBar.frame.origin.y == 0 {
            curFramePosition = 0
            showStatusBar = true
            prefersStatusBarHidden()
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    func toggleBookmark(sender:UIBarButtonItem!){
        
        if (self.bookmarked == false){
            self.bookmarked = true
            self.bookmarkedArticles.append(self.articleNumber)
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setObject(self.bookmarkedArticles, forKey: "bookmarked")
            userDefaults.synchronize()
            sender.image = UIImage(named: "bookmarked.png")
            
            // Logging
            trackBookmarked(articleNumber)
        }
        else{
            self.bookmarked = false
            let index = self.bookmarkedArticles.indexOf(self.articleNumber)
            self.bookmarkedArticles.removeAtIndex(index!)
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setObject(self.bookmarkedArticles, forKey: "bookmarked")
            userDefaults.synchronize()
            sender.image = UIImage(named: "bookmark.png")
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        if showStatusBar{
            return false
        }
        return true
    }
    
    // MARK: UIWebView
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let link: NSURL = request.URL!
        
        if link.absoluteString.contains("http://") || link.absoluteString.contains("https://"){
            class OutsideLink: UIViewController{
                override func viewWillAppear(animated: Bool) {
                    super.viewWillAppear(animated)
                    self.navigationController?.navigationBarHidden = false
                    self.navigationController?.hidesBarsOnSwipe = false
                }
            }
            let webVC = OutsideLink()
            webVC.title = "External Link"
            let externalLink = UIWebView(frame: CGRectMake(0, 0, self.view.viewWidth, self.view.viewHeight))
            let request: NSURLRequest = NSURLRequest(URL: link)
            externalLink.loadRequest(request)
            webVC.view.addSubview(externalLink)
            self.navigationController?.pushViewController(webVC, animated: true)
        }
        else if link.absoluteString.contains("category"){
            let stringArr = link.absoluteString.componentsSeparatedByString("%20")
            let subject = findCategory(stringArr[1])
            self.tabBarController?.selectedViewController = self.tabBarController?.viewControllers![3]
            self.tabBarController?.selectedIndex = 3
            let navVC = self.tabBarController?.selectedViewController as! UINavigationController
            navVC.popToRootViewControllerAnimated(false)
            let subjectVC = navVC.topViewController as! FFSubjectViewController
            let index = GlobalDBValues.distinctSubjectsArr.indexOf(subject)!
            let indexPath: NSIndexPath = NSIndexPath(forRow: index, inSection: 0)
            subjectVC.tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.None)
            subjectVC.tableView(subjectVC.tableView, didSelectRowAtIndexPath: indexPath)
        }
            // Local fast fact
        else if link.lastPathComponent!.contains(".html"){
            let articleNum = link.lastPathComponent!.componentsSeparatedByString(".")[0]
            self.articleNumber = Int(articleNum)
            self.navigationController?.navigationBar.topItem?.title = "FF #\(articleNum)"
            return true
        }
        else{
            return true
        }
        return false
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        // For the background
        self.articleView.stringByEvaluatingJavaScriptFromString(getInjectJS())
    }
    
    func pinchToZoom(gesture: UIPinchGestureRecognizer){
        if gesture.state == UIGestureRecognizerState.Changed || gesture.state == UIGestureRecognizerState.Ended{
            if gesture.scale*fontSize <= 30 && gesture.scale*fontSize >= 8{
                let js = "document.body.style.fontSize = parseFloat(\(gesture.scale*fontSize));"
                self.articleView.stringByEvaluatingJavaScriptFromString(js)
            }
        }
    }
    
    // MARK: Mail composer
    func sendEmail(sender:UIBarButtonItem!){
        let mailComposeVC = MFMailComposeViewController()
        configureMailComposer(mailComposeVC)
        if MFMailComposeViewController.canSendMail() {
            self.presentViewController(mailComposeVC, animated: true, completion: nil)
        } else {
            showSendMailErrorAlert()
        }
        
        // Logging
        trackShared(articleNumber)
    }
    
    func configureMailComposer(aVC: MFMailComposeViewController){
        aVC.mailComposeDelegate = self
        
        aVC.setSubject("A Fast Facts Article Was Shared With You")
        
        let article: Article = GlobalDBValues.getArticle(articleNumber)
        
        let body: String = "<strong>Fast Fact #\(articleNumber): \(article.title)</strong> <br><br>\n <em> The full article is attached to this email. </em><br><br>\n \(article.background) \n<br><br><br> <a href=\"https://itunes.apple.com/us/app/palliative-care-fast-facts/id868472172\">Click here to download Fast Facts for iOS today.</a>"
        aVC.setMessageBody(body, isHTML: true)
        
        let filePath = NSBundle.mainBundle().pathForResource("\(articleNumber).html", ofType: nil)
        let fileData: NSData = NSData(contentsOfFile: filePath!)!
        aVC.addAttachmentData(fileData, mimeType: "text/html", fileName: "Fast Fact #\(articleNumber)")
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertController(title: "Could Not Send Email", message: "Your device could not send this e-mail. Please check your email configuration and try again.", preferredStyle: UIAlertControllerStyle.Alert)
        presentViewController(sendMailErrorAlert, animated: true, completion: nil)
    }
    
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        //Adjust width of article view
        self.articleView.frame.size.width = (self.tabBarController?.tabBar.frame.width)!
    }
    
}
