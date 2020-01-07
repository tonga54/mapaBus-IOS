//
//  Localizacion.swift
//  mapaBus
//
//  Created by Gaston Rodriguez Agriel on 12/15/19.
//  Copyright © 2019 Gaston Rodriguez Agriel. All rights reserved.
//

import UIKit
import CoreLocation

class Localizacion: NSObject, CLLocationManagerDelegate {
    var locationManager : CLLocationManager?
    var lat : Double?
    var lng : Double?
    
    override init(){
        super.init()
        
        self.locationManager = CLLocationManager()
        self.locationManager?.delegate = self
//        self.locationManager?.desiredAccuracy = kl
        self.locationManager?.requestAlwaysAuthorization()
        self.locationManager?.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        print("Lat:", locations[0].coordinate.latitude)
//        print("Lon:", locations[0].coordinate.longitude)
        self.lat = locations[0].coordinate.latitude
        self.lng = locations[0].coordinate.longitude
    }
    
}
