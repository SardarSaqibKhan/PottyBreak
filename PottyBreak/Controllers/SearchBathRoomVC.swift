//
//  SearchBathRoomVC.swift
//  PottyBreak
//
//  Created by Moheed Zafar Hashmi on 02/04/2019.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import GoogleMapsBase
import Alamofire
class SearchBathRoomVC: UIViewController{
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var viewArticalImage: UIImageView!
    @IBOutlet weak var popImage: UIImageView!
    @IBOutlet weak var gameImage: UIImageView!
    var markers = [customMarker]()
    
    let locationManager = CLLocationManager()
    let currentLocationMarker = GMSMarker()
    
    var searchActive : Bool = false
    var washroomID:String = ""
    var ForwardingArray = [Toilet]();
    var forwardingMarker:customMarker?
    var CurrentLocation:CLLocation? = CLLocation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
        
        self.mapView.isMyLocationEnabled = false
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        searchBar.delegate = self;
        mapView.delegate = self
 
        settingTapGesturseOnNewImage()
        fechingUserCurrentLocation()
        let searchBarStyle = searchBar.value(forKey: "searchField") as? UITextField
        searchBarStyle?.clearButtonMode = .never
        settingTapGesturseOnView()
        
        
      
        

    }
    

    @IBAction func refine(_ sender: Any) {
        self.performSegue(withIdentifier: "refinesegue", sender: nil)
    }
    
 
    
    
    
}
extension SearchBathRoomVC : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: 6.0)
        CurrentLocation = location
        self.animateMap(vancouver: location.coordinate)
  //      mapView.camera = camera
//        let fancy = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
//                                             longitude: location.coordinate.longitude,
//                                             zoom: 18,
//                                             bearing: 270,
//                                             viewingAngle: 45)
//        mapView.camera = fancy
//        mapView.animate(toViewingAngle: 45)
        
        addCurrentLocationMarker()
       

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
extension SearchBathRoomVC : UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        searchBathRoom(searchText: searchText)

    }
    
    
}
extension SearchBathRoomVC:GMSMapViewDelegate{
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
       
        
        if marker.icon == UIImage(named: "walking"){
            return false
        }
        else{
            let custommarker = marker as? customMarker
            print(marker.title)
            print(marker.snippet!)
            // print(custommarker!.id!)
            
            print(mapView.myLocation)
            self.washroomID = (custommarker?.id)!
            
            self.forwardingMarker = custommarker
            
            performSegue(withIdentifier: "WashRoomDiatailVC", sender: nil)
            return true
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ratingsegue"{
            let dastination = segue.destination as! RateABathroomVC
            dastination.bathroomid = self.washroomID
            
        }
        else if segue.identifier == "WashRoomDiatailVC"{
//            let Nav = segue.destination as! UINavigationController
//            let dastination = Nav.viewControllers.first as! WashRoomDiatailVC
           
            let dastination = segue.destination as! WashRoomDiatailVC
            
           dastination.recivingMarker = self.forwardingMarker
           dastination.mymap = self.mapView
           dastination.bathroomID = self.washroomID
        }
        else if segue.identifier == "refinesegue"{
            let dasti = segue.destination as! RefineSearchVC
            dasti.placesArr = self.ForwardingArray
            dasti.RefineDelegate = self;
        }
    }
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        self.view.endEditing(true)
    }
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        self.view.endEditing(true)
    }
    func animateMap(vancouver:CLLocationCoordinate2D)
    {
        delay(seconds: 2.0) { () -> () in
            let zoomOut = GMSCameraUpdate.zoom(to: 0)
            self.mapView.animate(with: zoomOut)
            
            self.delay(seconds: 0.0, closure: { () -> () in
                
                
                var vancouverCam = GMSCameraUpdate.setTarget(vancouver)
                self.mapView.animate(toLocation: vancouver)
                
                self.delay(seconds: 0.5, closure: { () -> () in
                    self.moveMarker()
                    let zoomIn = GMSCameraUpdate.zoom(to: 15)
                    self.mapView.animate(with: zoomIn)
                    
                })
            })
        }
    }
    func delay(seconds: Double, closure: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            closure()
        }
    }
}
extension SearchBathRoomVC{
    func settingTapGesturseOnNewImage(){
        let tap = ratingGesture(target: self, action: #selector(SearchBathRoomVC.handleTap(_:)))
        viewArticalImage.addGestureRecognizer(tap)
        tap.id = 0
        let tap1 = ratingGesture(target: self, action: #selector(SearchBathRoomVC.handleTap(_:)))
        popImage.addGestureRecognizer(tap1)
        tap1.id = 1
        let tap2 = ratingGesture(target: self, action: #selector(SearchBathRoomVC.handleTap(_:)))
        gameImage.addGestureRecognizer(tap2)
        tap2.id = 2
        
        
    }
    @objc func handleTap(_ sender: ratingGesture) {
        
        let id = sender.id
        if id == 1 {
            self.performSegue(withIdentifier: "article", sender: nil)
           // present(UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "article"), animated: true, completion: nil)
        }
        else if id == 0 {
        //  present(UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "nav"), animated: true, completion: nil)
            self.performSegue(withIdentifier: "AllContactsTableViewController", sender: nil)
            
        }
        else if id == 2
        {
            self.performSegue(withIdentifier: "GameViewController", sender: nil)
        }
      
    }
}
/////searchig the
extension SearchBathRoomVC{
    
    func searchBathRoom(searchText:String){
        
        let publicToiletUrl = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=Public toilets Near \(searchText) &key=AIzaSyAqu4LBAcUGQ19eORpHjKSQqKDe9d_SimY"
        let restaurentsUrl = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=\(searchText)&type=restaurant&key=AIzaSyAqu4LBAcUGQ19eORpHjKSQqKDe9d_SimY"
        let busStationsUrl = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=\(searchText)&type=bus_station&key=AIzaSyAqu4LBAcUGQ19eORpHjKSQqKDe9d_SimY"
        processQuery(urlString: publicToiletUrl,isNotToilet: false)
        processQuery(urlString: restaurentsUrl,isNotToilet: true)
        processQuery(urlString: busStationsUrl,isNotToilet: true)
        
        
        
    }
    func processQuery(urlString:String,isNotToilet:Bool)
   {
    var escapedString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    Alamofire.request(escapedString!).responseJSON{
        response in
        var placesArr = [Toilet]();
        if let value = response.result.value as? [String:Any]
        {
            if let places = value["results"] as? [[String:Any]]
            {
                var count = 0;
                for place in places
                {
                    var toilet = Toilet(json: place,isNotToilet:isNotToilet)
                    placesArr.append(toilet);
                    
                    
                }
                
                for place in placesArr
                {
                    let state_marker = customMarker()
                    state_marker.id = place.id
                    state_marker.position = place.location!;
                    state_marker.title = place.name!;
                    state_marker.snippet = place.formatted_address!;
                    state_marker.isNotToilet = place.isNotToilet
                    state_marker.icon = UIImage(named: "marker")
                    state_marker.rating = place.ratings ?? 0.0
                    state_marker.user_ratings_total = place.user_ratings_total ?? 0
                    self.markers.append(state_marker);
                    state_marker.map = self.mapView
                    count = count + 1;
                    
                    
                }
                if placesArr.count>0
                {
                    if let cl = self.CurrentLocation
                    {
//                        let camera = GMSCameraPosition.camera(withLatitude: cl.coordinate.latitude, longitude: cl.coordinate.longitude
//                            , zoom: 18.0)
//
//                        self.mapView.camera = camera
//                        self.mapView.animate(toViewingAngle: 45)
                        self.animateMap(vancouver: CLLocationCoordinate2D(latitude: cl.coordinate.latitude, longitude: cl.coordinate.longitude))
                    }
                    else{
                        let camera = GMSCameraPosition.camera(withLatitude: (placesArr[0].location?.latitude)!, longitude: (placesArr[0].location?.longitude)!, zoom: 18.0)
                        
//                        self.mapView.camera = camera
//                        self.mapView.animate(toViewingAngle: 45)
                          self.animateMap(vancouver: CLLocationCoordinate2D(latitude: (placesArr[0].location?.latitude)!, longitude: (placesArr[0].location?.longitude)!))
                    }
                }
            }
            
        }
        self.ForwardingArray = placesArr
    }//Request End Here
    }
}
extension SearchBathRoomVC{
    func fechingUserCurrentLocation(){
        
        let latitude = UserDefaults.standard.value(forKey: "UserCurrentLatitude") as? CLLocationDegrees ?? (37.773972)
        let longitude = UserDefaults.standard.value(forKey: "UserCurrentLongitude") as? CLLocationDegrees ?? CLLocationDegrees(-122.431297)
        let address =  UserDefaults.standard.value(forKey: "UserCurrentAddress") as? String ?? "San Francisco"
        print(latitude)
        print(longitude)
        print(address)
   
        CurrentLocation = CLLocation(latitude: latitude, longitude: longitude)
        let newcamera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 18.0)
        self.mapView.camera = newcamera
        DispatchQueue.main.async {
            
            let point = self.mapView.projection.point(for: self.CurrentLocation!.coordinate)
            let camera = self.mapView.projection.coordinate(for: point)
            let position = GMSCameraUpdate.setTarget(camera)
            self.mapView.animate(with: position)
            self.mapView.isMyLocationEnabled = true
            self.addCurrentLocationMarker()
            
        }
        addCurrentLocationMarker()
        searchBathRoom(searchText: address)
    }
    
   
}
protocol RefineSearchProtocol:class {
    func getRefineDataBack(data:[Toilet])
}
extension SearchBathRoomVC:RefineSearchProtocol{
    func getRefineDataBack(data: [Toilet]) {
        self.mapView.clear()
    
        var count = 0;
        for place in data
        {
            let state_marker = customMarker()
            state_marker.id = place.id
            state_marker.position = place.location!;
            state_marker.title = place.name!;
            state_marker.snippet = place.formatted_address!;
            state_marker.isNotToilet = place.isNotToilet
            state_marker.icon = UIImage(named: "marker")
            state_marker.rating = place.ratings ?? 0.0
            state_marker.user_ratings_total = place.user_ratings_total ?? 0
             self.markers.append(state_marker);
            state_marker.map = self.mapView
            count += 1
           
            
        }
        if data.count > 0
        {
            let camera = GMSCameraPosition.camera(withLatitude: (data[0].location?.latitude)!, longitude: (data[0].location?.longitude)!, zoom: 18.0)
            self.mapView.camera = camera
        }
    }
}
//////// for hiding keyboard
extension SearchBathRoomVC{
    func settingTapGesturseOnView(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(SearchBathRoomVC.handleViewTap(_:)))
        self.mapView.addGestureRecognizer(tap)
        
    }
    @objc func handleViewTap(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
}
//////// MOVEING MORKER ////
extension SearchBathRoomVC{
    @objc func moveMarker(){
        let lat = CurrentLocation?.coordinate.latitude
        let long = CurrentLocation?.coordinate.longitude
        //lat += 0.0017
        
        CATransaction.begin()
        CATransaction.setValue(2.0, forKey: kCATransactionAnimationDuration)
        CATransaction.setCompletionBlock {
            //self.marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        }
        self.mapView.animate(to: GMSCameraPosition.camera(withLatitude: lat!, longitude: long!, zoom: 15))
        //self.marker.position = CLLocationCoordinate2D(latitude: self.lat, longitude: self.lon)
        CATransaction.commit()
        // self.marker.map = self.mapView
    }
}
///////////////////////////////// ADD CURRENT LOCATION MARKER ////////////////////
extension SearchBathRoomVC{
    func addCurrentLocationMarker() {
        self.mapView.isMyLocationEnabled = false
        let userLocationMarker = GMSMarker(position: CurrentLocation!.coordinate)
        userLocationMarker.icon = UIImage(named: "maps-and-flags (2)")
        userLocationMarker.map = mapView
    }

}
class customMarker: GMSMarker {
    var id:String?
    var rating:Double?
    var user_ratings_total:Int?
    var isNotToilet = false
}
