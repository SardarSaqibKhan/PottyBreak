//
//  GameStartVC.swift
//  DrawPad
//
//  Created by abdul on 29/05/2019.
//  Copyright © 2019 Ray Wenderlich. All rights reserved.
//

import UIKit

class GameStartVC: UIViewController {

    @IBOutlet weak var swipedownbtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
      swipedownbtn.carve()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func swipedownbtnaction(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "GamePlayVC") as! GamePlayVC
        self.present(vc, animated: false, completion: nil)
    }
  
  @IBAction func backbtn(_ sender: Any) {
    self.dismiss(animated: false, completion: nil)
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
