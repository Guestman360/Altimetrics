//
//  CurrentWeather.swift
//  Altimetrics
//
//  Created by The Guest Family on 2/5/17.
//  Copyright © 2017 AlphaApplications. All rights reserved.
//

import Foundation
import Alamofire

class CurrentWeather {

    var _cityName: String!
    var _weatherType: String!
    var _currentTemp: Double!
    var _pressure: Double!
    var _humidity: Double!
    
    //Initializing and adding extra layer of safety
    var cityName: String {
        if _cityName == nil {
            _cityName = ""
        }
        return _cityName
    }
    
    var weatherType: String {
        if _weatherType == nil {
            _weatherType = ""
        }
        return _weatherType
    }
    
    var currentTemp: Double {
        if _currentTemp == nil {
            _currentTemp = 0.0
        }
        return _currentTemp
    }
    
    var pressure: Double {
        if _pressure == nil {
            _pressure = 0.0
        }
        return _pressure
    }
    
    var humidity: Double {
        if _humidity == nil {
            _humidity = 0.0
        }
        return _humidity
    }
    
    
    func retrieveWeatherData(completed: @escaping DownloadComplete) {
        
        //Retrieving relevant weather data to display on the ViewController
        //Gets the city name, weather type, temp, pressure and humidity
        Alamofire.request(CURRENT_WEATHER_URL).responseJSON {response in
            let result = response.result
            
            if let dict = result.value as? Dictionary<String, AnyObject> {
                if let name = dict["name"] as? String {
                    self._cityName = name.capitalized
                    print(self._cityName)
                }
                
                if let weather = dict["weather"] as? [Dictionary<String, AnyObject>] {
                    if let main = weather[0]["main"] as? String {
                        self._weatherType = main.capitalized
                        print(self._weatherType)
                    }
                }
                
                if let main = dict["main"] as? Dictionary<String, AnyObject> {
                    if let currentTemperature = main["temp"] as? Double {
                        let kelvinToFahrenheitPreDivision = (currentTemperature * (9/5) - 459.67)
                        let kelvinToFahrenheit = Double(round(10 * kelvinToFahrenheitPreDivision/10))
                        //Data is initially presented in fahrenheit, must convert to celcius later if desired
                        self._currentTemp = kelvinToFahrenheit
                        print(self._currentTemp)
                    }
                }
                
                if let main2 = dict["main"] as? Dictionary<String, AnyObject> {
                    if let pressures = main2["pressure"] as? Double {
                        self._pressure = pressures
                        print(self._pressure)
                    }
                }
                
                if let main3 = dict["main"] as? Dictionary<String, AnyObject> {
                    if let humidities = main3["humidity"] as? Double {
                        self._humidity = humidities
                        print(self._humidity)
                    }
                }
                
            }
            completed()
        }
    }
    
}
























