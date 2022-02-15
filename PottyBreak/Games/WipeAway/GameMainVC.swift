//
//  GameMainVC.swift
//  DrawPad
//
//  Created by abdul on 29/05/2019.
//  Copyright © 2019 Ray Wenderlich. All rights reserved.
//

import UIKit

class GameMainVC: UIViewController {

    @IBOutlet weak var StartBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
    StartBtn.carve()
//      var color = UIColor(hue: 0.60, saturation: 100, brightness: 100, alpha: 1)
//      StartBtn.backgroundColor = color
        // Do any additional setup after loading the view.
    }
    

  @IBAction func backbtn(_ sender: Any) {
    self.dismiss(animated: false, completion: nil)
  }
  @IBAction func Startbtnaction(_ sender: UIButton) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "GameStartVC") as! GameStartVC
        self.present(vc, animated: false, completion: nil)
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
