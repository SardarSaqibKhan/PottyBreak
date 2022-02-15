//
//  ViewArticleDetail.swift
//  PoutyBrakeAdminSide
//
//  Created by Saim Ali on 03/04/2019.
//  Copyright © 2019 Saim Ali. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ViewArticleDetail: UIViewController {
    
    var Articletitle = String()
    var Articlewritter = String()
    var Articleimg = String()
    var Articledescription = String()
    
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var lbltitle: UILabel!
    @IBOutlet weak var lblwritter: UILabel!
    @IBOutlet weak var txtdescription: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadArticle()
      
        
        // Do any additional setup after loading the view.
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
                    var artist = baner["artist"] as! String;
                    var des = baner["description"] as! String;
                    var titleA = baner["title"] as! String //Exception handle
                    var url = baner["url"] as! String
                    DispatchQueue.main.async(execute: {
                       
                        self.lbltitle.text = titleA
                        self.lblwritter.text = artist
                        self.txtdescription.text = des
                        
                        self.img.sd_setIndicatorStyle(.gray);
                        self.img.sd_setShowActivityIndicatorView(true)
                        
                        let path = url;
                        print(path);
                        
                        self.img.sd_setImage(with: URL(string: path)) { (img, error, cacheType, url) in
                            
                            
                        };
                        
                    })
                }
                count = count+1;
            }
        }
    }
    
}
