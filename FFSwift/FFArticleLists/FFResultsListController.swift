//
//  FFResultsListController.swift
//  FFSwift
//
//  Created by David Liu on 9/20/15.
//  Copyright © 2015 David Liu. All rights reserved.
//


import UIKit
import RealmSwift


class FFResultsListController: UITableViewController {
    
    let realm = try! Realm()
    var filteredArticles = [Int]()
    var query: String = ""
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.query != ""{
            return realm.objects(Article).filter("article_text CONTAINS[c] '\(self.query)'").count
        }
        else{
            return GlobalDBValues.count
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 90
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //Get cell
        let cell: ArticleTableCell = tableView.dequeueReusableCellWithIdentifier(ArticleTableCell.identifier, forIndexPath: indexPath) as! ArticleTableCell
        if filteredArticles.count > 0{
            let matchingArticle: Article? = GlobalDBValues.getArticle(filteredArticles[indexPath.row])
            cell.configureCell(matchingArticle)
        }
        return cell
    }
}