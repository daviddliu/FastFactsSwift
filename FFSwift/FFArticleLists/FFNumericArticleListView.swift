//
//  FFNumericArticleListView.swift
//  FastFactsSwift
//
//  Created by David Liu on 7/18/15.
//  Copyright (c) 2015 David Liu. All rights reserved.
//

import UIKit

class FFNumericArticleListView: UITableViewController{
    
    var name: String = ""
    var articles: [Int]!
    
    init(name: String?, articles: [Int]?){
        self.name = name!
        self.articles = articles!.sort()
        super.init(nibName: nil, bundle: nil);
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.hidden = false
        self.navigationController?.setToolbarHidden(true, animated: false)
    }
    
    override func viewDidLoad() {
        self.title = self.name
        self.tableView.registerClass(ArticleTableCell.self, forCellReuseIdentifier: ArticleTableCell.identifier)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.articles.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let matchingArticle: Article? = GlobalDBValues.getArticle(articles[indexPath.row])
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
        self.navigationController?.pushViewController(FFArticleViewController(articleNumber: articles[indexPath.row]), animated: true)
    }
    
    
}

