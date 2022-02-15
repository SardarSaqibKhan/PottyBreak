
import UIKit
import GoogleMaps
import GooglePlaces
import Alamofire

enum Location {
    case startLocation
    case destinationLocation
}

class GetDirectionsVC: UIViewController , GMSMapViewDelegate ,  CLLocationManagerDelegate {
    
    @IBOutlet weak var walkingImage: UIImageView!
    @IBOutlet weak var byCycleImage: UIImageView!
    @IBOutlet weak var drivingImage: UIImageView!
   // @IBOutlet weak var DisDurPlaceHolderImage: UIImageView!
    
    @IBOutlet weak var googleMaps: GMSMapView!
    var startLocation: UITextField!
    var destinationLocation: UITextField!
    
  //  @IBOutlet weak var distanceAndDurationView: UIView!
  //  @IBOutlet weak var distanceLabel: UILabel!
    //@IBOutlet weak var durationLabel: UILabel!
    
    @IBOutlet weak var carView: UIView!
    @IBOutlet weak var cycleView: UIView!
    @IBOutlet weak var walkView: UIView!
    @IBOutlet weak var carLabel: UILabel!
    @IBOutlet weak var cycleLabel: UILabel!
    @IBOutlet weak var walkLabel: UILabel!
    
    
    
    
    
    var locationManager = CLLocationManager()
    var locationSelected = Location.startLocation
    
    var locationStart = CLLocation()
    var locationEnd = CLLocation()
    var recivingMarker:customMarker?
    

    var mode = "driving"
    var distance = String()
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fechingUserCurrentLocation()
        
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startMonitoringSignificantLocationChanges()
        
      //  self.distanceAndDurationView.layer.borderColor = UIColor(displayP3Red: 170/255, green: 170/255, blue: 170/255, alpha: 1)
        //self.distanceAndDurationView.layer.borderWidth = 2
        //Your map initiation code
        self.googleMaps.delegate = self
        self.googleMaps?.isMyLocationEnabled = true
        self.googleMaps.settings.myLocationButton = true
        self.googleMaps.settings.compassButton = true
        self.googleMaps.settings.zoomGestures = true
        // drawPath(startLocation: CLLocation(latitude: -7.9293122, longitude: -7.9293122), endLocation: CLLocation(latitude: -7.9293122, longitude: -7.8293122))
        walkingImage.circleImage()
        drivingImage.circleImage()
        byCycleImage.circleImage()
        settingTapGesturseOnNewImage()
        
//        distanceAndDurationView.layer.borderColor = UIColor.darkGray.cgColor
//        distanceAndDurationView.layer.borderWidth = 0.5
//        distanceAndDurationView.layer.opacity = 0.8
        
        walkingImage.circleImage();
        drivingImage.circleImage(color: UIColor.yellow)
        byCycleImage.circleImage()
        
        carView.alpha = 0
        cycleView.alpha = 0
        walkView.alpha = 0
        
    }
    override func loadView() {
        super.loadView()
       

    }
    func fechingUserCurrentLocation(){
        
        
        let latitude = UserDefaults.standard.value(forKey: "UserCurrentLatitude") as? CLLocationDegrees ?? (37.773972)
        let longitude = UserDefaults.standard.value(forKey: "UserCurrentLongitude") as? CLLocationDegrees ?? CLLocationDegrees(-122.431297)
        let address =  UserDefaults.standard.value(forKey: "UserCurrentAddress") as? String ?? "San Francisco"
        locationStart = CLLocation(latitude: latitude, longitude: longitude)
        
        
        
    }
  
    // MARK: function for create a marker pin on map
    func createMarker(titleMarker: String, iconMarker: UIImage, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(latitude, longitude)
       // marker.title = titleMarker
        marker.title = self.distance
        marker.icon = iconMarker
        marker.map = googleMaps
        print("Coord:\(marker.position)")
        
    }
    
    //MARK: - Location Manager delegates
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error to get location : \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let locationTujuan = CLLocation(latitude:  (self.recivingMarker?.position.latitude)!, longitude: (self.recivingMarker?.position.longitude)!)
        
        createMarker(titleMarker: "Distance", iconMarker: UIImage(named: "marker")! , latitude: locationTujuan.coordinate.latitude, longitude: locationTujuan.coordinate.longitude)
        let camera = GMSCameraPosition.camera(withLatitude: (locationStart.coordinate.latitude), longitude: (locationStart.coordinate.longitude), zoom: 15.0)
        
        self.googleMaps.camera = camera
         locationEnd = locationTujuan
        drawPath(startLocation: locationStart, endLocation: locationTujuan)
        
        //        self.googleMaps?.animate(to: camera)
        self.locationManager.stopUpdatingLocation()
        
    }
    
    // MARK: - GMSMapViewDelegate
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        googleMaps.isMyLocationEnabled = true
        makeMarkerVisible()
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        googleMaps.isMyLocationEnabled = true
        
        if (gesture) {
            mapView.selectedMarker = nil
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        googleMaps.isMyLocationEnabled = true
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("COORDINATE \(coordinate)") // when you tapped coordinate
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        googleMaps.isMyLocationEnabled = true
        googleMaps.selectedMarker = nil
        return false
    }
 
  
    
    //MARK: - this is function for create direction path, from start location to desination location
    func drawPath(startLocation: CLLocation, endLocation: CLLocation)
    {
       // distanceAndDurationView.isHidden = true;
        
        let origin = "\(startLocation.coordinate.latitude),\(startLocation.coordinate.longitude)"
        let destination = "\(endLocation.coordinate.latitude),\(endLocation.coordinate.longitude)"
        
        
        //let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving"
        let url = "https://maps.googleapis.com/maps/api/directions/json?units=metric&origin=\(origin)&destination=\(destination)&key=AIzaSyAqu4LBAcUGQ19eORpHjKSQqKDe9d_SimY&mode=\(mode)"
        
        Alamofire.request(url).responseJSON { response in
            print(response.request as Any)  // original URL request
            print(response.response as Any) // HTTP URL response
            print(response.data as Any)     // server data
            print(response.result as Any)   // result of response serialization
            
            let json = JSON(data: response.data!)
            let routes = json["routes"].arrayValue
        
            // print route using Polyline
            for route in routes
            {
                
                let routeOverviewPolyline = route["overview_polyline"].dictionary
                let points = routeOverviewPolyline?["points"]?.stringValue
            
                let path = GMSPath.init(fromEncodedPath: points!)
                let polyline = GMSPolyline.init(path: path)
                polyline.strokeWidth = 4
                polyline.strokeColor = UIColor.red
                polyline.map = self.googleMaps
                
                let legs = route["legs"].array
                for leg in legs!
                {
                    let distance = leg["distance"].dictionary
                    let distanceText = distance!["text"]!.stringValue
                    self.distance = distanceText
                    
                    let duration = leg["duration"].dictionary
                    let durationText = duration!["text"]!.stringValue
                    DispatchQueue.main.async {
                        //self.modeLabel.text = self.mode
                        self.carLabel.text = durationText
                        self.carView.alpha = 1.0
                        self.cycleView.alpha = 0
                        self.walkView.alpha = 0
                        
                      
                        if self.mode == "walking"{
                           self.walkLabel.text = durationText
                            self.carView.alpha = 0
                            self.cycleView.alpha = 0
                            self.walkView.alpha = 1.0
                        }
                        else if self.mode == "bicycling"{
                             self.cycleLabel.text = durationText
                             self.carView.alpha = 0
                             self.cycleView.alpha = 1.0
                             self.walkView.alpha = 0
                        }
                        else if self.mode == "driving"{
                            self.carLabel.text = durationText
                            self.carView.alpha = 1.0
                            self.cycleView.alpha = 0
                            self.walkView.alpha = 0
                        }
//                        self.distanceLabel.text = distanceText
//                        self.durationLabel.text = durationText
//                        self.distanceAndDurationView.isHidden = false;
                    }
                }
            }
        }
    }
    
    // MARK: when start location tap, this will open the search location
    func openStartLocation(_ sender: UIButton) {
        
        let autoCompleteController = GMSAutocompleteViewController()
        autoCompleteController.delegate = self
        
        // selected location
        locationSelected = .startLocation
        
        // Change text color
        UISearchBar.appearance().setTextColor(color: UIColor.black)
        self.locationManager.stopUpdatingLocation()
        
        self.present(autoCompleteController, animated: true, completion: nil)
    }
    
    // MARK: when destination location tap, this will open the search location
    func openDestinationLocation(_ sender: UIButton) {
        
        let autoCompleteController = GMSAutocompleteViewController()
        autoCompleteController.delegate = self
        
        // selected location
        locationSelected = .destinationLocation
        
        // Change text color
        UISearchBar.appearance().setTextColor(color: UIColor.black)
        self.locationManager.stopUpdatingLocation()
        
        self.present(autoCompleteController, animated: true, completion: nil)
    }
    
    
    // MARK: SHOW DIRECTION WITH BUTTON
    func showDirection(_ sender: UIButton) {
        // when button direction tapped, must call drawpath func
        self.drawPath(startLocation: locationStart, endLocation: locationEnd)
    }
    
    
    
    
}

// MARK: - GMS Auto Complete Delegate, for autocomplete search location
extension GetDirectionsVC: GMSAutocompleteViewControllerDelegate {
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error \(error)")
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        // Change map location
        let camera = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude, longitude: place.coordinate.longitude, zoom: 16.0
        )
        
        // set coordinate to text
        if locationSelected == .startLocation {
            startLocation.text = "\(place.coordinate.latitude), \(place.coordinate.longitude)"
            locationStart = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
            createMarker(titleMarker: "Location Start", iconMarker: #imageLiteral(resourceName: "marker"), latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        } else {
            destinationLocation.text = "\(place.coordinate.latitude), \(place.coordinate.longitude)"
            locationEnd = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
            createMarker(titleMarker: "Location End", iconMarker: #imageLiteral(resourceName: "marker"), latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        }
        
        
        self.googleMaps.camera = camera
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}

public extension UISearchBar {
    
    public func setTextColor(color: UIColor) {
        let svs = subviews.flatMap { $0.subviews }
        guard let tf = (svs.filter { $0 is UITextField }).first as? UITextField else { return }
        tf.textColor = color
    }
    
}

extension GetDirectionsVC{
    func settingTapGesturseOnNewImage(){
        let tap = ratingGesture(target: self, action: #selector(GetDirectionsVC.handleTap(_:)))
        walkingImage.addGestureRecognizer(tap)
        tap.id = 0;
        let tap1 = ratingGesture(target: self, action: #selector(GetDirectionsVC.handleTap(_:)))
        byCycleImage.addGestureRecognizer(tap1)
        tap1.id = 1
        let tap2 = ratingGesture(target: self, action: #selector(GetDirectionsVC.handleTap(_:)))
        drivingImage.addGestureRecognizer(tap2)
        tap2.id = 2
        
      //  distanceAndDurationView.carveView()
    }
    @objc func handleTap(_ sender: ratingGesture) {
        
        let id = sender.id
        if id == 0 {
           googleMaps.clear()
           mode = "walking"
            walkingImage.circleImage(color: UIColor.yellow);
            drivingImage.circleImage()
            byCycleImage.circleImage()
            
           
        }
        else if id == 1 {
           
            mode = "bicycling"
            walkingImage.circleImage();
            drivingImage.circleImage()
            byCycleImage.circleImage(color: UIColor.yellow)
           

        }
        else
        {
            mode = "driving"
            walkingImage.circleImage();
            drivingImage.circleImage(color: UIColor.yellow)
            byCycleImage.circleImage()
           
        }
        googleMaps.clear()
        makeMarkerVisible()
        drawPath(startLocation: locationStart, endLocation: locationEnd)
        
    }
    func makeMarkerVisible(){
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(locationEnd.coordinate.latitude, locationEnd.coordinate.longitude)
        // marker.title = titleMarker
        marker.title = "Distance"
        marker.icon = UIImage(named: "marker")
        marker.snippet = self.distance
        marker.map = googleMaps
        print("Coord:\(marker.position)")
    }
}

