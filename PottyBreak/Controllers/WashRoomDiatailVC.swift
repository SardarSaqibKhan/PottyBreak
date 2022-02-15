//
//  WashRoomDiatailVC.swift
//  PottyBreak
//
//  Created by MacBook Pro on 04/04/2019.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//



import UIKit
import GoogleMaps
import GooglePlaces
import Alamofire
import FirebaseDatabase
import FirebaseStorage
import Firebase
import SDWebImage


class WashRoomDiatailVC: UIViewController {
    
    
    @IBOutlet weak var thumpnilLabel: UILabel!
    
    @IBOutlet weak var getDirectionButton: UIButton!
    @IBOutlet weak var LeaveReviewButton: UIButton!
    @IBOutlet weak var washroomimagesCollectionView: UICollectionView!
    
    @IBOutlet weak var mapView: GMSMapView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratedImage: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var ratingoneImage: UIImageView!
    @IBOutlet weak var ratingtwoImage: UIImageView!
    @IBOutlet weak var ratingthreeImage: UIImageView!
    @IBOutlet weak var ratingfourImage: UIImageView!
    
    let groupDownload = DispatchGroup()
    let array = ["cover","cover","cover","cover","cover"]
    var imageUrls = [String]();
    let locationManager = CLLocationManager()
    var recivingMarker:customMarker?
    var mymap:GMSMapView?
    var uploadingImage:UIImage?
    // let storage = Storage.storage()
    var Databaseref: DatabaseReference!
    var bathroomID = String()
    var imagesArray = [UIImage]()
    let storageRef = StorageReference()
    var picArray = [UIImage]()
    var washroomtitle = String()
    
    /////
    var ratings : Double?
    var numberofuser : Int?
    var transferImagePath = String()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        thumpnilLabel.isHidden = true
        getDirectionButton.carveButton()
        LeaveReviewButton.carveButton()
        settingTapGesturseOnNewImage()
        ratingoneImage.alpha = 0.3
        ratingtwoImage.alpha = 0.3
        ratingthreeImage.alpha = 0.3
        ratingfourImage.alpha = 0.3
        setingMapOnView()
        
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        getImagesAndRatings()
        
        
    }
    
    @IBAction func leaveareview(_ sender: Any) {
        
        //newuploading()
        self.performSegue(withIdentifier: "RateABathroomVC", sender: nil)
    }
    
    
    @IBAction func getDirection(_ sender: Any) {
        print("tapped")
        self.performSegue(withIdentifier: "GetDirectionsVC", sender: nil)
    }
    
    
}
////setting map on view
extension WashRoomDiatailVC:CLLocationManagerDelegate{
    func setingMapOnView(){
        
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        mapView.delegate = self as? GMSMapViewDelegate
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: (self.recivingMarker?.position.latitude)!,longitude: (self.recivingMarker?.position.longitude)!)
        marker.title = self.recivingMarker?.title
        marker.snippet = self.recivingMarker?.snippet
        marker.icon = self.recivingMarker?.icon
        marker.map = mapView
        
        let mycamera = GMSCameraPosition.camera(withLatitude: (self.recivingMarker?.position.latitude)!, longitude: (self.recivingMarker?.position.longitude)! , zoom: 18.0)
        mapView.camera = mycamera
        DispatchQueue.main.async {
            
            var point = self.mapView.projection.point(for: marker.position)
            let camera = self.mapView.projection.coordinate(for: point)
            let position = GMSCameraUpdate.setTarget(camera)
            self.mapView.animate(with: position)
            self.mapView.isMyLocationEnabled = true
            
        }
        
        
        if recivingMarker!.isNotToilet { nameLabel.text = marker.title! + " Toilet" }
        else{ nameLabel.text = marker.title }
        addressLabel.text = marker.snippet
        washroomtitle = marker.title!
        // mapView.setNeedsLayout()
        
    }
    
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        let mycamera = GMSCameraPosition.camera(withLatitude: (self.recivingMarker?.position.latitude)!, longitude: (self.recivingMarker?.position.longitude)! , zoom: 18.0)
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: 18.0)
        
        mapView.camera = mycamera
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        marker.title = "ABS"
        marker.snippet = "AST"
        marker.map = mapView
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }
}

//////////adding tap gesture on new image
extension WashRoomDiatailVC{
    func settingTapGesturseOnNewImage(){
        
        let tap1 = ratingGesture(target: self, action: #selector(WashRoomDiatailVC.handleTap(_:)))
        ratingoneImage.addGestureRecognizer(tap1)
        tap1.id = 1
        let tap2 = ratingGesture(target: self, action: #selector(WashRoomDiatailVC.handleTap(_:)))
        ratingtwoImage.addGestureRecognizer(tap2)
        tap2.id = 2
        let tap3 = ratingGesture(target: self, action: #selector(WashRoomDiatailVC.handleTap(_:)))
        ratingthreeImage.addGestureRecognizer(tap3)
        tap3.id = 3
        let tap4 = ratingGesture(target: self, action: #selector(WashRoomDiatailVC.handleTap(_:)))
        ratingfourImage.addGestureRecognizer(tap4)
        tap4.id = 4
        
        /////// for accessabilities
    }
    @objc func handleTap(_ sender: ratingGesture) {
        
        let id = sender.id
        if id == 0 {
            
        }
        else if id == 1 {
            ratedImage.image = UIImage(named: "btn_rating1")
            ratingoneImage.alpha = 1.0
            ratingtwoImage.alpha = 0.3
            ratingthreeImage.alpha = 0.3
            ratingfourImage.alpha = 0.3
        }
        else if id == 2 {
            ratedImage.image = UIImage(named: "btn_rating2")
            ratingoneImage.alpha = 0.3
            ratingtwoImage.alpha = 1.0
            ratingthreeImage.alpha = 0.3
            ratingfourImage.alpha = 0.3
        }
        else if id == 3 {
            ratedImage.image = UIImage(named: "btn_rating3")
            ratingoneImage.alpha = 0.3
            ratingtwoImage.alpha = 0.3
            ratingthreeImage.alpha = 1.0
            ratingfourImage.alpha = 0.3
        }
        else if id == 4 {
            ratedImage.image = UIImage(named: "btn_rating4")
            ratingoneImage.alpha = 0.3
            ratingtwoImage.alpha = 0.3
            ratingthreeImage.alpha = 0.3
            ratingfourImage.alpha = 1.0
        }
        
    }
}

//////collection view datasourse
extension WashRoomDiatailVC:UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("image urls count\(imageUrls.count)")
        
        return imageUrls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WashRoomDiatailcell", for: indexPath) as! WashRoomDiatailCollectionViewCell
        //  cell.bathroomImage.image =  UIImage(named: array[indexPath.row])
        groupDownload.enter()
        cell.bathroomImage.sd_setIndicatorStyle(.gray);
        cell.bathroomImage.sd_setShowActivityIndicatorView(true)
        
        let path = imageUrls[indexPath.row];
        print(path);
        
        cell.bathroomImage.sd_setImage(with: URL(string: path)) { (img, error, cacheType, url) in
            
            self.groupDownload.leave()
            
        };
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
        self.transferImagePath = imageUrls[indexPath.row]
        showImagePopUp()
        
    }
    
    
}
class WashRoomDiatailCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var bathroomImage:UIImageView!
    
}

////// preparing for segues
extension WashRoomDiatailVC{
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GetDirectionsVC"{
            let desti = segue.destination as! GetDirectionsVC
            desti.recivingMarker = self.recivingMarker
            setRatingFlags()
            
        }
        else if segue.identifier == "RateABathroomVC"{
            let vc = segue.destination as! RateABathroomVC
            vc.recivingMarker = recivingMarker;
            vc.ratings = ratings
            vc.numberofuser = numberofuser
        }
    }
    func setRatingFlags()
    {
        let placeID = recivingMarker?.id
        let name = recivingMarker?.title
        let address = recivingMarker?.snippet
        UserDefaults.standard.set(placeID, forKey: "placeID")
        UserDefaults.standard.set(name, forKey: "title")
        UserDefaults.standard.set(address, forKey: "address")
        
        if let rat = ratings{UserDefaults.standard.set(rat, forKey: "ratings")}
        else{UserDefaults.standard.set(0.0, forKey: "ratings")}
        
        if let numberOfUsers = numberofuser{UserDefaults.standard.set(numberOfUsers, forKey: "users")}
        else{UserDefaults.standard.set(0, forKey: "users")}
        
        
    }
}
/////// After Integration
extension WashRoomDiatailVC{
    func getImagesAndRatings()
    {
        Database.database().reference().child("Ratings").child("\(self.bathroomID)").child("imageUrls").observe(.value) { (snapshot) in
            let json1 = snapshot.value as? [String: String]
            if let json = json1{
                self.thumpnilLabel.isHidden = true
                self.imageUrls.removeAll()
                for (_, url) in json
                {
                    self.imageUrls.append(url);
                }
                DispatchQueue.main.async(execute: {
                    self.washroomimagesCollectionView.reloadData()
                })
            }
            else
            {
                print("No images found in Firebase For this bathroom")
                self.thumpnilLabel.isHidden = false
            }
        }
        let googleRatings = recivingMarker?.rating!;
        let gooleNumberOfRatings = recivingMarker?.user_ratings_total!;
        print("Google=\(googleRatings!),\(gooleNumberOfRatings!)")
        Database.database().reference().child("Ratings").child("\(self.bathroomID)").observe(.value) { (snapshot) in
            let value = snapshot.value as? NSDictionary
            
            if value != nil{
                let rating = value!["rating"] as? Double ?? 0.0
                self.ratings = rating
                let service = value!["Services"] as? [String:Bool] ?? [:]
                let numberofuser = value!["Total_Number_of_USer"] as? Double ?? 0
                self.numberofuser = Int(numberofuser) ;
                var totalratingoogle = googleRatings! * Double(gooleNumberOfRatings!)
                var totalratingdatabase = rating * numberofuser
                var totaluser =  Double( gooleNumberOfRatings! ) + numberofuser
                
                
                var totaltrating:Double = (totalratingoogle + totalratingdatabase ) / totaluser
                DispatchQueue.main.async(execute: {
                    if totaltrating > 4.0
                    {
                        self.ratedImage.image = UIImage(named: "btn_rating4")
                        self.ratingoneImage.alpha = 0.3
                        
                        self.ratingtwoImage.alpha = 0.3
                        self.ratingthreeImage.alpha = 0.3
                        self.ratingfourImage.alpha = 1.0
                    }
                    else if totaltrating > 3.0
                    {
                        self.ratedImage.image = UIImage(named: "btn_rating3")
                        self.ratingoneImage.alpha = 0.3
                        self.ratingtwoImage.alpha = 0.3
                        self.ratingthreeImage.alpha = 1.0
                        self.ratingfourImage.alpha = 0.3
                        
                    }
                    else if totaltrating > 2.0
                    {
                        self.ratedImage.image = UIImage(named: "btn_rating2")
                        self.ratingoneImage.alpha = 0.3
                        self.ratingtwoImage.alpha = 1.0
                        self.ratingthreeImage.alpha = 0.3
                        self.ratingfourImage.alpha = 0.3
                        
                    }
                    else if totaltrating > 1.0
                    {
                        self.ratedImage.image = UIImage(named: "btn_rating1")
                        self.ratingoneImage.alpha = 1.0
                        self.ratingtwoImage.alpha = 0.3
                        self.ratingthreeImage.alpha = 0.3
                        self.ratingfourImage.alpha = 0.3
                    }
                    // ifElseStructureEnds
                })//DisptachEnds
                
            } //Value nil checker End
            else
            {
                var totaltrating = googleRatings!;
                
                DispatchQueue.main.async(execute: {
                    if totaltrating > 4.0
                    {
                        self.ratedImage.image = UIImage(named: "btn_rating4")
                        self.ratingoneImage.alpha = 0.3
                        self.ratingtwoImage.alpha = 0.3
                        self.ratingthreeImage.alpha = 0.3
                        self.ratingfourImage.alpha = 1.0
                        
                    }
                    else if totaltrating > 3.0
                    {
                        self.ratedImage.image = UIImage(named: "btn_rating3")
                        self.ratingoneImage.alpha = 0.3
                        self.ratingtwoImage.alpha = 0.3
                        self.ratingthreeImage.alpha = 1.0
                        self.ratingfourImage.alpha = 0.3
                        
                    }
                    else if totaltrating > 2.0
                    {
                        self.ratedImage.image = UIImage(named: "btn_rating2")
                        self.ratingoneImage.alpha = 0.3
                        self.ratingtwoImage.alpha = 1.0
                        self.ratingthreeImage.alpha = 0.3
                        self.ratingfourImage.alpha = 0.3
                        
                    }
                    else if totaltrating > 1.0
                    {
                        self.ratedImage.image = UIImage(named: "btn_rating1")
                        self.ratingoneImage.alpha = 1.0
                        self.ratingtwoImage.alpha = 0.3
                        self.ratingthreeImage.alpha = 0.3
                        self.ratingfourImage.alpha = 0.3
                    }
                    // ifElseStructureEnds
                })//DispatchEnds
            } // else Ends
        }// Ends Firebase Closure
    }//getImagesAndRatings Ends
}
extension WashRoomDiatailVC{
    func showImagePopUp(){
        let popVC = UIStoryboard.init(name: "Main", bundle:nil).instantiateViewController(withIdentifier: "WashRoomImageVC") as! WashRoomImageVC
        popVC.recivedImagePath = self.transferImagePath
        self.addChild(popVC)
        popVC.view.frame = self.view.frame
        self.view.addSubview(popVC.view)
        popVC.didMove(toParent: self)
    }
   
}
