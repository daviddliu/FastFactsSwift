//
//  SettingsViewController.swift
//  FFSwift
//
//  Created by David Liu on 9/26/15.
//  Copyright © 2015 David Liu. All rights reserved.
//

import UIKit

enum DisplayStyles: Int{
    case black = 0
    case white = 1
    case peach = 2
}

enum Setting{
    case Highlight
    case Shake
    case BackgroundText
    case BackgroundColor
    case FontSize
}

func getFromUserDefaults(setting: Setting) -> Any{
    let userDefaults = NSUserDefaults.standardUserDefaults()
    switch setting{
    case .Highlight:
        return userDefaults.objectForKey("highlightEnabled") as? Bool ?? true
    case .Shake:
        return userDefaults.objectForKey("shakeEnabled") as? Bool ?? true
    case .BackgroundText:
        return userDefaults.objectForKey("backgroundTextEnabled") as? Bool ?? true
    case .BackgroundColor:
        return userDefaults.objectForKey("backgroundTextColor") as? String ?? "blackOnWhite"
    case .FontSize:
        return userDefaults.objectForKey("fontSize") as? Float ?? 14.0
    }
}

func toggleUserDefaults(setting: Setting, to: AnyObject){
    let userDefaults = NSUserDefaults.standardUserDefaults()
    switch setting{
    case .Highlight:
        userDefaults.setObject(to, forKey: "highlightEnabled")
    case .Shake:
        userDefaults.setObject(to, forKey: "shakeEnabled")
    case .BackgroundText:
        userDefaults.setObject(to, forKey: "backgroundTextEnabled")
    case .BackgroundColor:
        userDefaults.setObject(to, forKey: "backgroundTextColor")
    case .FontSize:
        userDefaults.setObject(to, forKey: "fontSize")
    }
    userDefaults.synchronize()
}

func getInjectJS() -> String{
    let displayType = getFromUserDefaults(Setting.BackgroundColor) as! String
    let conversionDict = [
        "blackOnWhite": DisplayStyles.white,
        "whiteOnBlack": DisplayStyles.black,
        "peach": DisplayStyles.peach
    ]
    return injectableBackgroundJS(conversionDict[displayType]!)
}

func injectableBackgroundJS(style: DisplayStyles) -> String{
    var backgroundColor: String!
    var textColor: String!
    let fontSize = getFromUserDefaults(Setting.FontSize)
    switch style{
    case .black:
        backgroundColor = "#555555"
        textColor = "#FFFFFF"
    case .white:
        backgroundColor = "#FFFFFF"
        textColor = "#111111"
    case .peach:
        backgroundColor = "#FFEFE6"
        textColor = "#111111"
    }
    var JSString = "document.body.style.background = \"\(backgroundColor)\"; document.body.style.color= \"\(textColor)\"; document.body.style.fontSize = parseFloat(\(fontSize));"
    JSString += "document.getElementById(100).textContent=\(fontSize)"
    return JSString
}

class SettingsViewController: UIViewController, UIWebViewDelegate{
    
    var highlightSwitch: UISwitch!
    var shakeSwitch: UISwitch!
    var backgroundTextSwitch: UISwitch!
    var fontSizeSlider: UISlider!
    var textStyleChooser: UISegmentedControl!
    var demoWebView: UIWebView!
    
    override func viewDidLoad(){
        self.title = "Settings"
        
        let highlightText: UILabel = UILabel(frame: CGRect(x: 15, y: 100, width: 0, height: 0))
        highlightText.text = "Search highlights enabled"
        highlightText.sizeToFit()
        self.view.addSubview(highlightText)
        highlightSwitch = UISwitch(frame: CGRect(x: self.view.frame.width/1.5, y: 100, width: self.view.frame.width/5.0, height: 30))
        
        let shakeText: UILabel = UILabel(frame: CGRect(x: 15, y: 150, width:0, height: 0))
        shakeText.text = "Shake removes highlights"
        shakeText.sizeToFit()
        self.view.addSubview(shakeText)
        shakeSwitch = UISwitch(frame: CGRect(x: self.view.frame.width/1.5, y: 150, width: self.view.frame.width/5.0, height: 30))
        
        let backgroundText: UILabel = UILabel(frame: CGRect(x: 15, y: 200, width:0, height: 0))
        backgroundText.text = "Background text in menu"
        backgroundText.sizeToFit()
        self.view.addSubview(backgroundText)
        backgroundTextSwitch = UISwitch(frame: CGRect(x: self.view.frame.width/1.5, y: 200, width: self.view.frame.width/5.0, height: 30))
        
        let fontText: UILabel = UILabel(frame: CGRect(x: 15, y: 250, width:0, height: 0))
        fontText.text = "Font size"
        fontText.sizeToFit()
        self.view.addSubview(fontText)
        fontSizeSlider = UISlider(frame: CGRect(x: self.view.frame.width/3.0, y: 250, width: self.view.frame.width/2.0, height: 30))
        fontSizeSlider.minimumValue = 8.0
        fontSizeSlider.maximumValue = 30.0
        fontSizeSlider.value = getFromUserDefaults(Setting.FontSize) as! Float
        
        let styleText: UILabel = UILabel(frame: CGRect(x: 0, y: 300, width:188.0, height: 20.5))
        styleText.center.x = self.view.center.x
        styleText.text = "Article background color"
        self.view.addSubview(styleText)
        let styles = ["Grey", "White", "Peach"]
        textStyleChooser = UISegmentedControl(items: styles)
        textStyleChooser.frame = CGRectMake(100, 325, self.view.frame.width/1.5, 50)
        textStyleChooser.center.x = self.view.center.x
        textStyleChooser.addTarget(self, action: "changeColor:", forControlEvents: .ValueChanged)
        
        demoWebView = UIWebView(frame: CGRect(x: 0, y: 375, width: self.view.frame.width, height: 200))
        demoWebView.loadHTMLString("<html> <body> <div style=\"text-align:center; padding-top: 25px\"> Fast Facts are fantastic. <br>The current font size is <span id=100></span>.</div> </body> </html>", baseURL: nil)
        demoWebView.delegate = self
        
        toggleButtons()
    }
    
    
    func toggleButtons(){
        highlightSwitch.on = getFromUserDefaults(Setting.Highlight) as! Bool
        shakeSwitch.on = getFromUserDefaults(Setting.Shake) as! Bool
        backgroundTextSwitch.on = getFromUserDefaults(Setting.BackgroundText) as! Bool
        
        let displayType = getFromUserDefaults(Setting.BackgroundColor) as! String
        let conversionDict = [
            "blackOnWhite": DisplayStyles.white.rawValue,
            "whiteOnBlack": DisplayStyles.black.rawValue,
            "peach": DisplayStyles.peach.rawValue
        ]
        textStyleChooser.selectedSegmentIndex = conversionDict[displayType]!
        
        highlightSwitch.addTarget(self, action: "toggleHighlight:", forControlEvents: UIControlEvents.ValueChanged)
        shakeSwitch.addTarget(self, action: "toggleShake:", forControlEvents: UIControlEvents.ValueChanged)
        backgroundTextSwitch.addTarget(self, action: "toggleBackgroundText:", forControlEvents: UIControlEvents.ValueChanged)
        fontSizeSlider.addTarget(self, action: "sliderMoved:", forControlEvents: UIControlEvents.ValueChanged)
        
        self.view.addSubview(highlightSwitch)
        self.view.addSubview(shakeSwitch)
        self.view.addSubview(backgroundTextSwitch)
        self.view.addSubview(fontSizeSlider)
        self.view.addSubview(textStyleChooser)
        self.view.addSubview(demoWebView)
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        webView.stringByEvaluatingJavaScriptFromString(getInjectJS())
    }
    
    func changeColor(sender: UISegmentedControl){
        switch sender.selectedSegmentIndex{
        case 1:
            toggleUserDefaults(Setting.BackgroundColor, to: "blackOnWhite")
            demoWebView.stringByEvaluatingJavaScriptFromString(injectableBackgroundJS(DisplayStyles.white))
        case 2:
            toggleUserDefaults(Setting.BackgroundColor, to: "peach")
            demoWebView.stringByEvaluatingJavaScriptFromString(injectableBackgroundJS(DisplayStyles.peach))
        default:
            toggleUserDefaults(Setting.BackgroundColor, to: "whiteOnBlack")
            demoWebView.stringByEvaluatingJavaScriptFromString(injectableBackgroundJS(DisplayStyles.black))
        }
    }
    
    func toggleShake(sender: UIControl){
        if shakeSwitch.on{
            toggleUserDefaults(Setting.Shake, to: true)
        }
        else{
            toggleUserDefaults(Setting.Shake, to: false)
        }
    }
    
    func toggleBackgroundText(sender: UIControl){
        if backgroundTextSwitch.on{
            toggleUserDefaults(Setting.BackgroundText, to: true)
        }
        else{
            toggleUserDefaults(Setting.BackgroundText, to: false)
        }
    }
    
    func toggleHighlight(sender: UIControl){
        if highlightSwitch.on{
            toggleUserDefaults(Setting.Highlight, to: true)
        }
        else{
            toggleUserDefaults(Setting.Highlight, to: false)
        }
    }
    
    func sliderMoved(sender: UIControl){
        let newFontSize = round(fontSizeSlider.value)
        toggleUserDefaults(Setting.FontSize, to: newFontSize)
        demoWebView.stringByEvaluatingJavaScriptFromString(getInjectJS())
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        //Adjust width of article view
        self.view.setNeedsLayout()
    }
    
}


