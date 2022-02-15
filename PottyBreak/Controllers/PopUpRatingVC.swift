//
//  PopUpRatingVC.swift
//  PottyBreak
//
//  Created by Moheed Zafar Hashmi on 09/05/2019.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

import UIKit
import Cosmos

class PopUpRatingVC: UIViewController {
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
  
    @IBOutlet weak var closeOutlet: UIButton!
    @IBOutlet weak var rateNowOutlet: UIButton!
    
    var address = String()
    var titleForLabel = String()
    var id = String()
    var delegate:RateNowDelegate?;
    override func viewDidLoad() {
        super.viewDidLoad()
        styling()
        setData()
        // Do any additional setup after loading the view.
    }
    @IBAction func rateNow(_ sender: Any) {
        //Send Ratings
        
        self.view.removeFromSuperview()
        delegate?.rateNow()
    }
    @IBAction func close(_ sender: Any) {
        resetRatingFlags()
        self.view.removeFromSuperview()
    }
    func resetRatingFlags()
    {
        UserDefaults.standard.removeObject(forKey: "placeID")
        UserDefaults.standard.removeObject(forKey: "title")
        UserDefaults.standard.removeObject(forKey: "address")
    }


}
extension PopUpRatingVC
{
    func styling()
    {
       closeOutlet.carveButton()
       rateNowOutlet.carveButton()
        
       backgroundView.carveView()
       backgroundView.layer.borderColor = #colorLiteral(red: 0.180544883, green: 0.4116913378, blue: 0.6689992547, alpha: 1)
       backgroundView.layer.borderWidth = 5
       
    }
    func setData()
    {
        titleLabel.text = titleForLabel
        addressLabel.text = address
        
    }
 
}
