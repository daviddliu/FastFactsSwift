//
//  AboutViewController.swift
//  FFSwift
//
//  Created by David Liu on 9/26/15.
//  Copyright © 2015 David Liu. All rights reserved.
//

import UIKit

class WebViewController: UIViewController, UIWebViewDelegate{
    
    var aboutView: UIWebView!
    var workingTitle: String!
    var htmlName: String!
    
    init(title: String, htmlName: String){
        self.workingTitle = title
        self.htmlName = htmlName
        super.init(nibName: nil, bundle: nil);
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        self.title = workingTitle
        let filePath = NSBundle.mainBundle().URLForResource(htmlName, withExtension: ".html")
        let request = NSURLRequest(URL: filePath!)
        aboutView = UIWebView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        aboutView.loadRequest(request)
        aboutView.delegate = self
        self.view.addSubview(aboutView)
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        //Adjust width of article view
        self.aboutView.frame.size.width = (self.navigationController?.navigationBar.frame.width)!
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let link: NSURL = request.URL!
        
        if link.absoluteString.contains("http://") || link.absoluteString.contains("https://"){
            // Redundant, I know
            class OutsideLink: UIViewController{}
            let webVC = OutsideLink()
            webVC.title = "External Link"
            let externalLink = UIWebView(frame: CGRectMake(0, 0, self.view.viewWidth, self.view.viewHeight))
            let request: NSURLRequest = NSURLRequest(URL: link)
            externalLink.loadRequest(request)
            webVC.view.addSubview(externalLink)
            self.navigationController?.pushViewController(webVC, animated: true)
            return false
        }
        return true

    }
}