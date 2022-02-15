//
//  Array+toDictionary.swift
//  Service Station
//
//  Created by fahad on 02/10/2018.
//  Copyright © 2018 EYCON. All rights reserved.
//

import Foundation

extension Array where Element == String {
    
    func toDictionary() -> [AnyHashable:Any] {
        return self.reduce(into: [String:String]()) { $0[$1] = "nil" }
    }
    
}
