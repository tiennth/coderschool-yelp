//
//  BusinessDetailViewController.swift
//  Yelp
//
//  Created by Tien on 3/19/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit
import MapKit

class BusinessDetailViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var ratingImageView: UIImageView!
    @IBOutlet weak var reviewCountLabel: UILabel!
    @IBOutlet weak var categoriesLabel: UILabel!
    @IBOutlet weak var openingHoursLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressButton: UIButton!
    
    var business:Business!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = business.name
        // Do any additional setup after loading the view.
        nameLabel.text = business.name
        distanceLabel.text = business.distance
        self.ratingImageView.setImageWithURL(business.ratingImageURL!)
        if let _ = business.reviewCount {
            self.reviewCountLabel.text = "\(business.reviewCount!.intValue) Reviews"
        }
        if let _ = business.distance {
            self.distanceLabel.text = "\(business.distance!)"
        } else {
            self.distanceLabel.text = "--"
        }
        self.categoriesLabel.text = business.categories
        
        if (self.business.lat != nil && self.business.lon != nil) {
            let location = CLLocationCoordinate2D(latitude: self.business.lat!, longitude: self.business.lon!)
            self.centerMapOnLocation(location)
            
            let artwork = MKBusiness(title: business.name!, coordinate: location)
            self.mapView.addAnnotation(artwork)
        }
        
        self.addressButton.setTitle(self.business.address, forState: .Normal)
        
        self.mapView.layer.cornerRadius = 8.0
    }

    override func viewDidLayoutSubviews() {
        self.scrollView.contentSize = CGSizeMake(0, self.mapView.frame.origin.y + self.mapView.frame.size.height + 20)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func buttonAddressDidClicked(sender: AnyObject) {
        if (self.business.lat != nil && self.business.lon != nil) {
            let location = CLLocationCoordinate2D(latitude: self.business.lat!, longitude: self.business.lon!)
            self.centerMapOnLocation(location)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    let regionRadius: CLLocationDistance = 1000
    func centerMapOnLocation(location: CLLocationCoordinate2D) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location,
            regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
}
