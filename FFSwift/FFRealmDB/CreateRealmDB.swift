//
//  CreateRealmDB.swift
//  FFSwift
//
//  Created by David Liu on 8/30/15.
//  Copyright © 2015 David Liu. All rights reserved.
//

import Foundation
import RealmSwift

func seedFFDB(){
    let realm = try! Realm()
    try! realm.write {
        realm.deleteAll()
    }
    // Change this if rnuning on a different computer
    let filePath: String = "/Users/ddliu/Desktop/FFSwift/PalliativeScraper/new_fast_facts_data.txt"
    try! realm.write{
        if let aStreamReader = StreamReader(path: filePath) {
            defer {
                aStreamReader.close()
            }
            while let line = aStreamReader.nextLine() {
                var articleDatum = line.componentsSeparatedByString("|")
                let articleNumber: Int = Int(articleDatum[0])!
                realm.add(Article(value: ["articleNumber": articleNumber, "title": articleDatum[1], "category": articleDatum[2], "background": articleDatum[3], "article_text": articleDatum[4]]))
            }
        }
    }
}

func loadRealmFile(){
    var db_path = NSBundle.mainBundle().pathForResource("prod_db.realm", ofType: nil)
    var config = Realm.Configuration()
    config.fileURL = NSURL(fileURLWithPath: db_path!)
    config.readOnly = true
    Realm.Configuration.defaultConfiguration = config
}

let nonGlobalRealm = try! Realm()

func allArticlesList(numArticles: Int) -> [Int]{
    // Exclude these from the table views
    var articles: [Int] = [Int]()
    for num in [Int](1...numArticles){
        articles.append(num)
    }
    return articles
}

struct GlobalDBValues{
    static var count = nonGlobalRealm.objects(Article).count
    static var allArticles = allArticlesList(count)
    static var distinctSubjectsArr = distinctSubjects()
    static var articleCache: [Int: Article] = [:]
    static func getArticleNumber(articleNum: Int) -> Article {
        if let article = nonGlobalRealm.objects(Article).filter("articleNumber = \(articleNum)").first{
            return article
        }
        else{
            let number = Int(arc4random_uniform(UInt32(GlobalDBValues.count - 1))) + 1
            return nonGlobalRealm.objects(Article).filter("articleNumber = \(number)").first!
        }
    }
    static func getArticle(articleNum: Int) -> Article{
        if articleCache[articleNum] != nil{
            // Do nothing
        }
        else{
            articleCache[articleNum] = getArticleNumber(articleNum)
        }
        return articleCache[articleNum]!
    }
}