//
//  BasicDataStructures.swift
//  FastFactsSwift
//
//  Created by David Liu on 6/27/15.
//  Copyright (c) 2015 David Liu. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

//CUSTOM CLASSES

func distinctSubjects() -> [String]{
    let realm = try! Realm()
    let aloa = realm.objects(Article)
    var alos = [String]()
    for article in aloa{
        alos.append(article.category)
    }
    var distinctSubjects: Set<String> = Set()
    for csSubject in alos{
        for subject in csSubject.componentsSeparatedByString(";"){
            distinctSubjects.insert(subject)
        }
    }
    // Convert back to array for order
    var subjects = [String]()
    for subject in distinctSubjects{
        subjects.append(subject)
    }
    subjects.sortInPlace()
    return subjects
}

func compressString(aString: String) -> String {
    // create an inverted set
    let notLetterSet = NSCharacterSet.letterCharacterSet().invertedSet
    // get your string components separated by the notLetterSet
    let lettersOnlyArray = aString.componentsSeparatedByCharactersInSet(notLetterSet)
    // return the joined result
    return lettersOnlyArray.joinWithSeparator("")
}


func findCategory(aString: String) -> String{
    let subjects = GlobalDBValues.distinctSubjectsArr
    var subjectDict: [String:String] = [:]
    let compressedString = compressString(aString.lowercaseString)
    for subject in subjects{
        subjectDict[compressString(subject.lowercaseString)] = subject
    }
    for (compressed, full) in subjectDict{
        if compressed == compressedString{
            return full
        }
    }
    return "Error"
}

func matchLinkToCategoryArticles(linkCategory: String) -> [Int]{
    let realm = try! Realm()
    let subject = findCategory(linkCategory)
    let subjectArticles = realm.objects(Article).filter("category CONTAINS[c] '\(subject)'")
    var articleNumbers = [Int]()
    for article in subjectArticles{
        articleNumbers.append(article.articleNumber)
    }
    return articleNumbers
//    self.navigationController?.pushViewController(FFNumericArticleListView(name: "Subject: \(subject)", articles: articleNumbers), animated: true)
}

func numberOccurences(article: Article, query: String) -> Int{
    return (article.article_text.lowercaseString.componentsSeparatedByString(query).count - 1) + (article.title.lowercaseString.componentsSeparatedByString(query).count - 1) * 200
}

func addToRecentlyViewed(recentlyViewed : [Int], articleNumber: Int) -> [Int]{
    var updatedViewed = recentlyViewed
    if let foundIndex = updatedViewed.indexOf(articleNumber){
        updatedViewed.removeAtIndex(foundIndex)
    }
    if updatedViewed.count >= 10{
        updatedViewed.removeAtIndex(0)
    }
    updatedViewed.insert(articleNumber, atIndex: 0)
    return updatedViewed
}


//UI SUPPORT METHODS

extension UIView {
    var viewHeight:CGFloat {
        get {
            return self.bounds.height
        }
    }
    var viewWidth:CGFloat {
        get {
            return self.bounds.width
        }
    }
}


func setSearchBarMasks(searchBar: UISearchBar){
    searchBar.autoresizingMask =
        [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleBottomMargin];
}

func setButtonMasks(button: UIButton){
    button.autoresizingMask =
        [UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleRightMargin, UIViewAutoresizing.FlexibleTopMargin, UIViewAutoresizing.FlexibleTopMargin]
}

func addButtonToHomeView(homeView: UIView, pathToImage: String, posX: Float, posY: Float, scale: Float) -> UIButton{
    let height = homeView.viewHeight
    let width = homeView.viewWidth
    let imageToInsert: UIImage = UIImage(named: pathToImage)!
    let returnButton: UIButton = UIButton(frame: CGRect(x: width * CGFloat(posX), y: height * CGFloat(posY), width: CGFloat(CGFloat(scale) * imageToInsert.size.width), height: CGFloat(CGFloat(scale) * imageToInsert.size.height)))
    returnButton.setImage(imageToInsert, forState: UIControlState.Normal)
    homeView.addSubview(returnButton)
    return returnButton
}

extension UIColor {
    public convenience init(rgba: String) {
        var red:   CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue:  CGFloat = 0.0
        var alpha: CGFloat = 1.0
        
        if rgba.hasPrefix("#") {
            let index   = rgba.startIndex.advancedBy(1) //advance(rgba.startIndex, 1)
            let hex     = rgba.substringFromIndex(index)
            let scanner = NSScanner(string: hex)
            var hexValue: CUnsignedLongLong = 0
            if scanner.scanHexLongLong(&hexValue) {
                switch (hex.characters.count) {
                case 3:
                    red   = CGFloat((hexValue & 0xF00) >> 8)       / 15.0
                    green = CGFloat((hexValue & 0x0F0) >> 4)       / 15.0
                    blue  = CGFloat(hexValue & 0x00F)              / 15.0
                case 4:
                    red   = CGFloat((hexValue & 0xF000) >> 12)     / 15.0
                    green = CGFloat((hexValue & 0x0F00) >> 8)      / 15.0
                    blue  = CGFloat((hexValue & 0x00F0) >> 4)      / 15.0
                    alpha = CGFloat(hexValue & 0x000F)             / 15.0
                case 6:
                    red   = CGFloat((hexValue & 0xFF0000) >> 16)   / 255.0
                    green = CGFloat((hexValue & 0x00FF00) >> 8)    / 255.0
                    blue  = CGFloat(hexValue & 0x0000FF)           / 255.0
                case 8:
                    red   = CGFloat((hexValue & 0xFF000000) >> 24) / 255.0
                    green = CGFloat((hexValue & 0x00FF0000) >> 16) / 255.0
                    blue  = CGFloat((hexValue & 0x0000FF00) >> 8)  / 255.0
                    alpha = CGFloat(hexValue & 0x000000FF)         / 255.0
                default:
                    print("Invalid RGB string, number of characters after '#' should be either 3, 4, 6 or 8")
                }
            } else {
                print("Scan hex error")
            }
        } else {
            print("Invalid RGB string, missing '#' as prefix")
        }
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
}

class StreamReader  {
    
    let encoding : UInt
    let chunkSize : Int
    
    var fileHandle : NSFileHandle!
    let buffer : NSMutableData!
    let delimData : NSData!
    var atEof : Bool = false
    
    init?(path: String, delimiter: String = "\n", encoding : UInt = NSUTF8StringEncoding, chunkSize : Int = 4096) {
        self.chunkSize = chunkSize
        self.encoding = encoding
        
        if let fileHandle = NSFileHandle(forReadingAtPath: path),
            delimData = delimiter.dataUsingEncoding(encoding),
            buffer = NSMutableData(capacity: chunkSize)
        {
            self.fileHandle = fileHandle
            self.delimData = delimData
            self.buffer = buffer
        } else {
            self.fileHandle = nil
            self.delimData = nil
            self.buffer = nil
            return nil
        }
    }
    
    deinit {
        self.close()
    }
    
    /// Return next line, or nil on EOF.
    func nextLine() -> String? {
        precondition(fileHandle != nil, "Attempt to read from closed file")
        
        if atEof {
            return nil
        }
        
        // Read data chunks from file until a line delimiter is found:
        var range = buffer.rangeOfData(delimData, options: [], range: NSMakeRange(0, buffer.length))
        while range.location == NSNotFound {
            let tmpData = fileHandle.readDataOfLength(chunkSize)
            if tmpData.length == 0 {
                // EOF or read error.
                atEof = true
                if buffer.length > 0 {
                    // Buffer contains last line in file (not terminated by delimiter).
                    let line = NSString(data: buffer, encoding: encoding)
                    
                    buffer.length = 0
                    return line as String?
                }
                // No more lines.
                return nil
            }
            buffer.appendData(tmpData)
            range = buffer.rangeOfData(delimData, options: [], range: NSMakeRange(0, buffer.length))
        }
        
        // Convert complete line (excluding the delimiter) to a string:
        let line = NSString(data: buffer.subdataWithRange(NSMakeRange(0, range.location)),
            encoding: encoding)
        // Remove line (and the delimiter) from the buffer:
        buffer.replaceBytesInRange(NSMakeRange(0, range.location + range.length), withBytes: nil, length: 0)
        
        return line as String?
    }
    
    /// Start reading from the beginning of file.
    func rewind() -> Void {
        fileHandle.seekToFileOffset(0)
        buffer.length = 0
        atEof = false
    }
    
    /// Close the underlying file. No reading must be done after calling this method.
    func close() -> Void {
        fileHandle?.closeFile()
        fileHandle = nil
    }
}

extension StreamReader : SequenceType {
    func generate() -> AnyGenerator<String> {
        return anyGenerator {
            return self.nextLine()
        }
    }
}

extension String {
    
    func contains(find: String) -> Bool{
        return self.rangeOfString(find) != nil
    }
}
