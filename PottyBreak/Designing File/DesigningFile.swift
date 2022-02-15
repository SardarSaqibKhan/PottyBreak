//
//  DesigningFile.swift
//  PottyBreak
//
//  Created by MacBook Pro on 14/03/2019.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

import Foundation
import UIKit
extension UIButton{
    
    func loginButtonDesign(){
        self.layer.cornerRadius = 20
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowRadius = 5
        self.layer.shadowOpacity = 1.5
        //self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowOffset =    CGSize(width: 5.0, height: 5.0)
        //self.layer.shadowOffset = CGSize.zero
    }
    func customCheckBoxs(){
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 0.5
    }
    
    func carveButton(){
        self.layer.cornerRadius = 5
        
    }
    func carveLoginButton(){
        self.layer.cornerRadius = 7
        self.layer.masksToBounds = true
    }
}
extension UITextView
{
    func carveTextview()
    {
        self.layer.cornerRadius = 5
    }
    func border()
    {
        self.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        self.layer.borderWidth = 0.5
        
    }
}
extension UIImageView{
    func customCheckBoxs(){
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 0.5
    }
    func addNewImage(){
        self.layer.borderColor = UIColor.blue.withAlphaComponent(0.5).cgColor
        self.layer.borderWidth = 1.5
    }
    func roundImage(){
        self.layer.cornerRadius = self.frame.width /  2
        self.clipsToBounds = true
        self.layer.borderColor = UIColor.red.cgColor
        self.layer.borderWidth = 0.5
    }
    func circleImage(color:UIColor? = UIColor.white)
    {
        self.layer.borderWidth = 3
        self.layer.masksToBounds = false
        self.layer.borderColor = color?.cgColor
        self.layer.cornerRadius = self.frame.height/2
        self.clipsToBounds = true
    }

}
extension UIView{
    
    func carveView(){
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
        
    }
    func carveViewborder(){
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
        self.layer.borderWidth = 0.5
        self.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
    }
}
extension UICollectionView{
    func hightLightBorder(){
        self.layer.cornerRadius = 2
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 0.5
    }
}
