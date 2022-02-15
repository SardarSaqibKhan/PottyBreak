//
//  CustomLounchScreenVC.swift
//  PottyBreak
//
//  Created by MacBook Pro on 14/03/2019.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

import UIKit
import FirebaseAuth

class CustomLounchScreenVC: UIViewController {

    @IBOutlet weak var progressView: UIProgressView!
    
    var timer:Timer? = nil
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //perform(#selector(performingSegue), with: nil, afterDelay: 2)
        
        
        
        timer = Timer.scheduledTimer(timeInterval: 0.0003, target: self, selector: (#selector (CustomLounchScreenVC.UpdateProgreesview)), userInfo: nil, repeats: true)
    }

    @objc func UpdateProgreesview(){
         progressView.progress += 0.0002
        if progressView.progress == 1
        {
            performingSegue()
        }
    }
    
    
     func performingSegue()
    {
        
        timer!.invalidate()
            timer = nil
        if Auth.auth().currentUser != nil{
            let vc = storyboard?.instantiateViewController(withIdentifier: "mainnav")
            self.present(vc!, animated: true, completion: nil)
        }
        else{
            let nextpg = storyboard?.instantiateViewController(withIdentifier: "second")
            self.present(nextpg!, animated: true, completion: nil)
        }
    }
}
