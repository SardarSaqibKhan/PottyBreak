//
//  ArticleVC.swift
//  PottyBreak
//
//  Created by Moheed Zafar on 28/05/2019.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ArticleVC: UITableViewController {
    var artist = String()
    var des:String?
    var titleA = String()
    var path = String()
    
    
    @IBOutlet var articleTV: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        loadArticle()
        
    }
    
    
    func loadArticle()
    {
        Database.database().reference().child("Article").observe(.value) { (snapshot) in
            let Banners = snapshot.value as! [String: Any]
            let random = Int.random(in: 0 ..< Banners.count)
            var count = 0;
            for article in Banners
            {
                if count == random{
                    
                    let baner = article.value as! [String : Any]
                    self.artist = baner["artist"] as! String;
                    self.des = baner["description"] as! String;
                    self.titleA = baner["title"] as! String //Exception handle
                    self.path = baner["url"] as! String
                    DispatchQueue.main.async(execute: {
                        
                        self.articleTV.reloadData()
                    })
                }
                count = count+1;
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
         return 2
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 { return 0 }
        else { return 110 }
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0
        {
            return nil;
        }
        else
        {
            var view = Bundle.main.loadNibNamed("ArticleHeader", owner: nil, options: nil)
            var  headerView = view![0] as! UIView
            print(headerView.bounds.height)
            headerView.backgroundColor = #colorLiteral(red: 0.9724534154, green: 0.9726158977, blue: 0.9724320769, alpha: 1)
            (headerView.viewWithTag(9) as! UILabel).text = titleA
            (headerView.viewWithTag(8) as! UILabel).text = artist
            return headerView
        }
        
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0
        {
            return 2
        }
        return 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        

        // Configure the cell...
        if indexPath.section == 0 && indexPath.row == 0
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath)
            (cell.viewWithTag(9) as! UIImageView).image = UIImage(named: "daily-deuce-title")
            return cell
        }
        else if indexPath.section == 0 && indexPath.row == 1
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath)
            let imgV = cell.viewWithTag(9) as! UIImageView
            imgV.sd_setIndicatorStyle(.gray);
            imgV.sd_setShowActivityIndicatorView(true)
            imgV.sd_setImage(with: URL(string: path)) { (img, error, cacheType, url) in
                
            };
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "descriptionCell", for: indexPath)
            let descriptionLabel = (cell.viewWithTag(9) as! UILabel)
            descriptionLabel.text = des
            descriptionLabel.textAlignment = NSTextAlignment.justified
            descriptionLabel.backgroundColor = #colorLiteral(red: 0.9724534154, green: 0.9726158977, blue: 0.9724320769, alpha: 1)
            return cell
        }
    }
 


}
extension ArticleVC
{
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 || indexPath.row == 1
        {
            return 160
        }
        else if indexPath.row == 2
        {
            return 105
        }
        else
        {
            return UITableView.automaticDimension

        }
    }
    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
       
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        label.textAlignment = NSTextAlignment.justified
        label.sizeToFit()
        return label.frame.height
    }
}

