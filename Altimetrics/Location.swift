//
//  Location.swift
//  Altimetrics
//
//  Created by The Guest Family on 2/5/17.
//  Copyright © 2017 AlphaApplications. All rights reserved.
//

import Foundation
import CoreLocation


class Location {
    //Implement a Location singleton
    static var sharedInstance = Location()
    private init() {}
    
    var latitude: Double!
    var longitude: Double!
}
