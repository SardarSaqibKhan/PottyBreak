//
//  User.swift
//  Chat App
//
//  Created by fahad on 26/11/2018.
//  Copyright © 2018 Fahad. All rights reserved.
//

import Foundation
import CoreLocation

class Toilet {
    //UserName,Email,ContactNumber,Gender,City,DOB
    
    var formatted_address: String?
    var location:CLLocationCoordinate2D?
    var icon: String?
    var id: String?
    var name: String?
    var ratings: Double?
    var user_ratings_total: Int?
    var isNotToilet = false;
    
    init(json: [String:Any],isNotToilet:Bool) {
        self.isNotToilet = isNotToilet
        id = json["id"] as? String ?? "" // Confirm from ServerEnd Dev
        
        name = json["name"] as? String ?? ""
        ratings = json["rating"] as? Double ?? 0.0
        user_ratings_total = json["user_ratings_total"] as? Int ?? 0
        icon = json["icon"] as? String ?? ""
        formatted_address = json["formatted_address"] as? String ?? ""
        var geometry = json["geometry"] as? [String:Any]
        if let geom = geometry
        {
           if let location = geom["location"] as? [String:Any]
           {
            self.location = CLLocationCoordinate2D(latitude: location["lat"] as! Double, longitude: location["lng"] as! Double)
            }
        }
        
        
    }
}


