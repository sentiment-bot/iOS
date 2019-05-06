//
//  LocationHelper.swift
//  Sentiment Bot
//
//  Created by Moin Uddin on 1/10/19.
//  Copyright © 2019 Scott Bennett. All rights reserved.
//

import Foundation
import CoreLocation

class LocationHelper: NSObject, CLLocationManagerDelegate {    

    
    let locationManager = CLLocationManager()
    
    
    func requestLocationAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func getCurrentLocation() -> CLLocation? {
        return locationManager.location
    }

    
    
    func saveLocation() {
        let longitude = locationManager.location?.coordinate.longitude
        let latitude = locationManager.location?.coordinate.latitude
        UserDefaults.standard.set(longitude, forKey: UserDefaultsKeys.longitude.rawValue)
        UserDefaults.standard.set(latitude, forKey: UserDefaultsKeys.latitude.rawValue)
    }
    
    
}
