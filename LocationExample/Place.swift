//
//  Place.swift
//  LocationExample
//
//  Created by Axel Rivera on 9/25/15.
//  Copyright © 2015 Axel Rivera. All rights reserved.
//

import Foundation
import CoreLocation

import SwiftyJSON

typealias PlaceArray = [Place]

class Place {
    
    var placeId: String!
    
    var title = String()
    var city = String()
    
    var coordinate: CLLocationCoordinate2D?
    
    init() {
        // Main Initializer
        // Don't call super because it's a root class
        
        placeId = NSUUID().UUIDString
    }
    
    init(json: JSON) {
        placeId = json["place_id"].string ?? NSUUID().UUIDString
        
        title = json["title"].stringValue
        city = json["city"].stringValue
        
        if let latitude = json["latitude"].double, longitude = json["longitude"].double {
            coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
    }
    
    var annotation: MapAnnotation? {
        guard let coordinate = self.coordinate else {
            return nil
        }
        
        return MapAnnotation(title: title, coordinate: coordinate)
    }
    
    var dictionary: [String: AnyObject] {
        var aDictionary = [String: AnyObject]()
        
        aDictionary["title"] = title
        aDictionary["city"] = city
        
        if let latitude = coordinate?.latitude, longitude = coordinate?.longitude {
            aDictionary["latitude"] = latitude
            aDictionary["longitude"] = longitude
        }
        
        return aDictionary
    }
    
}

extension Place: Hashable {
    
    var hashValue: Int {
        return placeId.hashValue
    }
    
}

extension Place: Equatable {
    // The Equality Method is implemented at global scope
}

func ==(lhs: Place, rhs: Place) -> Bool {
    return lhs.placeId == rhs.placeId
}
