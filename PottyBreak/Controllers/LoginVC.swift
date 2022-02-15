//
//  LoginVC.swift
//  PottyBreak
//
//  Created by MacBook Pro on 14/03/2019.
//  Copyright © 2019 MacBook Pro. All rights reserved.
///
//  LoginVC.swift
//  PottyBreak
//
//  Created by MacBook Pro on 14/03/2019.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import GoogleSignIn
import FBSDKCoreKit
import FBSDKLoginKit
import FirebaseDatabase
import CoreLocation



let  popVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ShowActivityAnimation") as! ShowActivityAnimation

class LoginVC: UIViewController   , GIDSignInUIDelegate {
    
    @IBOutlet weak var backgroundView:UIView!
    @IBOutlet weak var fbloginbutton :FBSDKLoginButton!
    @IBOutlet weak var gmailBackgroundView:UIView!
    @IBOutlet weak var poweredByImageView: UIImageView!
    
    @IBOutlet weak var gimg: UIImageView!
    @IBOutlet weak var fbimg: UIImageView!
    
    @IBOutlet weak var gmailButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
       // gmailBackgroundView.carveView()
        checkDevice()
        gmailButton.carveView()
    
        fbimg.layer.cornerRadius = 7
        fbimg.layer.masksToBounds = true
        gimg.layer.cornerRadius = 7
        gimg.layer.masksToBounds = true
        fbloginbutton.readPermissions = [ "email"];
        fbloginbutton.delegate = self
        fbloginbutton.imageView?.image = #imageLiteral(resourceName: "facebook")
 
        GIDSignIn.sharedInstance()?.uiDelegate = self as GIDSignInUIDelegate
        GIDSignIn.sharedInstance()?.delegate = self
        
        //poweredByImageView.carveView()
        if let fbuser = FBSDKAccessToken.current()
        {
            
        }
    }
    
    @IBAction func googleSignButton(_ sender: Any) {
        
        GIDSignIn.sharedInstance()?.signIn()
    }
    
}
///////////// Login with Google Account
extension LoginVC : GIDSignInDelegate
{
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if let error = error
        {
            return
        }
        else
        {
             self.showAndicator()
            guard let guser = user
                else{
                    return
            }
            
            let userinfo = User(id: guser.userID, name: guser.profile.name, email: guser.profile.email, photoUrl: guser.profile.imageURL(withDimension: 100)?.absoluteString)
            if userinfo != nil{
                
                Auth.auth().fetchProviders(forEmail: userinfo.email as! String , completion: {
                    (providers,error)
                    in
                    print(providers)
                    
                    if let error = error
                    {
                        print(error.localizedDescription)
                    }
                        
                    else if let providers = providers {
                        
                        //If providers are returned, and they aren't facebook related, this means that there is already an account associated with this email
                        
                        if providers.first != "google.com" {
                            
                            let alert = UIAlertController(title: "Email already in use.", message: "The email address linked with this Facebook account is already being used by a HOOT user.", preferredStyle: UIAlertController.Style.alert)
                            
                            let ok = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                            
                            alert.addAction(ok)
                            
                            self.present(alert, animated: true, completion: nil)
                        }
                        else{
                            
                            guard  let authentication = guser.authentication else { return }
                            
                            let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                                           accessToken: authentication.accessToken)
                            Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
                                if  error == nil {
                                    self.removeAndicator()
                                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "mainnav")
                                    self.present(vc!, animated: true, completion: nil)
                                    
                                }
                                else{
                                    print(error?.localizedDescription)
                                }
                            }
                        }
                    }
                    else{
                        self.createAcctWithFBCredentials(userInfo: userinfo  , user: user)
                    }
                })
            }
            else
            {
                print(Auth.auth().currentUser?.uid)
                
            }
        }
    }
    
    func createAcctWithFBCredentials(userInfo: User , user : GIDGoogleUser) {
  
        guard  let authentication = user.authentication else { return }
        
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        //Sign into firebase with this credential
        
        Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
            
            if let error = error {
                return
                
            }
            
            let user = Auth.auth().currentUser
            
            Database.database().reference().child("Users").child(user!.uid).setValue(["email" : userInfo.email ?? "unknown email","id" : Auth.auth().currentUser!.uid,"photoUrl" : userInfo.photoUrl,"name": (userInfo.name as! String)])
            
            if let user = user {
                
                let changeRequest = user.createProfileChangeRequest()
                
                //Update our user's display name in firebase to their facebook name
                changeRequest.displayName = (userInfo.name as! String)
                
                //Update our user's photoURL in firebase to the user's profile pic
                
                changeRequest.photoURL =
                    
                    URL(string: userInfo.photoUrl!)
    
                //Commit these changes
                
                changeRequest.commitChanges { error in
                    
                    if let error = error {
                        
                        // An error happened.
                        
                    } else {
                        
                        // Profile updated.
                        
                        // User is signed in
                        
                        
                        
                        //Update our user's email in firebase to their facebook email
                        
                        user.updateEmail(to: userInfo.email as! String, completion: { (error) in
                            
                            //  self.performSegue(withIdentifier: "loginToHome", sender: self)
                            
                        })
                        
                    }
                    
                }
                
            }
            self.removeAndicator()
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "mainnav")
            self.present(vc!, animated: true, completion: nil)
        }
    }
}
////////// Login with FaceBook
extension LoginVC : FBSDKLoginButtonDelegate
{
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        //
        try?
            Auth.auth().signOut()
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        let loginResult = result
        
        if let error = error {
            
            print(error.localizedDescription)
            
            return
            
        }
        
        //If the request wasn't cancelled...
        
        if !result.isCancelled {
            self.showAndicator()
            
            //Request the user's id, name, first name, last name, email, and 480x480 px profile picture
            
            let request = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, email, picture.width(480).height(480)"])
            
            request?.start(completionHandler: { (connection, result, error) in
                
                guard let userInfo = result as? [String: Any] else { return } //handle the error
                
                
                
                //Check if there is already an account in our Firebase associated with the facebook account's email
                
                Auth.auth().fetchProviders(forEmail: userInfo["email"] as! String, completion: {
                    
                    (providers, error) in
                    
                    
                    
                    if let error = error {
                        
                        print(error.localizedDescription)
                        
                    } else if let providers = providers {
                        
                        //If providers are returned, and they aren't facebook related, this means that there is already an account associated with this email
                        
                        if providers.first != "facebook.com" {
                            
                            let alert = UIAlertController(title: "Email already in use.", message: "The email address linked with this Facebook account is already being used by a HOOT user.", preferredStyle: UIAlertController.Style.alert)
                            
                            let ok = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                            
                            alert.addAction(ok)
                            
                            self.present(alert, animated: true, completion: nil)
                            
                        } else {
                            
                            //if the providers are related to facebook, then sign in using the facebook info
                            
                            let credential = FacebookAuthProvider.credential(withAccessToken: loginResult?.token.tokenString ?? "")
                            
                            Auth.auth().signInAndRetrieveData(with: credential, completion: { (result, error) in
                                
                                if error == nil {
                                    
                                    //Segue to the mapViewController if no error
                                    self.removeAndicator()
                                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "mainnav")
                                    self.present(vc!, animated: true, completion: nil)
                                  
                                    
                                } else {
                                    
                                    print("error:", error)
                                }
                            })
                        }
                    } else {
                        
                        //If no providers are returned, then we can create an account using the facebook info provided
                        self.removeAndicator()
                        self.createAcctWithFBCredentials(userInfo: userInfo)
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "mainnav")
                        self.present(vc!, animated: true, completion: nil)
                    }
                })
            })
        }
    }
    
    
    func createAcctWithFBCredentials(userInfo: [String:Any]) {
        
        
        
        //Create credential from the access token
        
        let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        
        //Sign into firebase with this credential
        
        Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
            
            if let error = error {
                
                // ...
                
                return
                
            }
            
            
            
            //The url is nested 3 layers deep into the result so it's pretty messy
            
            if let imageURL = ((userInfo["picture"] as? [String: Any])?["data"] as? [String: Any])?["url"] as? String {
                
                //Download image from imageURL
                
                let user = Auth.auth().currentUser
                
                Database.database().reference().child("Users").child(user!.uid).setValue(["email" : userInfo["email"] ?? "unknown email","id" : Auth.auth().currentUser!.uid,"photoUrl" : imageURL,"name": (userInfo["name"] as! String)])
                
                if let user = user {
                    
                    let changeRequest = user.createProfileChangeRequest()
                    
                    //Update our user's display name in firebase to their facebook name
                    
                    changeRequest.displayName = (userInfo["name"] as! String)
                    
                    //Update our user's photoURL in firebase to the user's profile pic
                    
                    changeRequest.photoURL =
                        
                        URL(string: imageURL)
                    
                    
                    
                    //Commit these changes
                    
                    changeRequest.commitChanges { error in
                        
                        if let error = error {
                            
                            // An error happened.
                            
                        } else {
                            
                            // Profile updated.
                            
                            // User is signed in
                            
                            
                            
                            //Update our user's email in firebase to their facebook email
                            
                            user.updateEmail(to: userInfo["email"] as! String, completion: { (error) in
                                
                                //  self.performSegue(withIdentifier: "loginToHome", sender: self)
                                
                            })
                            
                        }
                        
                    }
                    
                }
                
            }
            
            
            
        }
        
    }
    override func awakeFromNib() {
        
        
    }
}
/////// Activity Indicator
extension LoginVC{
    func showAndicator(){
        
        self.addChild(popVC)
        popVC.view.frame = self.view.frame
        self.view.addSubview(popVC.view)
        popVC.didMove(toParent: self)
    }
    func removeAndicator(){
        // popVC.removeFromParentViewController()
        popVC.view.removeFromSuperview()
    }
    
}

///////////////// CHECKING DEVICES ///////////////////////////
extension LoginVC{
    func checkDevice(){
        
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136:
                
                print("iPhone 5 or 5S or 5C")
                backgroundView.topAnchor.constraint(equalTo: view.topAnchor, constant: 420).isActive = true
                backgroundView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 55).isActive = true
                backgroundView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -60).isActive = true
                backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -55).isActive = true
                
            case 1334:
                print("iPhone 6/6S/7/8")
                
                backgroundView.topAnchor.constraint(equalTo: view.topAnchor, constant: 490).isActive = true
                backgroundView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 65).isActive = true
                backgroundView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -70).isActive = true
                backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -60).isActive = true
                
                
            case 1920, 2208:
                print("iPhone 6+/6S+/7+/8+")
                backgroundView.topAnchor.constraint(equalTo: view.topAnchor, constant: 545).isActive = true
                backgroundView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 70).isActive = true
                backgroundView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -75).isActive = true
                backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -65).isActive = true
                
            case 2436:
                print("iPhone X, XS")
                backgroundView.topAnchor.constraint(equalTo: view.topAnchor, constant: 600).isActive = true
                backgroundView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 65).isActive = true
                backgroundView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -65).isActive = true
                backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -80).isActive = true
            case 2688:
                print("iPhone XS Max")
                backgroundView.topAnchor.constraint(equalTo: view.topAnchor, constant: 665).isActive = true
                backgroundView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 70).isActive = true
                backgroundView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -65).isActive = true
                backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -80).isActive = true
            case 1792:
                print("iPhone XR")
                
                  backgroundView.topAnchor.constraint(equalTo: view.topAnchor, constant: 665).isActive = true
                backgroundView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 70).isActive = true
                backgroundView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -65).isActive = true
                backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -80).isActive = true
    
            default:
                print("Unknown")
            }
        }
   }
    
   
    
    
}
