//
//  GamePlayVC.swift
//  DrawPad
//
//  Created by abdul on 29/05/2019.
//  Copyright © 2019 Ray Wenderlich. All rights reserved.
//

import UIKit
import HueKit
protocol saveimagedelagate : class {
  func save()
}


class GamePlayVC: UIViewController {

  var imagenames = String()
  var namecounter = Int()
  var lastPoint = CGPoint.zero
  var color = UIColor.red
  var brushWidth: CGFloat = 5.0
  var opacity: CGFloat = 1.0
  var swiped = false
 
  @IBOutlet weak var colorbarpicker: ColorBarPicker!
    @IBOutlet weak var tissuerollview: UIView!
    
    @IBOutlet weak var tissueimg: UIImageView!
    
    @IBOutlet weak var animatetissue: UIImageView!
    @IBOutlet weak var animateview: UIView!
    
  @IBOutlet weak var colorindicatorview: ColorIndicatorView!
  @IBOutlet weak var afterdrawingimg: UIImageView!
  @IBOutlet weak var drawimg: UIImageView!
  
  @IBOutlet weak var submitbtn: UIButton!
  override func viewDidLoad() {
        super.viewDidLoad()
      submitbtn.carve()
    if let value = UserDefaults.standard.string(forKey: "imagenames") 
    {
      namecounter = UserDefaults.standard.integer(forKey: "namecounter")
      imagenames =  UserDefaults.standard.string(forKey: "imagenames")!
    }
    //afterdrawingimg.image = UIImage(named: "img_tissue_wrap")
    setGestureOnCameraIcon()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        animte()
        
    }
    func animte()
    {
        self.animateview.isHidden = true
        self.animateview.transform = CGAffineTransform(translationX: 0, y: 0)
        
        UIView.animate(withDuration: 0.4, delay: 0.2, options: .transitionCurlUp, animations: {
            self.animateview.isHidden = false
            self.animateview.transform = CGAffineTransform(translationX: 0, y: 1520)
            self.afterdrawingimg.image = nil
            //self.animatetissue.image = nil
            self.drawimg.image = nil
            // self.animateview.isHidden = true
            // self.animateview.transform = CGAffineTransform(translationX: 0, y: -320)
            //self.backgroundView.transform = CGAffineTransform.init(scaleX: 1   , y:   1)
        }) { (res) in
            if res
            {
                self.animatetissue.image = UIImage(named: "img_tissue_wrap-1")
            }
        }
        
    }

  
  @IBAction func colorbarpickeraction(_ sender: ColorBarPicker) {
  print(colorbarpicker.hue)
     var colorbox = ColorIndicatorView()
//    color = UIColor(white: sender.hue, alpha: 1
//    )
    //colorindicatorview.color = UIColor.init()
    color = UIColor(hue: CGFloat(sender.hue), saturation: 1, brightness: 1, alpha: 1)
    
  }
  
  
  @IBAction func backbtn(_ sender: Any) {
    self.dismiss(animated: false, completion: nil)
  }
  
  @IBAction func submitbtnaction(_ sender: Any) {
    
    let vc1 = storyboard?.instantiateViewController(withIdentifier: "SubmitPopVC") as! SubmitPopVC
    vc1.delagate = self
    self.addChild(vc1)
    vc1.view.frame = self.view.frame
    self.view.addSubview(vc1.view)
    vc1.didMove(toParent: self)
    
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
extension UIButton
{
    func carve()
    {
        self.layer.cornerRadius = 10
    }
}
extension GamePlayVC
{
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else {
      return
    }
    swiped = false
    lastPoint = touch.location(in: drawimg)
  }
  
  func drawLine(from fromPoint: CGPoint, to toPoint: CGPoint) {
    // 1
    UIGraphicsBeginImageContext(drawimg.frame.size)
    // UIGraphicsBeginImageContext(view.frame.size)
    guard let context = UIGraphicsGetCurrentContext() else {
      return
    }
    drawimg.image?.draw(in: afterdrawingimg.bounds)
    
    //tempImageView.image?.draw(in: view.bounds)
    
    // 2
    context.move(to: fromPoint)
    context.addLine(to: toPoint)
    
    // 3
    context.setLineCap(.round)
    context.setBlendMode(.normal)
    context.setLineWidth(brushWidth)
    context.setStrokeColor(color.cgColor)
    
    // 4
    context.strokePath()
    
    // 5
    drawimg.image = UIGraphicsGetImageFromCurrentImageContext()
    drawimg.alpha = opacity
    UIGraphicsEndImageContext()
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else {
      return
    }
    
    // 6
    swiped = true
    let currentPoint = touch.location(in: drawimg)
    drawLine(from: lastPoint, to: currentPoint)
    
    // 7
    lastPoint = currentPoint
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    if !swiped {
      // draw a single point
      drawLine(from: lastPoint, to: lastPoint)
    }
    
    // Merge tempImageView into mainImageView
    UIGraphicsBeginImageContext(afterdrawingimg.frame.size)
    //animatetissue.image?.draw(in: animatetissue.bounds, blendMode: .normal, alpha: 1.0)
    afterdrawingimg.image?.draw(in: afterdrawingimg.bounds, blendMode: .normal, alpha: 1.0)
    drawimg?.image?.draw(in: afterdrawingimg.bounds, blendMode: .normal, alpha: opacity)
    afterdrawingimg.image = UIGraphicsGetImageFromCurrentImageContext()
    //animatetissue.image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    UIGraphicsBeginImageContext(animatetissue.frame.size)
    animatetissue.image?.draw(in: animatetissue.bounds, blendMode: .normal, alpha: 1.0)
    drawimg?.image?.draw(in: animatetissue.bounds, blendMode: .normal, alpha: opacity)
    animatetissue.image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    drawimg.image = nil
  }
  
}

extension GamePlayVC
{
    func setGestureOnCameraIcon(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(GamePlayVC.handleTap(_:)))
        tissuerollview.addGestureRecognizer(tap)
        
    }
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        
       animte()
        //animatetissue.image = UIImage(named: "img_tissue_wrap")
    }
}

extension GamePlayVC: saveimagedelagate
{
  func save() {
    if namecounter == nil
    {
      namecounter = 1
    }
    else
    {
      namecounter = namecounter+1
    }
    var name = "image" + String(namecounter)
    
    var data = Data()
    var yourDataImagePNG = animatetissue.image!.pngData()
    UserDefaults().set(yourDataImagePNG, forKey: name)
    imagenames.append(" ")
    imagenames.append(name)
    UserDefaults.standard.set(imagenames, forKey: "imagenames")
    UserDefaults.standard.set(namecounter
      , forKey: "namecounter")
    
  }
  
  
}
