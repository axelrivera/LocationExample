//
//  MapAnnotation.swift
//  LocationExample
//
//  Created by Axel Rivera on 9/26/15.
//  Copyright © 2015 Axel Rivera. All rights reserved.
//

import Foundation
import MapKit

class MapAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    
    init(title: String?, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.coordinate = coordinate
        super.init()
    }
    
}
