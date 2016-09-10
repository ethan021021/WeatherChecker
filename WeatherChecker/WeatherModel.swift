//
//  WeatherModel.swift
//  WeatherChecker
//
//  Created by Ethan Thomas on 9/10/16.
//  Copyright © 2016 Ethan Thomas. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import CoreLocation
import SwiftyJSON

class WeatherModel {
    var coords: CLLocationCoordinate2D?
    var imperialTemperatureValue: String?
    var weatherTextCondition: String?
    var isDayTime: Bool?
    var weatherLink: URL?
    var weatherImage: UIImage?
    
    init(coords: CLLocationCoordinate2D, imperialTemperatureValue: String, weatherTextCondition: String, isDayTime: Bool, weatherLink: URL, weatherImageString: String) {
        self.coords = coords
        self.isDayTime = isDayTime
        self.weatherLink = weatherLink
        self.weatherTextCondition = weatherTextCondition
        self.imperialTemperatureValue = imperialTemperatureValue
        self.weatherImage = downloadImageFrom(url: URL.init(string: "https://apidev.accuweather.com/developers/Media/Default/WeatherIcons/\(weatherImageString)-s.png")!)
    }
    
    func downloadImageFrom(url: URL) -> UIImage? {
        if let imageData = try? Data.init(contentsOf: url) {
            return UIImage.init(data: imageData)
        } else {
            return nil
        }
    }
}
