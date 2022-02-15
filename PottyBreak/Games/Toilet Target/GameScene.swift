//
//  GameScene.swift
//  PaperToss
//
//  Created by steve on 10/1/17.
//  Copyright © 2017 Steve Richardson. All rights reserved.
//

import SpriteKit
import GameplayKit

// The current state of the game
enum GameState {
    case playing
    case menu
    static var current = GameState.playing
}

struct pc { // Physics Category
    static let none: UInt32 = 0x1 << 0
    static let ball: UInt32 = 0x1 << 1
    static let lBin: UInt32 = 0x1 << 2
    static let rBin: UInt32 = 0x1 << 3
    static let base: UInt32 = 0x1 << 4
    static let sG: UInt32 = 0x1 << 5
    static let eG: UInt32 = 0x1 << 6
}

// Really these can just be a variable inside the GameScene Class
struct t { // Start and end touch points - Records when we touch the ball (start) & when we let go (end)
    static var start = CGPoint()
    static var end = CGPoint()
}

// Same as these
struct c {  // Constants
    static var grav = CGFloat() // Gravity
    static var yVel = CGFloat() // Initial Y Velocity
    static var airTime = TimeInterval() // Time the ball is in the air
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // Variables
    
    var delagate : dismissdelagate?
    var grids = false // turn on to see all the physics grid lines
    
    // SKSprites
    var bg = SKSpriteNode(imageNamed: "bgToilet")            // background image
    var bFront = SKSpriteNode(imageNamed: "commode")       // Front portion of the bin
    var bBack = SKSpriteNode(imageNamed: "commode_bottom")         // rear portion of the bin
    var pBall = SKSpriteNode(imageNamed: "paperBallImage")  // Paper Ball skin
    var ac = SKSpriteNode(imageNamed: "icon_window")
    var box = SKSpriteNode(imageNamed: "icon_wallabox")
     var windarrow = SKSpriteNode(imageNamed: "bg_wind")
    var windarrowleft = SKSpriteNode(imageNamed: "leftArrow")
    var windarrowright = SKSpriteNode(imageNamed: "rightArrow")
    
    
    let scorelabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
    let scores = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    var svalue = 0
    
    //button
    let btn: UIButton = UIButton(frame: CGRect(x: 10, y: 20, width: 50, height: 50))
    
    
    //SKShapes
    var ball = SKShapeNode()
    var leftWall = SKShapeNode()
    var rightWall = SKShapeNode()
    var leftWall2 = SKShapeNode()
    var rightWall2 = SKShapeNode()
    var base = SKShapeNode()
    var endG = SKShapeNode()    // The ground that the bin will sit on
    var startG = SKShapeNode()  // Where the paper ball will start
    var lablevalue = Int()
    // SKLabels
    var windLbl = SKLabelNode()
    
    // CGFloats
    var pi = CGFloat(M_PI)
    var wind = CGFloat()
    //ball veloicty
    var ballv = CGFloat()
    var touchingBall = false 
    
    // Did Move To View - The GameViewController.swift has now displayed GameScene.swift and will instantly run this function.
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            c.grav = -6
            c.yVel = self.frame.height / 4
            c.airTime = 1.5
        }else{
            // iPad
        }
    checkDevice()
        
        
        physicsWorld.gravity = CGVector(dx: 0, dy: c.grav)
        
        setUpGame()
    }
    func checkDevice(){
    
    if UIDevice().userInterfaceIdiom == .phone {
    switch UIScreen.main.nativeBounds.height {
    case 1136:
    
    print("iPhone 5 or 5S or 5C")
        self.ballv = self.frame.size.height / 8
        
        
    case 1334:
    print("iPhone 6/6S/7/8")
        self.ballv = self.frame.size.height / 8
    
    case 1920, 2208:
    print("iPhone 6+/6S+/7+/8+")
      self.ballv = self.frame.size.height / 8
    case 2436:
    print("iPhone X, XS")
      self.ballv = self.frame.size.height / 5
    case 2688:
    print("iPhone XS Max")
    self.ballv = self.frame.size.height / 4.5
    case 1792:
    print("iPhone XR")
     self.ballv = self.frame.size.height / 4.5
    
    default:
    print("Unknown")
    }
    }
    }
    
    // Fires the instant a touch has made contact with the screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            if GameState.current == .playing {
                if ball.contains(location){
                    t.start = location
                    touchingBall = true
                }
            }
        }
    }
    
    // Fires as soon as the touch leaves the screen
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            if GameState.current == .playing && !ball.contains(location) && touchingBall{
                t.end = location
                touchingBall = false
                fire()
            }
        }
    }
    
    @objc func buttonAction(sender: UIButton!) {
        self.removeFromParent()
    }
    // Set the images and physics properties of the GameScene
    func setUpGame() {
        GameState.current = .playing
        
        
        
        
        windarrowright.isHidden = true
        windarrowleft.isHidden = false

        btn.setImage(UIImage(named: "btn-back"), for: .normal)
        btn.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        btn.tag = 1
        self.view!.addSubview(btn)
        
        
        // Background
        let bgScale = CGFloat(bg.frame.width / bg.frame.height) // eg. 1.4 as a scale
        
        bg.size.height = self.frame.height
        bg.size.width = self.frame.width
        bg.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        bg.zPosition = 0
        self.addChild(bg)
        
        ac.size.height = self.frame.height / 12
        ac.size.width = ac.size.height *  2.5
        ac.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 1.18 )
        ac.zPosition = bg.zPosition + 1
        self.addChild(ac)
        
        
        box.size.height = self.frame.height / 8
        box.size.width = box.size.height * 0.7
        box.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 1.5 )
        box.zPosition = bg.zPosition + 1
        self.addChild(box)
        
        windarrow.size.height = self.frame.height / 8
        windarrow.size.width = windarrow.size.height
        windarrow.position = CGPoint(x: self.frame.width / 1 - (windarrow.size.width - 10), y: self.frame.height / 6 )
        windarrow.zPosition = bg.zPosition + 1
        self.addChild(windarrow)
        
        windarrowleft.size.height = windarrow.size.height / 3
        windarrowleft.size.width = windarrowleft.size.height
        windarrowleft.position = CGPoint(x: windarrow.position.x  , y: windarrow.position.y + 20 )
        windarrowleft.zPosition = bg.zPosition + 1
        self.addChild(windarrowleft)
        
        windarrowright.size.height = windarrow.size.height / 3
        windarrowright.size.width = windarrowright.size.height
        windarrowright.position = CGPoint(x: windarrow.position.x  , y: windarrow.position.y + 20 )
        windarrowright.zPosition = bg.zPosition + 1
        self.addChild(windarrowright)
        
        windLbl.text = "0"
        windLbl.position = CGPoint(x: windarrow.position.x  , y: windarrow.position.y - 30   )
        windLbl.fontColor = #colorLiteral(red: 0.2824305296, green: 0.7237324119, blue: 0.8073182702, alpha: 1)
        windLbl.fontSize = 25
        windLbl.fontName = "AvenirNext-Bold"
        windLbl.zPosition = bg.zPosition + 1
        self.addChild(windLbl)
        
        
        scorelabel.center = CGPoint(x: self.frame.width / 2, y: self.frame.height / 4 )
        scorelabel.textColor = .black
        scorelabel.font.withSize(CGFloat(25))
         scorelabel.textAlignment = .center
        scorelabel.text = "Score"
        //scorelabel.font = UIFont.boldSystemFont(ofSize: 10.0)
        
        self.view!.addSubview(scorelabel)
        
        
        scores.center = CGPoint(x: self.frame.width / 2, y: self.frame.height / 3.3 )
        scores.textColor = .white
        scores.font.withSize(CGFloat(100))
        scores.textAlignment = .center
        scores.font = UIFont.boldSystemFont(ofSize: 25.0)
        scores.text = String(svalue)
        
        self.view!.addSubview(scores)
        
        //Bin front and back
        let binScale = CGFloat(bBack.frame.width / bBack.frame.height)
        
        
        
        bFront.size.height = self.frame.height / 4
        bFront.size.width = bFront.size.height * 0.8
        bFront.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2.2)
        bFront.zPosition = bg.zPosition
        self.addChild(bFront)
        
        bBack.size.height = bFront.frame.height / 2.85
        bBack.size.width = bBack.size.height * 1.75
        bBack.position = CGPoint(x: bFront.position.x  , y: bFront.position.y - bFront.size.height / 3.7)
        bBack.zPosition = bFront.zPosition + 3
        self.addChild(bBack)
        
        // Start ground - make grids true at the top to see these lines
        startG = SKShapeNode(rectOf: CGSize(width: self.frame.width, height: 5))
        startG.fillColor = .red
        startG.strokeColor = .clear
        startG.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 10)
        startG.zPosition = 10
        startG.alpha = grids ? 1 : 0
        
        startG.physicsBody = SKPhysicsBody(rectangleOf: startG.frame.size)
        startG.physicsBody?.categoryBitMask = pc.sG
        startG.physicsBody?.collisionBitMask = pc.ball
        startG.physicsBody?.contactTestBitMask = pc.none
        startG.physicsBody?.affectedByGravity = false
        startG.physicsBody?.isDynamic = false
        self.addChild(startG)
        
        // End ground
        endG = SKShapeNode(rectOf: CGSize(width: self.frame.width * 2, height: 5))
        endG.fillColor = .red
        endG.strokeColor = .clear
        endG.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 3 - bFront.frame.height / 10)
        endG.zPosition = 10
        endG.alpha = grids ? 1 : 0
        
        endG.physicsBody = SKPhysicsBody(rectangleOf: endG.frame.size)
        endG.physicsBody?.categoryBitMask = pc.eG
        endG.physicsBody?.collisionBitMask = pc.ball
        endG.physicsBody?.contactTestBitMask = pc.none
        endG.physicsBody?.affectedByGravity = false
        endG.physicsBody?.isDynamic = false
        self.addChild(endG)
        
        // Left Wall of the bin
        leftWall = SKShapeNode(rectOf: CGSize(width: 3, height: bFront.frame.height / 2.5))
        leftWall.fillColor = .red
        leftWall.strokeColor = .clear
        leftWall.position = CGPoint(x: bFront.position.x - bFront.frame.width / 3.5, y: bFront.position.y - bFront.size.height / 4)
        leftWall.zPosition = 10
        leftWall.alpha = grids ? 1 : 0
        
        leftWall.physicsBody = SKPhysicsBody(rectangleOf: leftWall.frame.size)
        leftWall.physicsBody?.categoryBitMask = pc.lBin
        leftWall.physicsBody?.collisionBitMask = pc.ball
        leftWall.physicsBody?.contactTestBitMask = pc.none
        leftWall.physicsBody?.affectedByGravity = false
        leftWall.physicsBody?.isDynamic = false
        leftWall.zRotation = pi / 25
        self.addChild(leftWall)
        
        
        
        // Right wall of the bin
        rightWall = SKShapeNode(rectOf: CGSize(width: 3, height: bFront.frame.height / 2.5))
        rightWall.fillColor = .red
        rightWall.strokeColor = .clear
        rightWall.position = CGPoint(x: bFront.position.x + bFront.frame.width / 3.5, y: bFront.position.y - bFront.size.height / 4)
        rightWall.zPosition = 10
        rightWall.alpha = grids ? 1 : 0
        
        rightWall.physicsBody = SKPhysicsBody(rectangleOf: rightWall.frame.size)
        rightWall.physicsBody?.categoryBitMask = pc.rBin
        rightWall.physicsBody?.collisionBitMask = pc.ball
        rightWall.physicsBody?.contactTestBitMask = pc.none
        rightWall.physicsBody?.affectedByGravity = false
        rightWall.physicsBody?.isDynamic = false
        rightWall.zRotation = -pi / 25
        self.addChild(rightWall)
        
        
        //roomwalls
        leftWall2 = SKShapeNode(rectOf: CGSize(width: 3, height: self.frame.height / 1))
        leftWall2.fillColor = .red
        leftWall2.strokeColor = .clear
        leftWall2.position = CGPoint(x: self.frame.width / 8 , y:  self.frame.height / 2 )
        leftWall2.zPosition = 10
        leftWall2.alpha = grids ? 1 : 0
        
        leftWall2.physicsBody = SKPhysicsBody(rectangleOf: leftWall2.frame.size)
        leftWall2.physicsBody?.categoryBitMask = pc.lBin
        leftWall2.physicsBody?.collisionBitMask = pc.ball
        leftWall2.physicsBody?.contactTestBitMask = pc.none
        leftWall2.physicsBody?.affectedByGravity = false
        leftWall2.physicsBody?.isDynamic = false
        //leftWall2.zRotation = pi / 25
        self.addChild(leftWall2)
        
        rightWall2 = SKShapeNode(rectOf: CGSize(width: 3, height: self.frame.height / 1))
        rightWall2.fillColor = .red
        rightWall2.strokeColor = .clear
        rightWall2.position = CGPoint(x: self.frame.width / 1.15 , y:  self.frame.height / 2 )
        rightWall2.zPosition = 10
        rightWall2.alpha = grids ? 1 : 0
        
        rightWall2.physicsBody = SKPhysicsBody(rectangleOf: rightWall2.frame.size)
        rightWall2.physicsBody?.categoryBitMask = pc.lBin
        rightWall2.physicsBody?.collisionBitMask = pc.ball
        rightWall2.physicsBody?.contactTestBitMask = pc.none
        rightWall2.physicsBody?.affectedByGravity = false
        rightWall2.physicsBody?.isDynamic = false
        //leftWall2.zRotation = pi / 25
        self.addChild(rightWall2)
        
        // The base of the bin
        base = SKShapeNode(rectOf: CGSize(width: bFront.frame.width / 2, height: 3))
        base.fillColor = .red
        base.strokeColor = .clear
        base.position = CGPoint(x: bFront.position.x, y: bFront.position.y - bFront.frame.height / 4)
        base.zPosition = 10
        base.alpha = grids ? 1 : 0
        base.physicsBody = SKPhysicsBody(rectangleOf: base.frame.size)
        base.physicsBody?.categoryBitMask = pc.base
        base.physicsBody?.collisionBitMask = pc.ball
        base.physicsBody?.contactTestBitMask = pc.ball
        base.physicsBody?.affectedByGravity = false
        base.physicsBody?.isDynamic = false
        self.addChild(base)
        
//        // The wind label
//        windLbl.text = "Wind = 0"
//        windLbl.position = CGPoint(x: self.frame.width / 2, y: self.frame.height * 4 / 5)
//        windLbl.fontSize = self.frame.width / 10
//        windLbl.zPosition = bg.zPosition + 1
//        self.addChild(windLbl)
        
        // Get new wind and setup the ball
        setWind()
        setBall()
    }
    
    // Set up the ball. This will be called to reset the ball too
    func setBall() {
        
        
        // Remove and reset incase the ball was previously thrown
        
        pBall.removeFromParent()
        ball.removeFromParent()
        
        ball.setScale(1)
        
        // Set up ball
        ball = SKShapeNode(circleOfRadius: bFront.frame.width / 4.5)
        ball.fillColor = grids ? .blue : .clear
        ball.strokeColor = .clear
        ball.position = CGPoint(x: self.frame.width / 2, y: startG.position.y + ball.frame.height)
        ball.zPosition = 10
        
        // Add "paper skin" to the circle shape
        pBall.size = ball.frame.size
        ball.addChild(pBall)
        
        // Set up the balls physics properties
        ball.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "paperBallImage"), size: pBall.size)
        ball.physicsBody?.categoryBitMask = pc.ball
        ball.physicsBody?.collisionBitMask = pc.sG
        ball.physicsBody?.contactTestBitMask = pc.base
        ball.physicsBody?.affectedByGravity = true
        ball.physicsBody?.isDynamic = true
        self.addChild(ball)
        
    }
    
    // Fetch a new wind speed and store it for use on the ball
    func setWind() {
        
        let multi = CGFloat(50)
        //let rnd = CGFloat(arc4random_uniform(UInt32(2))) - 2
        let rnd = CGFloat(Float.random(in: 0.0...2.0)) - 1
        
        windLbl.text = "\(String(format: "%.2f", Double(rnd)))"
        wind = rnd * multi
         if wind >= 0
         {
            windarrowright.isHidden = false
            windarrowleft.isHidden = true
        }
        else
         {
            windarrowleft.isHidden = false
           windarrowright.isHidden = true
        }
    }
    
    // When touches ended this is called to shoot the paper ball
    func fire() {
        
        let xChange = t.end.x - t.start.x
        let angle = (atan(xChange / (t.end.y - t.start.y)) * 180 / pi)
        let amendedX = (tan(angle * pi / 180) * c.yVel) * 0.5
        
        // Throw it!
        let throwVec = CGVector(dx: amendedX, dy: ballv)
        ball.physicsBody?.applyImpulse(throwVec, at: t.start)
        
        // Shrink
        ball.run(SKAction.scale(by: 0.3, duration: c.airTime))
        
        // Change Collision Bitmask
        let wait = SKAction.wait(forDuration: c.airTime / 2)
        let changeCollision = SKAction.run({
            self.ball.physicsBody?.collisionBitMask = pc.sG | pc.eG | pc.base | pc.lBin | pc.rBin
            self.ball.zPosition = self.bg.zPosition + 2
        })
        
        // ADD WIND STEVE!
        let windWait = SKAction.wait(forDuration: c.airTime / 4)
        let push = SKAction.applyImpulse(CGVector(dx: wind, dy: 0), duration: 1)
        ball.run(SKAction.sequence([windWait, push]))
        self.run(SKAction.sequence([wait,changeCollision]))
        
        // Wait & reset
    
        
        let wait4 = SKAction.wait(forDuration: 4)
        let reset = SKAction.run({
            if self.ball.position.y >= self.base.position.y && self.ball.position.y <= self.base.position.y + 20
            {
                self.svalue = self.svalue+1
                print("Done")
                self.scores.removeFromSuperview()
                self.pBall.removeFromParent()
                self.ball.removeFromParent()
                self.scores.text = String(self.svalue)
                self.view!.addSubview(self.scores)
            }
            else
            {
                print(self.ball.position.y )
                print(self.base.position.y)
            }
            self.setWind()
            self.setBall()
        })
    
        self.run(SKAction.sequence([wait4,reset]))
        
    }
}
