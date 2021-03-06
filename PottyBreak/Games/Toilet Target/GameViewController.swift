//
//  GameViewController.swift
//  PaperToss
//
//  Created by steve on 10/1/17.
//  Copyright © 2017 Steve Richardson. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
protocol dismissdelagate : class{
    func dismissgame()
}

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFit
                scene.size = self.view.bounds.size
                //scene.delegate = self
                
                // Present the scene
                view.presentScene(scene)
            }
            

        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .portrait
        } else {
            return .portrait
        }
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension GameViewController : dismissdelagate
{
    func dismissgame() {
        self.dismiss(animated: false, completion: nil)
    }
    
    
}
