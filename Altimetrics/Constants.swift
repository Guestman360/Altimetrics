//
//  File.swift
//  Altimetrics
//
//  Created by The Guest Family on 2/4/17.
//  Copyright © 2017 AlphaApplications. All rights reserved.
//

import Foundation


typealias DownloadComplete = () -> ()

//Here is the URL that connects to the openweathermap service to pull the data from

let CURRENT_WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather?lat=\(Location.sharedInstance.latitude!)&lon=\(Location.sharedInstance.longitude!)&appid=e457320ebf8da0eacf77280f7a5a2d75"
