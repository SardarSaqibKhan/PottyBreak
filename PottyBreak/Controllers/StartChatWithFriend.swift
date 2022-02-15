//
//  StartChatWithFriend.swift
//  PottyBreak
//
//  Created by MacBook Pro on 02/04/2019.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

import UIKit
import AVFoundation

class StartChatWithFriend: UIViewController {
    @IBOutlet weak var animatedImage:UIImageView!
    var animatedImagesArray = [UIImage]()
     var player: AVAudioPlayer?
    var animationDelegat:AnimationProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        playSound()
        showAnimate()
        AppendingImages()
        Animate()
        
        
        let date = Date().addingTimeInterval(5)
        let timer = Timer(fireAt: date, interval: 0, target: self, selector: #selector(StartChatWithFriend.runCode), userInfo: nil, repeats: false)
        RunLoop.main.add(timer, forMode: .common)

    }
   
    func AppendingImages(){
        
        animatedImagesArray.append(UIImage(named: "1")!)
        animatedImagesArray.append(UIImage(named: "2")!)
        animatedImagesArray.append(UIImage(named: "3")!)
        animatedImagesArray.append(UIImage(named: "4")!)
        animatedImagesArray.append(UIImage(named: "5")!)
        animatedImagesArray.append(UIImage(named: "6")!)
        animatedImagesArray.append(UIImage(named: "7")!)
        animatedImagesArray.append(UIImage(named: "8")!)
        animatedImagesArray.append(UIImage(named: "9")!)
        animatedImagesArray.append(UIImage(named: "10")!)
        
                
    }
    func Animate()
    {

        self.animatedImage.animationImages = self.animatedImagesArray
        self.animatedImage.animationDuration  = 1.5
        self.animatedImage.startAnimating()
    }
    
  
    func PerfomUnWindeSegue(){
         // performSegue(withIdentifier: "myunwindsegue", sender: self)
          view.removeFromSuperview()
        //animationDelegat?.removeAnimation()
      
        
    }
    func stopAnimation(){
//        let vc = storyboard?.instantiateViewController(withIdentifier: "MyChatViewController") as! MyChatViewController
//        vc.dismiss(animated: true, completion: nil)
        
        self.animatedImage.stopAnimating()
        self.player?.stop()
        self.dismiss(animated: true, completion: nil)
        animationDelegat?.removeAnimation()
       
    }
    @objc func runCode(){
        
       stopAnimation()
    }

}
extension StartChatWithFriend{
    func playSound() {
        guard let url = Bundle.main.url(forResource: "ToiletSound", withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            /* iOS 10 and earlier require the following line:
             player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */
            
            guard let player = player else { return }
            
            player.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
//////////////for pop up animation
extension StartChatWithFriend{
  
    func showAnimate()
    {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0;
        UIView.animate(withDuration: 0.5, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        });
    }
    
    func removeAnimate()
    {
        UIView.animate(withDuration: 0.5, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0;
        }, completion:{(finished : Bool)  in
            if (finished)
            {
                self.view.removeFromSuperview()
            }
        });
    }
}
