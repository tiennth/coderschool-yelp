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
    let subtitle:String?
    let coordinate:CLLocationCoordinate2D
    var business:Business?
    
    init(title:String, coordinate:CLLocationCoordinate2D, subtitle:String) {
        
        self.title = title
        self.coordinate = coordinate
        self.subtitle = subtitle
        
        super.init()
    }
    
    
}
