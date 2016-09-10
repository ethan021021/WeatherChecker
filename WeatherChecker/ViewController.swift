//
//  ViewController.swift
//  WeatherChecker
//
//  Created by Ethan Thomas on 9/10/16.
//  Copyright © 2016 Ethan Thomas. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class ViewController: UIViewController {
    
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var dayTimeLabel: UILabel!
    @IBOutlet weak var weatherConditionImage: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let locationManager = CLLocationManager()
    
    var currentCoordinates: CLLocationCoordinate2D?
    
    var currentCoordinateString = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        temperatureLabel.text = ""
        conditionLabel.text = ""
        dayTimeLabel.text = ""
        weatherConditionImage.image = nil
        activityIndicator.isHidden = true
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: activityIndicator)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }

    @IBAction func refreshBtnPressed(_ sender: UIBarButtonItem) {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        locationManager.startUpdatingLocation()
    }
    

    func showBasicAlert(title: String, message: String) {
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func setDisplayValues(model: WeatherModel) {
        self.temperatureLabel.text = "\(model.imperialTemperatureValue!) F"
        self.conditionLabel.text = "Current condition outside: \(model.weatherTextCondition!)"
        self.weatherConditionImage.image = model.weatherImage!
        if model.isDayTime == true {
            self.dayTimeLabel.text = "It's daytime"
        } else {
            self.dayTimeLabel.text = "It's night time"
        }
    }
    
    func getWeatherDataFromAPI(completion: @escaping (WeatherModel) -> Void) {
        Alamofire.request("http://dataservice.accuweather.com/locations/v1/cities/geoposition/search?apikey=\(Constants().apiKey)&q=\(currentCoordinateString)").responseJSON { (data) in
            let json = JSON(data: data.data!)
            Alamofire.request("http://dataservice.accuweather.com/currentconditions/v1/\(json["Key"].stringValue)?apikey=\(Constants().apiKey)").responseJSON(completionHandler: { (data) in
                let js = JSON(data: data.data!)
                var weatherInt = ""
                if js[0]["WeatherIcon"].intValue < 10 {
                    weatherInt = "0\(js[0]["WeatherIcon"].intValue)"
                } else {
                    weatherInt = "\(js[0]["WeatherIcon"].intValue)"
                }
                let model = WeatherModel(coords: self.currentCoordinates!, imperialTemperatureValue: js[0]["Temperature"]["Imperial"]["Value"].stringValue, weatherTextCondition: js[0]["WeatherText"].stringValue, isDayTime: js[0]["IsDayTime"].boolValue, weatherLink: URL.init(string: js[0]["Link"].stringValue)!, weatherImageString: weatherInt)
                completion(model)
            })
        }
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coords = manager.location?.coordinate {
            currentCoordinates = coords
            currentCoordinateString = "\(coords.latitude)%2C\(coords.longitude)"
            locationManager.stopUpdatingLocation()
            getWeatherDataFromAPI(completion: { (model) in
                self.setDisplayValues(model: model)
            })
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .denied:
            temperatureLabel.text = ""
            conditionLabel.text = ""
            dayTimeLabel.text = ""
            weatherConditionImage.image = nil
            activityIndicator.isHidden = true
            showBasicAlert(title: "Error!", message: "Please enable this apps location services in settings then press the refresh button!")
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        showBasicAlert(title: "Error!", message: "Location services disabled")
    }
}

