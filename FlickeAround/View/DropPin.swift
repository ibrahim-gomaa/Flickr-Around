//
//  DropPin.swift
//  FlickeAround
//
//  Created by ibrahim on 4/17/19.
//  Copyright © 2019 ibrahim. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class DropablePin: NSObject, MKAnnotation{
    
    dynamic var coordinate:CLLocationCoordinate2D
    var identifier: String
    init(coordinate:CLLocationCoordinate2D, identifier: String) {
        self.coordinate = coordinate
        self.identifier = identifier
        super.init()
    }
}
