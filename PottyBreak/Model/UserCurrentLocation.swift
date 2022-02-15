import Foundation
class UserCurrentLocation {
    
    var latitude:Double?
    var longitude:Double?
    var address:String?
    
    init() {
        self.latitude = 0.0
        self.longitude = 0.0
        self.address = ""
    }
    init(latitude:Double,longitude:Double,address:String) {
        
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
    }
}
