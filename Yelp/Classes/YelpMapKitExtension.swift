//
//  YelpMapKitExtension.swift
//  Yelp
//
//  Created by Tien on 3/19/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit
import MapKit

extension MKMapView {
    func centerMapOnLocation(location: CLLocationCoordinate2D) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location,
            1000 * 2.0, 1000 * 2.0)
        self.setRegion(coordinateRegion, animated: true)
    }
}
