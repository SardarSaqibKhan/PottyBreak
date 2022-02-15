//
//  RefineSearchVC.swift
//  PottyBreak
//
//  Created by MacBook Pro on 01/04/2019.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import CoreLocation

class RefineSearchVC: UIViewController {
    
    @IBOutlet weak var ratingoneImage: UIImageView!
    @IBOutlet weak var ratingtwoImage: UIImageView!
    @IBOutlet weak var ratingthreeImage: UIImageView!
    @IBOutlet weak var ratingfourImage: UIImageView!
    
    @IBOutlet weak var wheelchairimage: UIImageView!
    @IBOutlet weak var wheelchairLabel: UILabel!
    
    @IBOutlet weak var changingstationimage: UIImageView!
    @IBOutlet weak var changingStationLabel: UILabel!
    
    @IBOutlet weak var waterfountainimage: UIImageView!
    @IBOutlet weak var waterFountainLabel: UILabel!
    
    @IBOutlet weak var wifiaccessimage: UIImageView!
    @IBOutlet weak var wifiLabel: UILabel!
    
    @IBOutlet weak var familyimage: UIImageView!
    @IBOutlet weak var familyLabel: UILabel!
        
    @IBOutlet weak var DistanceLabel:UILabel!
    
    @IBOutlet weak var sliderP: UISlider!
    
    var ref: DatabaseReference!
    var requiredRating : Double = 0
    var arry = ["WheelChair","Stations","Fontain","Wifi","Family"]
    var requiredService = ["WheelChair":false,"Fontain":false,"Stations":false,"Wifi":false,"Family":false]
    let givenarr = ["b2d06d49964349a99ac9263c3ae61bdf777e2688","eb4c8fbb9a2084be17dfcb18b2916109beb35339"]
    var onlyoneserive :String = "0"
    var placesArr = [Toilet]();
    var includedPlacesArr = [Toilet]()
    
    var rtoilets = [Toilet]();
    var mtoilets = [Toilet]();
    var stoilets = [Toilet]();
    var r1toilets = [String]();
    var m1toilets = [String]();
    var s1toilets = [String]();
    var servicearry = [String]()
    
    var sildervalue : Double = 0
    var currentLocation: CLLocation?;
    var count  = 1
    
    var DG = DispatchGroup();
    var RefineDelegate:RefineSearchProtocol?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        ref = Database.database().reference()
        
        
        
        settingTapGesturseOnRatingImages()
        ratingoneImage.customCheckBoxs()
        ratingtwoImage.customCheckBoxs()
        ratingthreeImage.customCheckBoxs()
        ratingfourImage.customCheckBoxs()
        
        wheelchairimage.customCheckBoxs()
        changingstationimage.customCheckBoxs()
        waterfountainimage.customCheckBoxs()
        wifiaccessimage.customCheckBoxs()
        familyimage.customCheckBoxs()
        if let latitude = UserDefaults.standard.value(forKey: "UserCurrentLatitude") as? CLLocationDegrees
            , let longitude = UserDefaults.standard.value(forKey: "UserCurrentLongitude") as? CLLocationDegrees
        {
            currentLocation = CLLocation(latitude: latitude, longitude: longitude)
            print("Current Location Long=\(longitude),Lat=\(latitude)")
        }
        else
        {
            print("User Location is not Found")
        }
        
        
        
    }
    
    
    
    @IBAction func SliderValueChanged(_ sender: UISlider) {
        print(sender.value)
        
        sildervalue = Double(sender.value)
        DistanceLabel.text = String(Int(sildervalue)) + "ml"
        
    }
    
    
    @IBAction func RefineSearch(_ sender: Any) {
        var c = 0
        for a in requiredService.values
        {
            
            if a
            {
                servicearry.append(arry[c])
                print(servicearry)
            }
            c = c+1
            
        }
        SearchByRequirment()
        
        
    }
    
    @IBAction func clearFilters(_ sender: Any) {
        clear();
    }
    func clear()
    {
        sliderP.value = 0;
        requiredRating = 0;
        requiredService = ["WheelChair":false,"Fontain":false,"Stations":false,"Wifi":false,"Family":false]
        
        ratingoneImage.image = UIImage(named: "")
        ratingtwoImage.image = UIImage(named: "")
        ratingthreeImage.image = UIImage(named: "")
        ratingfourImage.image = UIImage(named: "")
        
        wheelchairimage.image = UIImage(named: "")
        changingstationimage.image = UIImage(named: "")
        waterfountainimage.image = UIImage(named: "")
        wifiaccessimage.image = UIImage(named: "")
        familyimage.image = UIImage(named: "")
        
        DistanceLabel.text = "0 ml"
        
    }
}
//// Tap Gesture for Rating
extension RefineSearchVC{
    
    func settingTapGesturseOnRatingImages(){
        let tap1 = ratingGesture(target: self, action: #selector(RefineSearchVC.handleTap(_:)))
        ratingoneImage.addGestureRecognizer(tap1)
        tap1.id = 0
        let tap2 = ratingGesture(target: self, action: #selector(RefineSearchVC.handleTap(_:)))
        ratingtwoImage.addGestureRecognizer(tap2)
        tap2.id = 1
        let tap3 = ratingGesture(target: self, action: #selector(RefineSearchVC.handleTap(_:)))
        ratingthreeImage.addGestureRecognizer(tap3)
        tap3.id = 2
        let tap4 = ratingGesture(target: self, action: #selector(RefineSearchVC.handleTap(_:)))
        ratingfourImage.addGestureRecognizer(tap4)
        tap4.id = 3
        /////// for accessabilities
        
        let tap5 = ratingGesture(target: self, action: #selector(RefineSearchVC.handleTap(_:)))
        let tap55 = ratingGesture(target: self, action: #selector(RefineSearchVC.handleTap(_:)))
        wheelchairimage.addGestureRecognizer(tap5)
        wheelchairLabel.addGestureRecognizer(tap55)
        tap5.id = 4
        tap55.id = 4
        
        let tap6 = ratingGesture(target: self, action: #selector(RefineSearchVC.handleTap(_:)))
        let tap66 = ratingGesture(target: self, action: #selector(RefineSearchVC.handleTap(_:)))
        changingstationimage.addGestureRecognizer(tap6)
        changingStationLabel.addGestureRecognizer(tap66)
        tap6.id = 5
        tap66.id = 5
        
        let tap7 = ratingGesture(target: self, action: #selector(RefineSearchVC.handleTap(_:)))
        let tap77 = ratingGesture(target: self, action: #selector(RefineSearchVC.handleTap(_:)))
        waterfountainimage.addGestureRecognizer(tap7)
        waterFountainLabel.addGestureRecognizer(tap77)
        tap7.id = 6
        tap77.id = 6
        
        let tap8 = ratingGesture(target: self, action: #selector(RefineSearchVC.handleTap(_:)))
        let tap88 = ratingGesture(target: self, action: #selector(RefineSearchVC.handleTap(_:)))
        wifiaccessimage.addGestureRecognizer(tap8)
        wifiLabel.addGestureRecognizer(tap88)
        tap8.id = 7
        tap88.id = 7
        
        let tap9 = ratingGesture(target: self, action: #selector(RefineSearchVC.handleTap(_:)))
        let tap99 = ratingGesture(target: self, action: #selector(RefineSearchVC.handleTap(_:)))
        familyimage.addGestureRecognizer(tap9)
        familyLabel.addGestureRecognizer(tap99)
        tap9.id = 8
        tap99.id = 8
        
        
    }
    
    // function which is triggered when handleTap is called
    @objc func handleTap(_ sender: ratingGesture) {
        let id = sender.id!
        if id == 0 {
            ratingoneImage.image = UIImage(named: "checkmark")
            ratingtwoImage.image = UIImage(named: "")
            ratingthreeImage.image = UIImage(named: "")
            ratingfourImage.image = UIImage(named: "")
            self.requiredRating = 1.0
        }
        else if id == 1
        {
            ratingoneImage.image = UIImage(named: "")
            ratingtwoImage.image = UIImage(named: "checkmark")
            ratingthreeImage.image = UIImage(named: "")
            ratingfourImage.image = UIImage(named: "")
            self.requiredRating = 2.0
        }
        else if id == 2{
            ratingoneImage.image = UIImage(named: "")
            ratingtwoImage.image = UIImage(named: "")
            ratingthreeImage.image = UIImage(named: "checkmark")
            ratingfourImage.image = UIImage(named: "")
            self.requiredRating = 3.0
        }
        else if id == 3{
            ratingoneImage.image = UIImage(named: "")
            ratingtwoImage.image = UIImage(named: "")
            ratingthreeImage.image = UIImage(named: "")
            ratingfourImage.image = UIImage(named: "checkmark")
            self.requiredRating = 4.0
        }
            
        else if id == 4{
            if wheelchairimage.image == UIImage(named: "checkmark"){
                wheelchairimage.image = UIImage(named: "")
                requiredService["WheelChair"] = false
            }
            else{
                wheelchairimage.image = UIImage(named: "checkmark")
                requiredService["WheelChair"] = true
                self.onlyoneserive = "WheelChair"
            }
            
        }
        else if id == 5{
            
            
            if changingstationimage.image == UIImage(named: "checkmark"){
                changingstationimage.image = UIImage(named: "")
                requiredService["Stations"] = false
            }
            else{
                changingstationimage.image = UIImage(named: "checkmark")
                requiredService["Stations"] = true
                self.onlyoneserive = "Stations"
            }
            
        }
        else if id == 6{
            
            
            if waterfountainimage.image == UIImage(named: "checkmark"){
                waterfountainimage.image = UIImage(named: "")
                requiredService["Fontain"] = false
            }
            else{
                waterfountainimage.image = UIImage(named: "checkmark")
                requiredService["Fontain"] = true
                self.onlyoneserive = "Fontain"
            }
            
            
        }
        else if id == 7{
            if wifiaccessimage.image == UIImage(named: "checkmark"){
                wifiaccessimage.image = UIImage(named: "")
                requiredService["Wifi"] = false
            }
            else{
                wifiaccessimage.image = UIImage(named: "checkmark")
                requiredService["Wifi"] = true
                self.onlyoneserive = "Wifi"
            }
            
        }else if id == 8{
            if familyimage.image == UIImage(named: "checkmark"){
                familyimage.image = UIImage(named: "")
                requiredService["Family"] = false
            }
            else{
                familyimage.image = UIImage(named: "checkmark")
                requiredService["Family"] = true
                self.onlyoneserive = "Family"
            }
            
        }
        
    }
}
class ratingGesture: UITapGestureRecognizer {
    var id:Int?
    
}
////////Searching throgh the Required Cratria
extension RefineSearchVC{
    
    
    func SearchByRequirment(){
        var withinMeters = self.sildervalue * 1609
        var isIncluded = true;
        var LastID = ""
        if placesArr.count > 0
        {
            LastID = placesArr[placesArr.count-1].id!;
        }
        for item in placesArr{
            
            ref.child("Ratings").child(item.id!).observeSingleEvent(of: .value, with: { (snapshot) in
                
                isIncluded = true;
                let value = snapshot.value as? NSDictionary
                
                if value != nil{
                    let rating = value!["rating"] as? Double ?? 0.0
                    let service = value!["Services"] as? [String:Bool] ?? [:]
                    let numberofuser = value!["Total_Number_of_USer"] as? Double ?? 0
                    var flag = false
                    
                    var totalratingoogle = item.ratings! * Double( item.user_ratings_total! )
                    var totalratingdatabase = rating * numberofuser
                    var totaluser =  Double( item.user_ratings_total! ) + numberofuser
                    
                    
                    var totaltrating = (totalratingoogle + totalratingdatabase ) / totaluser
                    
                    ///Service Check ["WheelChair":false,"Fontain":false,"Stations":false,"Wifi":false]
                    if self.requiredService["WheelChair"]!
                    {
                        if let serviceFromFB = service["WheelChair"] as? Bool
                        {
                            if !serviceFromFB
                            {
                                isIncluded = false;
                            }
                        }
                        else
                        {
                            isIncluded = false;
                        }
                    }
                    
                    if self.requiredService["Fontain"]!
                    {
                        if let serviceFromFB = service["Fontain"] as? Bool
                        {
                            if !serviceFromFB
                            {
                                isIncluded = false;
                            }
                        }
                        else
                        {
                            isIncluded = false;
                        }
                    }
                    if self.requiredService["Stations"]!
                    {
                        if let serviceFromFB = service["Stations"] as? Bool
                        {
                            if !serviceFromFB
                            {
                                isIncluded = false;
                            }
                        }
                        else
                        {
                            isIncluded = false;
                        }
                    }
                    if self.requiredService["Wifi"]!
                    {
                        if let serviceFromFB = service["Wifi"] as? Bool
                        {
                            if !serviceFromFB
                            {
                                isIncluded = false;
                            }
                        }
                        else
                        {
                            isIncluded = false;
                        }
                    }
                    if self.requiredService["Family"]!
                    {
                        if let serviceFromFB = service["Family"] as? Bool
                        {
                            if !serviceFromFB
                            {
                                isIncluded = false;
                            }
                        }
                        else
                        {
                            isIncluded = false;
                        }
                    }
                    if self.requiredRating != 0 //RAting Check
                    {
                        if totaltrating >= self.requiredRating
                        {
                            self.r1toilets.append(item.id!)
                            print("including Item Req:\(self.requiredRating),\(totaltrating)")
                        }
                        else
                        {
                            //Exclude this
                            isIncluded = false;
                            print("Excluding Item Req:\(self.requiredRating),\(totaltrating)")
                            //return
                        }
                    }
                    
                    if self.sildervalue != 0  //Distance
                    {
                        
                        var withinMeters = self.sildervalue * 1609
                        if let currentLoc = self.currentLocation{
                            var itemLocation = CLLocation(latitude: (item.location?.latitude)!, longitude: (item.location?.longitude)!);
                            var distance = itemLocation.distance(from: currentLoc);
                            if distance <= withinMeters
                            {
                                print("Distance included Selected: \(withinMeters),measured:\(distance)")
                            }
                            else
                            {
                                isIncluded = false;
                                print("Distance Excluded Selected: \(withinMeters),measured:\(distance)")
                            }
                            
                        }
                        else
                        {
                            //Show User and include
                            print("Current Location is Nil")
                        }
                    }
                    
                    
                    
                    
                }     //
                else  //nil Found Check google only
                {
                    
                    print(item.id!)
                    //Any Service Checked Exclude
                    for (key,value) in self.requiredService
                    {
                        if value
                        {
                            isIncluded = false;
                        }
                    }
                    if self.requiredRating != 0 //RAting Check
                    {
                        if item.ratings! >= self.requiredRating
                        {
                            self.r1toilets.append(item.id!)
                            print("including Item Req:\(self.requiredRating),\(item.ratings!)")
                        }
                        else
                        {
                            
                            isIncluded = false;
                            print("Excluding Item Req:\(self.requiredRating),\(item.ratings!)")
                            //return
                        }
                    }
                    
                    if self.sildervalue != 0  //Distance
                    {
                        if let currentLoc = self.currentLocation{
                            var itemLocation = CLLocation(latitude: (item.location?.latitude)!, longitude: (item.location?.longitude)!);
                            var distance = itemLocation.distance(from: currentLoc);
                            if distance <= withinMeters
                            {
                                print("Distance included Selected: \(withinMeters),measured:\(distance)")
                            }
                            else
                            {
                                // print("EXCLUDE")
                                isIncluded = false;
                                print("Distance Excluded Selected: \(withinMeters),measured:\(distance)")
                            }
                            
                        }
                        else
                        {
                            //Show User and include
                            print("Current Location is Nil")
                        }
                        
                    }
                    
                }
                //Final Checks
                if isIncluded{
                    self.includedPlacesArr.append(item);
                    
                    
                }
                if LastID == item.id!
                {
                    self.RefineDelegate?.getRefineDataBack(data: self.includedPlacesArr)
                    //  self.dismiss(animated: true, completion: nil)
                    self.navigationController?.popViewController(animated: true)
                    print("Count:\(self.includedPlacesArr.count)")
                }
            }) }
    }
}
