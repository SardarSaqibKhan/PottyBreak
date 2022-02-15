//
//  SubmitPopVC.swift
//  DrawPad
//
//  Created by abdul on 30/05/2019.
//  Copyright © 2019 Ray Wenderlich. All rights reserved.
//

import UIKit

class SubmitPopVC: UIViewController {

  var delagate : saveimagedelagate?
    @IBOutlet weak var popview: UIView!
    @IBOutlet weak var yesbtn: UIButton!
    @IBOutlet weak var nobtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
       popview.layer.cornerRadius = 10
        yesbtn.carve()
        nobtn.carve()
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
      
        // Do any additional setup after loading the view.
    }
  
    
    @IBAction func yesbtnaction(_ sender: Any) {
      
      delagate?.save()
        let vc = storyboard?.instantiateViewController(withIdentifier: "GalleryVC") as! GalleryVC
      
      self.present(vc, animated: true, completion: nil)
      
       self.view.removeFromSuperview()
      
    }
    @IBAction func nobtnaction(_ sender: Any) {
      
     
        self.view.removeFromSuperview()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
