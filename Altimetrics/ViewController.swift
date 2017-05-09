//
//  ViewController.swift
//  Altimetrics
//
//  Created by The Guest Family on 2/4/17.
//  Copyright © 2017 AlphaApplications. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    var currentWeather: CurrentWeather!
    var currentLocation: CLLocation!
    var isMenuShowing: Bool = false
    var colorArray = [UIColor(red: 78/255, green: 128/255, blue: 169/255, alpha: 1), //default blue
                      UIColor(red: 220/255, green: 20/255, blue: 60/255, alpha: 1), //crimson
                      UIColor(red: 240/255, green: 128/255, blue: 128/255, alpha: 1), //light coral
                      UIColor(red: 0/255, green: 100/255, blue: 0/255, alpha: 1), //dark green
                      UIColor(red: 30/255, green: 144/255, blue: 255/255, alpha: 1), //dodger blue
                      UIColor(red: 32/255, green: 178/255, blue: 170/255, alpha: 1), //light sea green
                      UIColor(red: 218/255, green: 112/255, blue: 214/255, alpha: 1), //orchid
                      UIColor.orange, UIColor.brown, UIColor.gray, UIColor.black] //standard colors
    var counter: Int = 0
    let defaults = UserDefaults.standard
    let currentDateTime = Date()
    //let altimeter = CMAltimeter()
    
    @IBOutlet weak var AltitudeLbl: UILabel!
    @IBOutlet weak var SpeedLbl: UILabel!
    @IBOutlet weak var LatLbl: UILabel!
    @IBOutlet weak var LongLbl: UILabel!
    @IBOutlet weak var CompassIcon: UIImageView!
    @IBOutlet weak var degreesLbl: UILabel!
    @IBOutlet weak var trueOrMagneticLbl: UILabel!
    
    //Outlets for weather data
    @IBOutlet weak var weatherImg: UIImageView!
    @IBOutlet weak var cityName: UILabel!
    @IBOutlet weak var weatherType: UILabel!
    @IBOutlet weak var tempLbl: UILabel!
    @IBOutlet weak var pressureLbl: UILabel!
    @IBOutlet weak var humidityLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    
    //Outlets for the slide up menu
    //@IBOutlet weak var topConstraint: NSLayoutConstraint!
    //@IBOutlet weak var topConstraintToggle: NSLayoutConstraint!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    

    //User defaults
    let speedToggle = "speedToggle"
    let tempToggle = "tempToggle"
    let headingToggle = "headingToggle"
    let coordinateToggle = "coordinateToggle"
    let unitToggle = "unitToggle"
    let colorToggle = "colorToggle"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var prefersStatusBarHidden: Bool {
            return true
        }
        //Add gesture recognizers to handle switching the background color of the view
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.rightChangeBackgroundColor))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.leftChangeBackgroundColor))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        //save the color
        if let colorIndex = defaults.value(forKey: colorToggle) as? Int {
            self.view.backgroundColor = colorArray[colorIndex]
        }
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = kCLDistanceFilterNone
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        //Updates for the compass
        self.locationManager.startUpdatingHeading()
        self.locationManager.headingFilter = 1
        
        currentWeather = CurrentWeather()
        
        updateWeatherUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationAuthorizationStatus()
        
        let formatter = DateFormatter()
        //formatter.timeStyle = .short
        formatter.dateStyle = .long
        dateLbl.text = formatter.string(from: currentDateTime)
    }
    
    //Functions for background color
    func rightChangeBackgroundColor() {
        //print("swipe right")
        counter += 1
        //print(counter)
        if counter >= colorArray.count {
            counter = 0
        }
        UIView.animate(withDuration: 0.5) {
            self.view.backgroundColor = self.colorArray[self.counter]
        }
        defaults.set(counter, forKey: colorToggle)
    }
    
    func leftChangeBackgroundColor() {
        //print("swipe Left")
        self.counter -= 1
        //print(counter)
        if counter < 0 {
            self.counter = self.colorArray.count - 1
        }
        UIView.animate(withDuration: 0.5) {
            self.view.backgroundColor = self.colorArray[self.counter]
        }
        defaults.set(counter, forKey: colorToggle)
    }
    
    func locationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            currentLocation = locationManager.location
            Location.sharedInstance.latitude = currentLocation.coordinate.latitude
            Location.sharedInstance.longitude = currentLocation.coordinate.longitude
            AltitudeLbl.text = String(format: "%.0f ft", currentLocation.altitude)
            currentWeather.retrieveWeatherData {
                self.updateWeatherUI()
            }
        } else {
            locationManager.requestWhenInUseAuthorization()
            //locationAuthorizationStatus()
        }
    }
    
    //Fills the outlets with their respective data and updates the main UI
    func updateWeatherUI() {
        cityName.text = currentWeather.cityName
        weatherImg.image = UIImage(named: currentWeather.weatherType)//gets the image based on the weather data name in JSON, name pics right
        weatherType.text = currentWeather.weatherType
        tempLbl.text = "\(currentWeather.currentTemp) °F"
        pressureLbl.text = "Pressure: \(currentWeather.pressure)" //kPcl - * 0.295299802
        humidityLbl.text = "Humidity: \(currentWeather.humidity) %"
    }
    
    //CLLocation classes
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        
        if newHeading.headingAccuracy > 0 {
        
            let magneticHead = newHeading.magneticHeading
            //print(magneticHead)
            
            degreesLbl.text = String(format: "%.0f", magneticHead)
            
            let heading: Double = 1.0 * M_PI * magneticHead/180
            self.CompassIcon.transform = CGAffineTransform(rotationAngle: CGFloat(heading))
        }
        
        //Heading toggle for true and magnetic
        if defaults.integer(forKey: headingToggle) != 1 {
            let magneticHead = newHeading.magneticHeading
            degreesLbl.text = String(format: "%.0f", magneticHead) + " °"
            trueOrMagneticLbl.text = "Magnetic"
            //print(magneticHead)
        } else {
            let trueHead = newHeading.trueHeading
            degreesLbl.text = String(format: "%.0f", trueHead) + " °"
            trueOrMagneticLbl.text = "True"
            //print(trueHead)
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location: CLLocation = locations.last!
        let alt = location.altitude
        
        //Default speed settings unless changed
        SpeedLbl.text = String(format: "%.0f mph", location.speed * 2.23694)
        
        if defaults.integer(forKey: speedToggle) != 1 {
            SpeedLbl.text = String(format: "%.0f mph", location.speed * 2.23694)
        } else {
            SpeedLbl.text = String(format: "%.0f kph", location.speed * 3.60)
        }
        
        //Handles tmperature conversion
        if defaults.integer(forKey: tempToggle) != 1 {
            tempLbl.text = "\(currentWeather.currentTemp) °F"
        } else {
            let celciusConversion = Double(currentWeather.currentTemp - 32)*5/9
            tempLbl.text = "\(String(format: "%.1f", celciusConversion)) °C"
        }
        
        //Switch from meters to feet here
        if location.verticalAccuracy > 0 && location.horizontalAccuracy > 0 {
        
            AltitudeLbl.text = String(format: "%.0f ft", alt * 3.28084)
        
            if defaults.integer(forKey: unitToggle) != 1 {
                AltitudeLbl.text = String(format: "%.0f ft", alt * 3.28084)
                //print(alt)
            } else {
                AltitudeLbl.text = String(format: "%.0f m", alt)
                //print(alt)
            }
        
        }
        //Provide the switch from DMS to Decimal check here
        LatLbl.text = String(format: "%.6f", location.coordinate.latitude)
        LongLbl.text = String(format: "%.6f", location.coordinate.longitude)
        
        if defaults.integer(forKey: coordinateToggle) != 1 {
            LatLbl.text = String(format: "%.6f", location.coordinate.latitude)
            LongLbl.text = String(format: "%.6f", location.coordinate.longitude)
        } else {
            LatLbl.text = latToDMS(latitude: location.coordinate.latitude)
            LongLbl.text = longToDMS(longitude: location.coordinate.longitude)
        }
    }
    
    //Both of these functions allow the lat and long to be converted into DMS for the two labels on screen
    func latToDMS(latitude: Double) -> String {
        var latSeconds = Int(latitude * 3600)
        let latDegrees = latSeconds / 3600
        latSeconds = abs(latSeconds % 3600)
        let latMinutes = latSeconds / 60
        latSeconds %= 60
        return String(format:"%d°%d'%d\"%@",
                      abs(latDegrees),
                      latMinutes,
                      latSeconds,
                      {return latDegrees >= 0 ? "N" : "S"}())
    }
    
    func longToDMS(longitude: Double) -> String {
        var longSeconds = Int(longitude * 3600)
        let longDegrees = longSeconds / 3600
        longSeconds = abs(longSeconds % 3600)
        let longMinutes = longSeconds / 60
        longSeconds %= 60
        return String(format:"%d°%d'%d\"%@",
                      abs(longDegrees),
                      longMinutes,
                      longSeconds,
                      {return longDegrees >= 0 ? "E" : "W"}() )
    }
    
    @IBAction func revealMenu(_ sender: AnyObject) {
            if(isMenuShowing){
                
                bottomConstraint.constant = -300
                    //750
                UIView.animate(withDuration: 0.3, animations: {
                    self.view.layoutIfNeeded()
                })
                
            } else {
                
                bottomConstraint.constant = 300
                    //437
                UIView.animate(withDuration: 0.3, animations: {
                    self.view.layoutIfNeeded()
                })
            }
            isMenuShowing = !isMenuShowing
        }
    
    
    @IBAction func downSwipe(_ sender: UISwipeGestureRecognizer) {
        
        if(isMenuShowing) {
            sender.direction = UISwipeGestureRecognizerDirection.down
            
            bottomConstraint.constant = -300
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            })
        } else {
            print("something went wrong..")
        }
        isMenuShowing = !isMenuShowing
    }
    
    //Setting button actions and defaults
    @IBAction func trueHeadingToggle(_ sender: AnyObject) {
        defaults.set(1, forKey: headingToggle)
    }
    
    @IBAction func magneticHeadingToggle(_ sender: AnyObject) {
        defaults.set(0, forKey: headingToggle)
    }
    
    @IBAction func dmsToggle(_ sender: AnyObject) {
        defaults.set(1, forKey: coordinateToggle)
    }
    
    @IBAction func decimalToggle(_ sender: AnyObject) {
        defaults.set(0, forKey: coordinateToggle)
    }
    
    @IBAction func meterToggle(_ sender: AnyObject) {
        defaults.set(1, forKey: unitToggle)
    }
    
    @IBAction func feetToggle(_ sender: AnyObject) {
        defaults.set(0, forKey: unitToggle)
    }
    
    @IBAction func kmhToggle(_ sender: AnyObject) {
        defaults.set(1, forKey: speedToggle)
    }
    
    @IBAction func mphToggle(_ sender: AnyObject) {
        defaults.set(0, forKey: speedToggle)
    }
    
    @IBAction func celciusToggle(_ sender: AnyObject) {
        defaults.set(1, forKey: tempToggle)
    }
    
    @IBAction func fahrenheitToggle(_ sender: AnyObject) {
        defaults.set(0, forKey: tempToggle)
    }
    
}

//Perhaps incorporate another time?
//extension UIColor {
//    convenience init(hex: String) {
//        let scanner = Scanner(string: hex)
//        scanner.scanLocation = 0
//        
//        var rgbValue: UInt64 = 0
//        
//        scanner.scanHexInt64(&rgbValue)
//        
//        let r = CGFloat((rgbValue & 0xff0000) >> 16) / 255.0
//        let g = CGFloat((rgbValue & 0xff00) >> 8) / 255.0
//        let b = CGFloat(rgbValue & 0xff) / 255.0
//        let a = CGFloat(1.0)
//        
//        self.init(
//            red: CGFloat(r) / 0xff,
//            green: CGFloat(g) / 0xff,
//            blue: CGFloat(b) / 0xff,
//            alpha: CGFloat(a)
//        )
//    }
//}



