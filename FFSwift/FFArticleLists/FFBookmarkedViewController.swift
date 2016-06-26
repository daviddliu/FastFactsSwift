//
//  FFBookmarkedViewController.swift
//  FastFactsSwift
//
//  Created by David Liu on 7/18/15.
//  Copyright (c) 2015 David Liu. All rights reserved.
//

import UIKit

class FFBookmarkedViewController: UITableViewController{
    
    var name: String = ""
    var bookmarked: [Int]!
    
    init(name: String?){
        self.name = name!
        let userDefaults = NSUserDefaults.standardUserDefaults()
        self.bookmarked = userDefaults.arrayForKey("bookmarked") as? [Int] ?? [Int]()
        bookmarked.sortInPlace()
        super.init(nibName: nil, bundle: nil);
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func bookmarksUpdated(){
        let userDefaults = NSUserDefaults.standardUserDefaults()
        self.bookmarked = userDefaults.arrayForKey("bookmarked") as? [Int] ?? [Int]()
        bookmarked.sortInPlace()
        tableView.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.hidden = false
        self.navigationController?.setToolbarHidden(true, animated: false)
    }
    
    override func viewDidLoad() {
        self.title = self.name
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "titleCell")
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.bookmarked.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //Get cell
        let matchingArticle: Article = GlobalDBValues.getArticle(bookmarked[indexPath.row])
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("titleCell", forIndexPath: indexPath)
        // Never want background text here.
        cell.textLabel?.text = "\(matchingArticle.articleNumber) | \(matchingArticle.title)"
        cell.textLabel?.font = UIFont.boldSystemFontOfSize(16.0)
        cell.textLabel?.numberOfLines = 0
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.navigationController?.pushViewController(FFArticleViewController(articleNumber: bookmarked[indexPath.row]), animated: true)
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            var newBookmarked = userDefaults.arrayForKey("bookmarked") as? [Int] ?? [Int]()
            newBookmarked.sortInPlace()
            newBookmarked.removeAtIndex(indexPath.row)
            userDefaults.setObject(newBookmarked, forKey: "bookmarked")
            bookmarksUpdated()
        }
    }

}

