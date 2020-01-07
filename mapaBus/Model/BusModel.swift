//
//  BusModel.swift
//  mapaBus
//
//  Created by Gaston Rodriguez Agriel on 12/16/19.
//  Copyright © 2019 Gaston Rodriguez Agriel. All rights reserved.
//

import Foundation

class BusModel{
    
    var lat : Double = 0
    var lng : Double = 0
    var subLinea : String = ""
    
    init(lat : Double, lng : Double, subLinea : String){
        self.lat = lat
        self.lng = lng
        self.subLinea = subLinea
    }
}
