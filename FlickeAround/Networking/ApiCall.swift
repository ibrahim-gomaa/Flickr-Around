//
//  ApiCall.swift
//  FlickeAround
//
//  Created by ibrahim on 4/21/19.
//  Copyright © 2019 ibrahim. All rights reserved.
//

import Foundation

    let apiKey = "a2474c3368a68a3c7c429ef0e3f4372f"
    
func flickrUrl(forApiKey key: String, withAnnotation annotation: DropablePin, andNumberOfPhotos number: Int) -> String {
    return "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.longitude)&radius=1&radius_units=mi&per_page=\(number)&format=json&nojsoncallback=1"
}

    
