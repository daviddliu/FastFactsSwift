//
//  FFSubjectViewController.swift
//  FastFactsSwift
//
//  Created by David Liu on 7/18/15.
//  Copyright (c) 2015 David Liu. All rights reserved.
//

import UIKit
import RealmSwift

class FFSubjectViewController: UITableViewController{
    
    var name: String = ""
    let realm = try! Realm()
    var subjects: [String]!
    var coreSubjects: [String: [Int]]!
    var coreNames: [String]!
    var allCategories: Bool = true
    
    init(name: String?){
        self.name = name!
        self.subjects = distinctSubjects()
        coreSubjects = [
            "Communication": [11, 155, 162, 183, 184, 19, 21, 22, 222, 223, 224, 225, 226, 227, 23, 24, 274, 47, 6, 64, 76, 77],
            "Neurology": [115, 135, 150, 201, 229, 234, 237, 238, 239, 299, 300, 301, 62],
            "Oncology": [116, 129, 13, 135, 14, 151, 157, 173, 176, 177, 190, 209, 236, 237, 238, 285, 297, 62, 91, 99],
            "Hospice": [139, 140, 246, 247, 38, 82],
            "Non-Pain Symptoms": [1, 109, 114, 146, 149, 15, 158, 182, 186, 199, 200, 218, 229, 256, 27, 282, 5, 60, 81, 96],
            "Ethics": [115, 155, 164, 165, 178, 219, 242, 292, 55, 8],
            "Prognosis": [125, 13, 141, 143, 150, 189, 191, 234, 235, 239, 3, 99],
            "Nutrition": [10, 128, 133, 134, 190, 220, 84],
            "Syndromes": [135, 151, 157, 176, 177, 188, 209, 238, 62],
            "Cardiac": [11, 112, 143, 144, 205, 209, 283, 296],
            "Emergency > Communication": [11, 155, 183, 184, 21, 22, 223, 224, 225, 226, 227, 23, 24, 305, 6, 64, 76, 77],
            "Emergency > Hospice and Palliative Care": [246, 247, 298],
            "Emergency > Non-Pain Symptoms": [297, 3],
            "Emergency > Other": [125, 269, 4],
            "Emergency > Pain Opioids": [20, 215, 248, 36, 74, 94],
            "Emergency > Ventilator Issues": [122, 230, 33, 34],
            "Pain > Opioid Order Writing": [18, 20, 215, 28, 36, 51, 72, 74, 92, 94],
            "Pain > Opioid Products": [103, 185, 2, 268, 290, 307, 51, 53, 75, 80],
            "Pain > Opioid Toxicity": [142, 161, 175, 248, 25, 260, 294, 295, 39, 57, 58],
            "Pain > Other": [117, 148, 187, 271, 272, 288, 289, 49, 85],
            "Pain > Substance Abuse": [110, 127, 244, 68, 69, 95]
        ]
        coreNames = [String](coreSubjects.keys)
        coreNames.sortInPlace()
        super.init(nibName: nil, bundle: nil);
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        self.title = self.name
        self.tableView = UITableView(frame: self.tableView.frame, style: .Grouped)
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        let segControl = UISegmentedControl(items: ["All Categories", "Core Curriculum"])
        segControl.layer.borderColor = UIColor(rgba: "#307ca5").CGColor;
        segControl.layer.cornerRadius = 0.0;
        segControl.layer.borderWidth = 1.5;
        segControl.selectedSegmentIndex = 0
        segControl.addTarget(self, action: "switchCategories:", forControlEvents: .ValueChanged)
        self.tableView.tableHeaderView = segControl
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if allCategories{
            return distinctSubjects().count
        }
        else{
            return coreNames.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //Get cell
        let cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell!
        if allCategories{
            cell.textLabel?.text = self.subjects[indexPath.row]
        }
        else{
            cell.textLabel?.text = self.coreNames[indexPath.row]
        }
        return cell
    }
    
    // Swift version
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        // remove bottom extra 20px space.
        return CGFloat.min
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if allCategories{
            let subject: String = self.subjects[indexPath.row]
            let subjectArticles = realm.objects(Article).filter("category CONTAINS[c] '\(subject)'")
            var articleNumbers = [Int]()
            for article in subjectArticles{
                articleNumbers.append(article.articleNumber)
            }
            self.navigationController?.pushViewController(FFNumericArticleListView(name: "\(subject)", articles: articleNumbers), animated: true)
        }
        else{
            let subjectArticleNumbers = self.coreSubjects[coreNames[indexPath.row]]
            self.navigationController?.pushViewController(FFNumericArticleListView(name: "\(coreNames[indexPath.row])", articles: subjectArticleNumbers), animated: true)
        }
    }
    
    func switchCategories(sender: UIButton){
        allCategories = !allCategories
        tableView.reloadData()
    }
    
}

