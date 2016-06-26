//
//  Analytics.swift
//  Fast Facts
//
//  Created by David Liu on 10/16/15.
//  Copyright © 2015 David Liu. All rights reserved.
//

import Foundation
import Amplitude_iOS


// What articles were opened?: Added
func trackArticleOpened(articleNum: Int, active: String){
    let event: [NSString : NSString] = [
        "articleNumber": String(articleNum),
        "activeTab": active
    ]
    Amplitude.instance().logEvent("article_opened", withEventProperties: event)
}

// What was the search query when an article was opened given that search was on?: Added
func trackSearchQuery(query: String, articleNum: Int){
    let event: [NSString : NSString]  = [
        "searchTerm": query,
        "articleNumber": String(articleNum)
    ]
    Amplitude.instance().logEvent("search_initiated", withEventProperties: event)
}

// Which tab was opened?: Removed 1.0.6
//func trackTabOpened(tabName: String){
//    let event: [NSString : NSString]  = [
//        "tabName": tabName
//    ]
//    Amplitude.instance().logEvent("tab_opened", withEventProperties: event)
//}

// Bookmarked: Added
func trackBookmarked(articleNum: Int){
    let event: [NSString : NSString]  = [
        "articleNumber": String(articleNum)
    ]
    Amplitude.instance().logEvent("article_bookmarked", withEventProperties: event)
}

// Shared: Added
func trackShared(articleNum: Int){
    let event: [NSString : NSString]  = [
        "articleNumber": String(articleNum)
    ]
    Amplitude.instance().logEvent("article_shared", withEventProperties: event)
}
