//
//  Article.swift
//  FFSwift
//
//  Created by David Liu on 8/30/15.
//  Copyright © 2015 David Liu. All rights reserved.
//

import Foundation
import RealmSwift

class Article: Object{
    dynamic var articleNumber = 0
    dynamic var title = ""
    dynamic var category = ""
    dynamic var background = ""
    dynamic var article_text = ""
}


