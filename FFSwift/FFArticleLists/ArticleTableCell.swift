//
//  ArticleTableCell.swift
//  FFSwift
//
//  Created by David Liu on 9/24/15.
//  Copyright © 2015 David Liu. All rights reserved.
//

import UIKit

class ArticleTableCell: UITableViewCell{
    
    static let identifier: String = "articleCell"
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?){
        super.init(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "articleCell")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    func configureCell(article: Article?) {
        if let aarticle = article{
            self.textLabel?.text = "\(aarticle.articleNumber) | \(aarticle.title)"
            self.textLabel?.font = UIFont.boldSystemFontOfSize(16.0)
            self.textLabel?.numberOfLines = 0
            if getFromUserDefaults(Setting.BackgroundText) as! Bool{
                self.detailTextLabel?.text = aarticle.background
                self.detailTextLabel?.numberOfLines = 3
            }
            // Because if we reuse cells without resetting then there will be some cells with extraneous info.
            else{
                self.detailTextLabel?.text = nil
                self.detailTextLabel?.numberOfLines = 0
            }
        }
    }
    
}
