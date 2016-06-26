//
//  FFArticleView.swift
//  FFSwift
//
//  Created by David Liu on 8/30/15.
//  Copyright © 2015 David Liu. All rights reserved.
//

import UIKit
import RealmSwift
import MessageUI

class FFArticleViewController: UIViewController, UIWebViewDelegate, UIGestureRecognizerDelegate, MFMailComposeViewControllerDelegate{
    
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
    var highlighted = false
    var query: String? = nil
    
    init(articleNumber: Int, title: String? = nil, highlighted: Bool = false, query: String? = nil){
        self.articleNumber = articleNumber
        self.highlighted = highlighted
        self.query = query
        
        if title != nil{
            self.workingTitle = title
        }
        else{
            self.workingTitle = "FF #\(self.articleNumber)"
        }
    
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
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func pullTabbarOnscreen(){
        nav.hidesBarsOnSwipe = false
        tab.tabBar.hidden = false
        var smallerFrame: CGRect = tab.view.frame
        smallerFrame.size.height -= tab.tabBar.frame.size.height
        tab.view.frame = smallerFrame
        articleView.frame = smallerFrame
    }
    
    func pushTabbarOffscreen(){
        self.navigationController?.hidesBarsOnSwipe = true
        self.navigationController?.view.frame.origin.y = 0
        self.navigationController?.barHideOnSwipeGestureRecognizer.addTarget(self, action: "didSwipe:")
        self.tabBarController?.tabBar.hidden = true
        var biggerFrame: CGRect = (self.tabBarController?.view.frame)!;
        let tabBarSize = (self.tabBarController?.tabBar.frame.size.height)!
        // Push the tab bar off screen and increase the size of the articleView to compensate.
        biggerFrame.size.height += tabBarSize
        self.articleView.frame.size.height += tabBarSize
        // We have to do this because height is an immutable property
        self.tabBarController?.view.frame = biggerFrame
        self.navigationController?.view.frame = biggerFrame
        // Interestingly, in the pullOnscreen function, self.controllers are both nil.
        nav = self.navigationController!
        tab = self.tabBarController!
    }
    
    // MAKE SURE TO PRESENT TOOLBAR AFTER EVERYTHING WAS SET UP!
    // Don't have to hide it because the view destroys it.
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.setToolbarHidden(false, animated: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        pushTabbarOffscreen()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        pullTabbarOnscreen()
    }
    
    override func viewDidLoad() {
        //MARK: configure navBar and toolBar
        self.title = self.workingTitle
        curFramePosition = 0.0 //Not hidden
        let backButton = UIBarButtonItem()
        backButton.title = "Back"
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
//        self.navigationItem.backBarButtonItem = backButton
        //MARK: load HTML file
        self.articleView = UIWebView(frame: CGRectMake(0, 0, self.view.viewWidth, self.view.viewHeight))
        self.articleView.sizeToFit()
        self.articleView.delegate = self
        if let articleHTMLPath = NSBundle.mainBundle().URLForResource(String(self.articleNumber), withExtension: "html"){
            let request: NSURLRequest = NSURLRequest(URL: articleHTMLPath)
            self.articleView.loadRequest(request)
        }
        
        let zoomer = UIPinchGestureRecognizer(target: self, action: "pinchToZoom:")
        zoomer.delegate = self
        self.articleView.addGestureRecognizer(zoomer)
        
        setUpToolbar()
        checkBounds()
    
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
    
    
    //MARK navigationBar functions
    func setUpToolbar(){
        let FLEXIBLE_SPACE: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        
        let backButton = UIBarButtonItem(image: UIImage(named: "back.png"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("goBackOneArticle:"))
        
        // MARK: Bookmark
        var bookmarkIcon: String = ""
        if (self.bookmarked == true){
            bookmarkIcon = "bookmarked.png"
        }
        else{
            bookmarkIcon = "bookmark.png"
        }
        let bookMarkButton = UIBarButtonItem(image: UIImage(named: bookmarkIcon), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("toggleBookmark:"))
        
        let emailButton = UIBarButtonItem(image: UIImage(named: "message.png"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("sendEmail:"))
        let forwardButton = UIBarButtonItem(image: UIImage(named: "forward.png"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("goForwardOneArticle:"))
        
        toolbarItems = [backButton, FLEXIBLE_SPACE, bookMarkButton, FLEXIBLE_SPACE, emailButton, FLEXIBLE_SPACE, forwardButton]
        
        self.navigationController?.setToolbarItems(toolbarItems, animated: false)
    }
    
    func goBackOneArticle(sender:UIBarButtonItem!){

        var vcs = self.navigationController?.viewControllers
        vcs?.removeLast()
        vcs?.append(FFArticleViewController(articleNumber: self.articleNumber - 1))
        self.navigationController?.setViewControllers(vcs!, animated: false)
    }

    func goForwardOneArticle(sender:UIBarButtonItem!){
        var vcs = self.navigationController?.viewControllers
        vcs?.removeLast()
        vcs?.append(FFArticleViewController(articleNumber: self.articleNumber + 1))
        self.navigationController?.setViewControllers(vcs!, animated: false)
    }
    
    func checkBounds(){
        if self.articleNumber == 1{
            self.navigationController?.toolbarItems?[0].enabled = false
        }
            
        else if self.articleNumber >= GlobalDBValues.count{
            self.navigationController?.toolbarItems?[6].enabled = false
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
    
    func setUpNavBookmark(){

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
                var parent: FFArticleViewController!
                init(parent: FFArticleViewController){
                    self.parent = parent
                    super.init(nibName: nil, bundle: nil);
                }
                required init?(coder aDecoder: NSCoder) {
                    super.init(coder: aDecoder)
                }
                override func viewWillAppear(animated: Bool) {
                    // Toggle the views without changing the parent dimensions
                    self.navigationController?.navigationBarHidden = false
                    self.navigationController?.hidesBarsOnSwipe = false
                    self.navigationController?.toolbarHidden = true
                    self.tabBarController?.tabBar.hidden = true
                    super.viewWillAppear(animated)
                }
                override func viewWillDisappear(animated: Bool) {
                    super.viewWillDisappear(animated)
                }
            }
            let webVC = OutsideLink(parent: self)
            webVC.title = "External Link"
            let externalLink = UIWebView(frame: CGRectMake(0, 0, self.view.viewWidth, self.view.viewHeight))
            let request: NSURLRequest = NSURLRequest(URL: link)
            externalLink.loadRequest(request)
            webVC.view.addSubview(externalLink)
            self.navigationController?.pushViewController(webVC, animated: true)
        }
        else if link.absoluteString.contains("category"){
            let stringArr = link.absoluteString.stringByReplacingOccurrencesOfString("%20", withString: " ").componentsSeparatedByString("category: ")
            let subject = stringArr[1]
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
            self.title = "FF #\(articleNum)"
            return true
        }
        else{
            return true
        }
        return false
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        if getFromUserDefaults(Setting.Highlight) as! Bool{
            highlight()
        }
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
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if (motion == UIEventSubtype.MotionShake) && (getFromUserDefaults(Setting.Highlight) as! Bool) && (getFromUserDefaults(Setting.Shake) as! Bool)
        {
            toggleHighlight()
        }
    }
    
    func toggleHighlight(){
        // If it is currently highlighted, remove highlights and set that it is not highlighted.
        // Else, highlight it.
        if(highlighted) {
            highlighted = false;
            unHighlight()
        }
        else {
            highlighted = true;
            highlight()
        }
    }
    
    func unHighlight(){
        let path = NSBundle.mainBundle().pathForResource("highlight.js", ofType: nil)
        let highlightJS = try! String(contentsOfFile: path!, encoding: NSUTF8StringEncoding)
        // Inject JS
        self.articleView.stringByEvaluatingJavaScriptFromString(highlightJS)
        let startSearch = "uiWebview_RemoveAllHighlights()"
        self.articleView.stringByEvaluatingJavaScriptFromString(startSearch)
    }
    
    func highlight(){
        if query != nil{
            let path = NSBundle.mainBundle().pathForResource("highlight.js", ofType: nil)
            let highlightJS = try! String(contentsOfFile: path!, encoding: NSUTF8StringEncoding)
            // Inject JS
            self.articleView.stringByEvaluatingJavaScriptFromString(highlightJS)
            let startSearch = "uiWebview_HighlightAllOccurencesOfString(\"\(query!)\")"
            self.articleView.stringByEvaluatingJavaScriptFromString(startSearch)
        }
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // Override for shake
    override func canBecomeFirstResponder() -> Bool {
        return true
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
        presentViewController(sendMailErrorAlert, animated: true, completion: emailTransitionComplete)
    }
    
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: emailTransitionComplete)
    }
    
    // Something to do with iPad transform layer. Only need to resize on iPhone. Why? Blame iOS9. I really don't know.
    func emailTransitionComplete(){
        if (UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone){
            pushTabbarOffscreen()
        }
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        //Adjust width of article view
        self.articleView.frame.size.width = (self.tabBarController?.tabBar.frame.width)!
    }
    
}
    