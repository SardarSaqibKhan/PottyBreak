//
//  WashRoomImageVC.swift
//  PottyBreak
//
//  Created by MacBook Pro on 27/05/2019.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

import UIKit
import SDWebImage

class WashRoomImageVC: UIViewController {

    @IBOutlet weak var washroomImageView: UIImageView!
    
    let groupDownload = DispatchGroup()
    var recivedImagePath = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        showImage()
        settingTapGesturse()

    }
    
    func showImage(){
        groupDownload.enter()
        washroomImageView.sd_setIndicatorStyle(.gray);
        washroomImageView.sd_setShowActivityIndicatorView(true)
        
        washroomImageView.sd_setImage(with: URL(string: recivedImagePath)) { (img, error, cacheType, url) in
            
            self.groupDownload.leave()
            
        };
    }
    func dismissPopUpView(){
        
    }

}
extension WashRoomImageVC{
    
    func settingTapGesturse(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(WashRoomImageVC.handleTap(_:)))
        self.view.addGestureRecognizer(tap)
        
    }
    
    // function which is triggered when handleTap is called
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
       self.view.removeFromSuperview()
        
    }
}
