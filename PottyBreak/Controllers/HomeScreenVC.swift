//
//  HomeScreenVC.swift
//  PottyBreak
//
//  Created by Moheed Zafar Hashmi on 05/04/2019.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

import UIKit
import CoreLocation
import FirebaseDatabase
import SDWebImage
import Firebase
import GoogleSignIn
import FBSDKLoginKit
import FBSDKCoreKit
protocol RateNowDelegate: class {
    func rateNow();
}
class HomeScreenVC: UIViewController {
   
    @IBOutlet weak var titleB: UILabel!
    @IBOutlet weak var descriptin: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var factView: UIView!
    @IBOutlet weak var heightOfFactView: NSLayoutConstraint!
    
    
    @IBOutlet weak var backgroundView:UIView!
    @IBOutlet weak var findBathRoomImage: UIImageView!
    @IBOutlet weak var shopNowImage: UIImageView!
    @IBOutlet weak var shapChatImage: UIImageView!
    @IBOutlet weak var DailyDueceImage: UIImageView!
    
    
    var manager = CLLocationManager()
    var score = 0;
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationItem.title = ""
        var id = Auth.auth().currentUser?.uid;
        Database.database().reference().child("Users").child("\(id!)").observeSingleEvent(of: .value, with: { (snapshot) in
            let json1 = snapshot.value as? [String: Any]
            
            if let user = json1
            {
                self.score = user["score"] as? Int ?? 0;
            }
            DispatchQueue.main.async {
                self.navigationItem.title = "Score: \(self.score)"
            }
            
        });
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkDevice()
        settingTapGesturseOnImages()
        postToken()
        image.roundImage()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        loadBanner();
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(HomeScreenVC.tapFunction))
        factView.isUserInteractionEnabled = true
        factView.addGestureRecognizer(tap)
        isNotRatedYet()

    }
    @objc
    func tapFunction(sender:UITapGestureRecognizer) {
        
        let popVC = UIStoryboard.init(name: "Main", bundle:nil).instantiateViewController(withIdentifier: "PopUpFactVC") as! PopUpFactVC
        popVC.fact = "\(titleB.text!)"
        popVC.factDescrition = "\(descriptin.text!)"
        popVC.image = self.image.image
        self.addChild(popVC)
        popVC.view.frame = self.view.frame
        self.view.addSubview(popVC.view)
        popVC.didMove(toParent: self)
    }

func loadBanner()
{
    Database.database().reference().child("Banner").observe(.value) { (snapshot) in
       if  let Banners = snapshot.value as? [String: Any]
       {
        let random = Int.random(in: 0 ..< Banners.count)
        var count = 0;
        for article in Banners
        {
            if count == random{
                
                let baner = article.value as! [String : Any]
                var tit = baner["title"] as! String;
                var des = baner["description"] as! String;
                var url = baner["photoUrl"] as! String //Exception handle
                DispatchQueue.main.async(execute: {
                    self.factView.isHidden = false
                    self.titleB.text = tit
                    self.descriptin.text = des
                    
                    self.image.sd_setIndicatorStyle(.gray);
                    self.image.sd_setShowActivityIndicatorView(true)
                    
                    let path = url;
                    print(path);
                    
                    self.image.sd_setImage(with: URL(string: path)) { (img, error, cacheType, url) in
                    };
                })
            }
            count = count+1;
        }
    }
       else{
          print("there is no banners")
        }
    }
    }
    
    
    @IBAction func logout(_ sender: Any) {
       GIDSignIn.sharedInstance()?.signOut()
       try? Auth.auth().signOut()
      
        DispatchQueue.main.async {
            
            self.performSegue(withIdentifier: "root", sender: nil)
        }
     
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.navigationItem.title = "Home"
    }
}

extension HomeScreenVC
{
    private func postToken()
    {
        if let refreshedToken = InstanceID.instanceID().token() {//1Open
            print("==========================================================================Chat-InstanceID TokenExist===============: \(refreshedToken)")
            if let id = Auth.auth().currentUser?.uid{       //2Open
                print("current User Exist");
                if let user = UserDefaults.standard.string(forKey: "user") //3Open
                {
                    print("User in UD Exist");
                    print("User in UD:\(user)")
                    if(user == Auth.auth().currentUser!.uid) //4Open
                    {
                        print("user in UD and Current user matched");
                        UserDefaults.standard.set(refreshedToken as Any?, forKey: "token");
                        Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).updateChildValues(["fcmToken":refreshedToken]);
                    }
                    else{ //4Closed
                        print("user in ud and current user not matched");
                        Database.database().reference().child("Users").child(user).updateChildValues(["fcmToken":""]);
                        Database.database().reference().child("Users").child(id).child("fcmToken").setValue(refreshedToken);
                        UserDefaults.standard.set(refreshedToken as Any?, forKey: "token");
                        UserDefaults.standard.set(id as Any?, forKey: "user");
                        
                    }
                }
                else{   //3Closed
                    print("user not exist in UD");
                    UserDefaults.standard.set(refreshedToken as Any?, forKey: "token");
                    UserDefaults.standard.set(id as Any?, forKey: "user");
                    Database.database().reference().child("Users").child(id).child("fcmToken").setValue(refreshedToken);
                }
            }
            else{
                print("Current User not Exist");
                UserDefaults.standard.set(refreshedToken as Any?, forKey: "token")
            }
        }
        else {//1C
            print("Token not Fount");
        }
        //  Messaging.messaging().shouldEstablishDirectChannel = true
    }
}

////////Getting current loction of user
extension HomeScreenVC:CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let location = locations[0]
        let myLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)

        UserDefaults.standard.set(myLocation.latitude, forKey: "UserCurrentLatitude")
        UserDefaults.standard.set(myLocation.longitude, forKey: "UserCurrentLongitude")
        CLGeocoder().reverseGeocodeLocation(location) { (placemark, error) in
            if error != nil
            {
                //print ("THERE WAS AN ERROR")
            }
            else
            {
                if let place = placemark?[0]
                {
          
                    var adressString : String = ""
                    if place.thoroughfare != nil {
                        adressString = adressString + place.thoroughfare! + ", "
                    }
                    if place.subThoroughfare != nil {
                        adressString = adressString + place.subThoroughfare! + "\n"
                    }
                    if place.locality != nil {
                        adressString = adressString + place.locality! + " - "
                    }
                    if place.postalCode != nil {
                        adressString = adressString + place.postalCode! + "\n"
                    }
                    if place.subAdministrativeArea != nil {
                        adressString = adressString + place.subAdministrativeArea! + " - "
                    }
                    if place.country != nil {
                        adressString = adressString + place.country!
                    }
                    
                     UserDefaults.standard.set(adressString, forKey: "UserCurrentAddress")

                }
            }
        }
    }
}
extension HomeScreenVC:RateNowDelegate
{
    func rateNow() {
        let placeID = UserDefaults.standard.string(forKey: "placeID")
        let title = UserDefaults.standard.string(forKey: "title")
        let snippet = UserDefaults.standard.string(forKey: "address")
        
        let ratings = UserDefaults.standard.double(forKey: "ratings")
        
        let numberOfUsers = UserDefaults.standard.integer(forKey: "users")
        var fm = customMarker();
        fm.id = placeID
        fm.snippet = snippet
        
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RateABathroomVC") as! RateABathroomVC
        vc.recivingMarker = fm;
        vc.ratings = ratings
        vc.numberofuser = numberOfUsers
        
        navigationController?.pushViewController(vc, animated: true)
        
        
        
        
    }
    
func isNotRatedYet()
{
    if let id = UserDefaults.standard.string(forKey: "placeID")
    {
        let title = UserDefaults.standard.string(forKey: "title") as! String
        let address = UserDefaults.standard.string(forKey: "address") as! String
        let popVC = UIStoryboard.init(name: "Main", bundle:nil).instantiateViewController(withIdentifier: "PopUpRatingVC") as! PopUpRatingVC
        popVC.delegate = self
        popVC.titleForLabel = title
        popVC.address = address
        popVC.id = id
        
        self.addChild(popVC)
        popVC.view.frame = self.view.frame
        self.view.addSubview(popVC.view)
        popVC.didMove(toParent: self)
    }
    
    }
}
/////////////////////////// SETTING GESTURES ON IMAGES ///////////////////////////////////
extension HomeScreenVC{
    func settingTapGesturseOnImages(){
        let tap1 = ratingGesture(target: self, action: #selector(HomeScreenVC.handleTap(_:)))
        findBathRoomImage.addGestureRecognizer(tap1)
        tap1.id = 1
        let tap2 = ratingGesture(target: self, action: #selector(HomeScreenVC.handleTap(_:)))
        shopNowImage.addGestureRecognizer(tap2)
        tap2.id = 2
        let tap3 = ratingGesture(target: self, action: #selector(HomeScreenVC.handleTap(_:)))
        shapChatImage.addGestureRecognizer(tap3)
        tap3.id = 3
        let tap4 = ratingGesture(target: self, action: #selector(HomeScreenVC.handleTap(_:)))
        DailyDueceImage.addGestureRecognizer(tap4)
        tap4.id = 4
    }
    @objc func handleTap(_ sender: ratingGesture) {
        let id = sender.id!
        
        if id == 1 {
            performSegue(withIdentifier: "SearchBathRoomVC", sender: nil)
        }
        else if id == 2{
            
        }
        else if id == 3{
            
        }
        else if id == 4{
            
        }
    }
}
////////////////////////////// PREPARING FOR SEGUES /////////////////////
extension HomeScreenVC{

}
//////////////// CHECKING DEVICES ///////////////////////////
extension HomeScreenVC{
    func checkDevice(){
        
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136:
                
                print("iPhone 5 or 5S or 5C")
                backgroundView.topAnchor.constraint(equalTo: view.topAnchor, constant: 205).isActive = true
                backgroundView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 55).isActive = true
                backgroundView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -54).isActive = true
                backgroundView.bottomAnchor.constraint(equalTo: factView.topAnchor, constant: -25).isActive = true
                
            case 1334:
                print("iPhone 6/6S/7/8")
                
                backgroundView.topAnchor.constraint(equalTo: view.topAnchor, constant: 245).isActive = true
                backgroundView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 60).isActive = true
                backgroundView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -60).isActive = true
                backgroundView.bottomAnchor.constraint(equalTo: factView.topAnchor, constant: -30).isActive = true
                
                
            case 1920, 2208:
                print("iPhone 6+/6S+/7+/8+")
                backgroundView.topAnchor.constraint(equalTo: view.topAnchor, constant: 275).isActive = true
                backgroundView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 65).isActive = true
                backgroundView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -65).isActive = true
                backgroundView.bottomAnchor.constraint(equalTo: factView.topAnchor, constant: -30).isActive = true
                
            case 2436:
                print("iPhone X, XS")
                backgroundView.topAnchor.constraint(equalTo: view.topAnchor, constant: 280).isActive = true
                backgroundView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 60).isActive = true
                backgroundView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -60).isActive = true
                backgroundView.bottomAnchor.constraint(equalTo: factView.topAnchor, constant: -30).isActive = true
            case 2688:
                print("iPhone XS Max")
                backgroundView.topAnchor.constraint(equalTo: view.topAnchor, constant: 320).isActive = true
                backgroundView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 65).isActive = true
                backgroundView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -65).isActive = true
                backgroundView.bottomAnchor.constraint(equalTo: factView.topAnchor, constant: -40).isActive = true
            case 1792:
                print("iPhone XR")
                
                backgroundView.topAnchor.constraint(equalTo: view.topAnchor, constant: 320).isActive = true
                backgroundView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 65).isActive = true
                backgroundView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -65).isActive = true
                backgroundView.bottomAnchor.constraint(equalTo: factView.topAnchor, constant: -40).isActive = true
                
            default:
                print("Unknown")
            }
        }
    }
    
}


