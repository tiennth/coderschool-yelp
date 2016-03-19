//
//  MKBusiness.swift
//  Yelp
//
//  Created by Tien on 3/19/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit
import MapKit

class MKBusiness: NSObject, MKAnnotation {
    let title:String?
    let coordinate:CLLocationCoordinate2D
    
    init(title:String, coordinate:CLLocationCoordinate2D) {
        
        self.title = title
        self.coordinate = coordinate
        
        super.init()
    }
    
    
}
