//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit
import MapKit
import MBProgressHUD

class BusinessesViewController: UIViewController {
    // Navigation bar's buttons
    var leftBarButton: UIBarButtonItem!
    var rightBarButton: UIBarButtonItem!
    
    // UIs
    @IBOutlet weak var emptyTableLabel: UILabel!
    @IBOutlet weak var restaurantMapView: MKMapView!
    @IBOutlet weak var restaurantTableView: UITableView!
    @IBOutlet weak var overlayView: UIView!
    var searchBar:UISearchBar!
    
    // Businesses
    var businesses: [Business]! = []
    var businessPins:[MKBusiness]! = []
    var currentPref = FiltersPreferences()
    var searchTerm:String? = nil
    var isSearchBarVisible = false
    var isMoreDataLoading = false
    var isAnimatingSwitchMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createSearchBarNavigationItem()
        self.createLeftBarButton()
        self.createRightBarButton()
        
        self.showLeftBarButton(true)
        self.showRightBarButton(true)
        self.showSearchBarOnNavigationBar(true)
        
        let tapOverlayView = UITapGestureRecognizer(target: self, action: "overlayViewDidTapped:")
        self.overlayView.addGestureRecognizer(tapOverlayView)
        
        self.configMapView()
        
        self.restaurantTableView.rowHeight = UITableViewAutomaticDimension
        self.restaurantTableView.estimatedRowHeight = 160
        
        self.loadRestaurantsData()
    }

    override func viewWillDisappear(animated: Bool) {
        self.searchBar.resignFirstResponder()
    }
    
    func configMapView() {
        self.restaurantMapView.delegate = self
        self.restaurantMapView.centerMapOnLocation(CLLocationCoordinate2D(latitude: AppConfig.latitude, longitude: AppConfig.longitude))
        
        let button = UIButton(type: .Custom)
        button.backgroundColor = UIColor.whiteColor()
        button.layer.cornerRadius = 8
        button.addTarget(self, action: "buttonCurrentLocationDidClick:", forControlEvents: .TouchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "current-location")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        button.tintColor = UIColor.appPrimaryColor()
        
        button.imageView?.contentMode = .ScaleAspectFit
        
        let views = ["button":button]
        self.restaurantMapView.addSubview(button)
        self.restaurantMapView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[button(48)]-(8)-|", options: [], metrics: nil, views: views))
        self.restaurantMapView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(8)-[button(48)]", options: [], metrics: nil, views: views))
    }
    
    func buttonCurrentLocationDidClick(sender:MKUserTrackingBarButtonItem) {
         self.restaurantMapView.centerMapOnLocation(CLLocationCoordinate2D(latitude: AppConfig.latitude, longitude: AppConfig.longitude))
    }
    
// MARK: - Navigation bar items
    private func createSearchBarNavigationItem() {
        self.searchBar = UISearchBar()
        self.searchBar.tintColor = UIColor.appPrimaryColor()
        self.searchBar.enablesReturnKeyAutomatically = false
        self.searchBar.delegate = self
        searchBar.sizeToFit()
    }
    
    private func showSearchBarOnNavigationBar(show:Bool) {
        if (show) {
            self.searchBar.removeFromSuperview()
            self.navigationItem.titleView = self.searchBar
        } else {
            self.navigationItem.titleView = nil
        }
        self.isSearchBarVisible = show
    }
    
    private func createLeftBarButton() {
        
        /*let button = UIButton(type: .Custom)
        button.frame = CGRectMake(0, 0, 50, 30)
        button.layer.masksToBounds = false
        button.layer.cornerRadius = 10
        button.layer.shadowOffset = CGSizeMake(1.5, 1.5)
        button.layer.shadowRadius = 0.5
        button.layer.shadowOpacity = 1.0
        button.layer.shadowColor = UIColor.blackColor().CGColor
        button.backgroundColor = UIColor.redColor()
        button.setTitle("ABC", forState: .Normal)
        self.leftBarButton = UIBarButtonItem(customView: button)
        */

        self.leftBarButton = UIBarButtonItem(title: "", style: .Plain, target: self, action: "leftBarButtonClicked:")
        self.leftBarButton.image = UIImage(named: "filter")
    }
    
    private func createRightBarButton() {
        self.rightBarButton = UIBarButtonItem(title: "", style: .Plain, target: self, action: "rightBarButtonClicked:")
        self.rightBarButton.image = UIImage(named: "map")
    }
    
    private func showLeftBarButton(show:Bool) {
        if show {
            self.navigationItem.leftBarButtonItem = self.leftBarButton
        } else {
            self.navigationItem.leftBarButtonItem = nil
        }
    }
    
    private func switchBarButtonImage() {
        // Dont no why i can't set bar button image easy way.
        var icon = UIImage(named: "map")?.imageWithRenderingMode(.AlwaysTemplate)
        if self.restaurantMapView.hidden {
            icon = UIImage(named: "list")?.imageWithRenderingMode(.AlwaysTemplate)
        }
        self.rightBarButton = UIBarButtonItem(title: "", style: .Plain, target: self, action: "rightBarButtonClicked:")
        self.rightBarButton.image = icon
        self.navigationItem.rightBarButtonItem = self.rightBarButton
    }
    
    private func showRightBarButton(show:Bool) {
        if show {
            self.navigationItem.rightBarButtonItem = self.rightBarButton
        } else {
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    func leftBarButtonClicked(sender: UIBarButtonItem) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let settingVC = sb.instantiateViewControllerWithIdentifier("settingVC") as! SettingViewController
        settingVC.currentPref = self.currentPref
        
        self.presentViewController(settingVC, animated: true, completion: nil)
    }
    
    func rightBarButtonClicked(sender: UIBarButtonItem) {
        if self.isAnimatingSwitchMode {
            return
        }
        self.switchBarButtonImage()
        
        let mapViewHidden = self.restaurantMapView.hidden
        // from will invisible, to will be visible
        var from:UIView = self.restaurantMapView
        var to:UIView = self.restaurantTableView
        
        if mapViewHidden {
            to = self.restaurantMapView
            from = self.restaurantTableView
        }

        
        to.alpha = 0
        from.hidden = false
        to.hidden = false
        self.isAnimatingSwitchMode = true
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            print("Get called")
            to.alpha = 1
            from.alpha = 0
            }) { (finished) -> Void in
                to.hidden = false
                from.hidden = true
                
                self.isAnimatingSwitchMode = false
                
                self.onLoadDataSuccess()
        }
    }
    
    func overlayViewDidTapped(sender:UIView) {
        self.searchBar.resignFirstResponder()
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! UITableViewCell
        let indexPath = self.restaurantTableView.indexPathForCell(cell)
        print(indexPath)
        let detailVc = segue.destinationViewController as! BusinessDetailViewController
        if indexPath != nil {
            detailVc.business = self.businesses[indexPath!.row]
        }
    }
    
    @IBAction func cancelSettingViewController(segue:UIStoryboardSegue) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func saveSearchPref(segue: UIStoryboardSegue) {
        let settingVc = segue.sourceViewController as! SettingViewController
        print("Current pref: \(self.currentPref.categoryIndexes)")
        
        self.currentPref = settingVc.currentPref
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
        self.loadRestaurantsData()
    }

    // MARK: - Load data & handle event
    func loadRestaurantsData() {
        let mbLoadingView = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        mbLoadingView.mode = MBProgressHUDMode.Indeterminate;
        
        let prefValue = self.currentPref.filterValues()
        Business.searchWithTerm(self.searchTerm, sort: prefValue.sortMode, categories: prefValue.category, deals: prefValue.deals, distance: prefValue.distanceInMile) { (businesses, error) -> Void in
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            
            if error != nil {
                self.onLoadDataFailed(error!)
            } else {
                self.businesses = businesses
                
                self.businessPins.removeAll()
                self.businessPins.appendContentsOf(self.businessMapData(businesses))
                self.restaurantMapView.removeAnnotations(self.restaurantMapView.annotations)
                
                self.onLoadDataSuccess()
            }
        }
    }
    
    func loadMoreRestaurantsData() {
        let mbLoadingView = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        mbLoadingView.mode = MBProgressHUDMode.Indeterminate;
        
        let offset = self.businesses != nil ? self.businesses.count : 0
        let prefValue = self.currentPref.filterValues()
        Business.searchWithTerm(self.searchTerm, sort: prefValue.sortMode, categories: prefValue.category, deals: prefValue.deals, distance: prefValue.distanceInMile, offset: offset) { (businesses, error) -> Void in
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            
            self.isMoreDataLoading = false
            
            if error != nil {
                self.onLoadDataFailed(error!)
            } else {
                self.businesses.appendContentsOf(businesses)
                self.businessPins.appendContentsOf(self.businessMapData(businesses))
                self.onLoadDataSuccess()
            }
        }
    }
    
    func onLoadDataSuccess() {
        if self.businesses.count == 0 {
            self.emptyTableLabel.hidden = self.restaurantTableView.hidden
        } else {
            self.emptyTableLabel.hidden = true
        }
        
        self.restaurantTableView.reloadData()
        if  self.businessPins.count > 0 {
            self.restaurantMapView.addAnnotations(self.businessPins)
            self.businessPins.removeAll()
        }
    }
    
    func onLoadDataFailed(error:NSError) {
        let alertController = UIAlertController(title: "Error", message: "Something went wrong, please try again later", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func businessMapData(business:[Business]!) -> [MKBusiness] {
        if business == nil {
            return []
        }
        var mkbusiness:[MKBusiness] = []
        for b in business {
            let locationPoint = b.locationPoint()
            if locationPoint  == nil {
                continue
            }
            let anotation = MKBusiness(title: b.name!, coordinate: locationPoint!, subtitle: b.address!)
            anotation.business = b
            mkbusiness.append(anotation)
        }
        return mkbusiness
    }
}

// MARK: - Tableview stuff
extension BusinessesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.businesses?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RestaurentCell") as! RestaurantTableCell
        cell.bindViewWithBussiness(self.businesses![indexPath.row])
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
}

// MARK: - SearchBar delegate
extension BusinessesViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.overlayView.hidden = false
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        self.overlayView.hidden = true
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.searchTerm = searchBar.text
        
        self.loadRestaurantsData()
        
        searchBar.resignFirstResponder()
    }
}

// MARK: - Scroll view delegate
extension BusinessesViewController : UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if self.isMoreDataLoading {
            return
        }
        
        let scrollViewContentHeight = self.restaurantTableView.contentSize.height
        let scrollOffsetThreshold = scrollViewContentHeight - self.restaurantTableView.bounds.size.height
        
        if(scrollView.contentOffset.y > scrollOffsetThreshold && self.restaurantTableView.dragging) {
            isMoreDataLoading = true
            
            self.loadMoreRestaurantsData()
        }
        
    }
}

extension BusinessesViewController : MKMapViewDelegate {
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? MKBusiness else {
            return nil
        }
        let identifier = "pinId"
        var view:MKPinAnnotationView
        
        if let dequeueView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView {
            view = dequeueView
        } else {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        return view
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let annotation = view.annotation as? MKBusiness {
            let business = annotation.business
            
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let detailVc = sb.instantiateViewControllerWithIdentifier("detailVC") as! BusinessDetailViewController
            detailVc.business = business
            self.navigationController?.pushViewController(detailVc, animated: true)
        }
    }
}
