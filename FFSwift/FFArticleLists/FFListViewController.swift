//
//  FFListViewController.swift
//  FastFactsSwift
//
//  Created by David Liu on 7/18/15.
//  Copyright (c) 2015 David Liu. All rights reserved.
//

import UIKit
import RealmSwift

class FFListViewController: UITableViewController, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating{
    
    var name: String = ""
    let realm = try! Realm()
    var searchController: UISearchController!
    var allArticles = [Int]()
    var filteredArticles = [Int]()
    var resultsTableController: FFResultsListController!
    var recentlyViewed: [Int]!
    var search: Bool = false
    var curQuery: String? = nil
    
    init(name: String?){
        self.name = name!
        let userDefaults = NSUserDefaults.standardUserDefaults()
        recentlyViewed = userDefaults.arrayForKey("recentlyViewed") as? [Int] ?? [Int]()
        allArticles = GlobalDBValues.allArticles
        filteredArticles = GlobalDBValues.allArticles
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = self.name
        //MARK: SearchController
        resultsTableController = FFResultsListController()
        resultsTableController.tableView.delegate = self
        resultsTableController.tableView.registerClass(ArticleTableCell.self, forCellReuseIdentifier: ArticleTableCell.identifier)
        
        searchController = UISearchController(searchResultsController: resultsTableController)
        searchController.searchResultsUpdater = self
        searchController.searchBar.sizeToFit()
        searchController.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        
        // MARK: tableview
        tableView.tableHeaderView = searchController.searchBar
        tableView.registerClass(ArticleTableCell.self, forCellReuseIdentifier: ArticleTableCell.identifier)
    
        definesPresentationContext = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.hidden = false
        updateRecentlyViewed()
        if getFromUserDefaults(Setting.BackgroundText) as! Bool{
            tableView.reloadData()
        }
        self.navigationController?.setToolbarHidden(true, animated: false)
    }
    
    // MARK: UISearchBarDelegate
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    // MARK: UISearchControllerDelegate
    func presentSearchController(searchController: UISearchController) {
        //debugPrint("UISearchControllerDelegate invoked method: \(__FUNCTION__).")
    }
    
    func willPresentSearchController(searchController: UISearchController) {
        //debugPrint("UISearchControllerDelegate invoked method: \(__FUNCTION__).")
    }
    
    func didPresentSearchController(searchController: UISearchController) {
        //debugPrint("UISearchControllerDelegate invoked method: \(__FUNCTION__).")
        search = true
    }
    
    func willDismissSearchController(searchController: UISearchController) {
        //debugPrint("UISearchControllerDelegate invoked method: \(__FUNCTION__).")
    }
    
    func didDismissSearchController(searchController: UISearchController) {
        //debugPrint("UISearchControllerDelegate invoked method: \(__FUNCTION__).")
        search = false
    }
    
    // MARK: UISearchResultsUpdating
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let whitespaceCharacterSet = NSCharacterSet.whitespaceCharacterSet()
        let strippedString = searchController.searchBar.text!.stringByTrimmingCharactersInSet(whitespaceCharacterSet).lowercaseString
        curQuery = strippedString
        if curQuery == "" { curQuery = nil} // No query means no highlighting!
        let resultsController = searchController.searchResultsController as! FFResultsListController
        
        let matchingArticles = realm.objects(Article).filter("article_text contains[c] '\(strippedString)'")
        let numMatchingArticles = allArticles.map{String($0)}.filter{$0.contains(strippedString)}
        var articleNumToOccurences: [Int: Int] = [:]
        for article in matchingArticles{
            articleNumToOccurences[article.articleNumber] = numberOccurences(article, query: strippedString)
        }
        for strArticleNumber in numMatchingArticles{
            let articleNumber = Int(strArticleNumber)
            var addValue = 100
            if strArticleNumber == strippedString{
                addValue = 1000
            }
            if articleNumToOccurences[articleNumber!] != nil{
                articleNumToOccurences[articleNumber!]! += addValue
            }
            else{
                articleNumToOccurences[articleNumber!] = addValue
            }
        }
        var tempFilteredArticles = [Int]()
        for (k,_) in articleNumToOccurences.sort({$1.1 < $0.1}){
            tempFilteredArticles.append(k)
        }
        filteredArticles = tempFilteredArticles
        resultsController.filteredArticles = filteredArticles
        resultsController.query = strippedString
        resultsController.tableView.reloadData()
    }
    
    // MARK: UITableViewDataSource
    enum tableSections: Int {
        case Recent = 0
        case All = 1
        static var count: Int = 2
    }
    //Sections
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Recently Viewed and all
        filteredArticles = GlobalDBValues.allArticles
        return tableSections.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == tableSections.Recent.rawValue{
            return recentlyViewed.count
        }
        else{ //section == tableSections.all
            return GlobalDBValues.count
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String {
        if section == tableSections.Recent.rawValue{
            return "Recently Viewed"
        }
        else{
            return "All Fast Facts"
        }
    }
    
    override func tableView(tableView: UITableView,
        willDisplayHeaderView view: UIView,
        forSection section: Int){
//            view.tintColor = UIColor(rgba: "#A57320")
            view.tintColor = UIColor(rgba: "#43ACE5")
    }
    
    // Reload table recently viewed
    func updateRecentlyViewed(){
        let userDefaults = NSUserDefaults.standardUserDefaults()
        recentlyViewed = userDefaults.arrayForKey("recentlyViewed") as? [Int] ?? [Int]()
        let recentlyViewedIndex = NSIndexSet(index: tableSections.Recent.rawValue)
        tableView.reloadSections(recentlyViewedIndex, withRowAnimation: UITableViewRowAnimation.None)
    }
    
    //Table
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //Get cell
        let articleNumber = getArticleNumber(indexPath)
        let matchingArticle: Article? = GlobalDBValues.getArticle(articleNumber)
        let cell: ArticleTableCell = tableView.dequeueReusableCellWithIdentifier(ArticleTableCell.identifier, forIndexPath: indexPath) as! ArticleTableCell
        cell.configureCell(matchingArticle)
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if getFromUserDefaults(Setting.BackgroundText) as! Bool{
            return 90
        }
        else{
            return 60
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var index: Int = 0
        if tableView === self.tableView {
            index = getArticleNumber(indexPath)
        }
        else {
            index = filteredArticles[indexPath.row]
        }
        if !search{
            curQuery = nil
        }
        else{
            // Logging
            if curQuery != nil{
                trackSearchQuery(curQuery!, articleNum: index)
                print(curQuery)
            }
        }
        
        self.navigationController?.pushViewController(FFArticleViewController(articleNumber: index, highlighted: search, query: curQuery), animated: true)
    }
    
    func getArticleNumber(indexPath: NSIndexPath) -> Int{
        if indexPath.section == tableSections.Recent.rawValue{
            return recentlyViewed[indexPath.row]
        }
        else{
            return allArticles[indexPath.row]
        }
    }
    

    
    
}

