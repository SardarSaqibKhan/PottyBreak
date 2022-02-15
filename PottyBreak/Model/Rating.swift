//
//  Rating.swift
//  PottyBreak
//
//  Created by MacBook Pro on 03/04/2019.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

import Foundation
class Rating {
    //UserName,Email,ContactNumber,Gender,City,DOB
    
   
    var id: String?
    var rating: Double?
    var Total_Number_of_USer: Int?
    var Services:[String:Bool]?
    var imageUrls:[String:String]?
    
    
    init(json: [String:Any]) {
        
        id = json["id"] as? String ?? "" 
        rating = json["rating"] as? Double ?? 0.0
        Total_Number_of_USer = json["Total_Number_of_USer"] as? Int ?? 0
        Services = json["Services"] as? [String:Bool]
        if let ser = Services
        {
          print(ser)
           
        }
        imageUrls = json["imageUrls"] as? [String:String]

    }
}
