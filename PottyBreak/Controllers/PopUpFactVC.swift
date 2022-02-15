//
//  PopUpFactVC.swift
//  PottyBreak
//
//  Created by Moheed Zafar on 22/05/2019.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

import UIKit

class PopUpFactVC: UIViewController {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UITextView!
    // @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var hideButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    var image:UIImage?
    var fact = String()
    var factDescrition = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        styling()
        setData()
        
    }
    @IBAction func hide(_ sender: Any) {
        self.view.removeFromSuperview()
    }
    
}
extension PopUpFactVC
{
    func styling()
    {
        imageView.roundImage()
        hideButton.carveButton()
        bgView.carveView()
        bgView.layer.borderColor = #colorLiteral(red: 0.180544883, green: 0.4116913378, blue: 0.6689992547, alpha: 1)
        bgView.layer.borderWidth = 5
        
    }
    func setData()
    {
        titleLabel.text = fact
        descriptionLabel.text = factDescrition
        if let img = image
        {
            imageView.image = img
        }
        
    }
    
}
