//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit
import MBProgressHUD

class BusinessesViewController: UIViewController {
    // Navigation bar's buttons
    var leftBarButton: UIBarButtonItem!
    var rightBarButton: UIBarButtonItem!
    
    // UIs
    @IBOutlet weak var restaurantTableView: UITableView!
    var searchBar:UISearchBar!
    
    // Businesses
    var businesses: [Business]!
    var filteredBusinesses: [Business]!
    var currentPref = FiltersPreferences()
    var searchTerm:String? = nil
    var isSearchBarVisible = false
    var isMoreDataLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createSearchBarNavigationItem()
        self.createLeftBarButton()
        self.createRightBarButton()
        
        self.showLeftBarButton(true)
        self.showRightBarButton(true)
        self.showSearchBarOnNavigationBar(true)
        
        self.restaurantTableView.rowHeight = UITableViewAutomaticDimension
        self.restaurantTableView.estimatedRowHeight = 160
        
        self.loadRestaurantsData()
        
    }

    override func viewWillDisappear(animated: Bool) {
        self.searchBar.resignFirstResponder()
    }
    
    override func viewDidAppear(animated: Bool) {
        
    }
    
    private func createSearchBarNavigationItem() {
        self.searchBar = UISearchBar()
        self.searchBar.tintColor = UIColor.redColor()
//        self.searchBar.showsCancelButton = true
        self.searchBar.delegate = self
        searchBar.sizeToFit()
    }
    
    private func showSearchBarOnNavigationBar(show:Bool) {
        if (show) {
            self.searchBar.removeFromSuperview()
            self.navigationItem.titleView = self.searchBar
//            self.searchBar.becomeFirstResponder()
        } else {
            self.navigationItem.titleView = nil
        }
        self.isSearchBarVisible = show
    }
    
    private func createLeftBarButton() {
        self.leftBarButton = UIBarButtonItem(title: "Filter", style: .Plain, target: self, action: "leftBarButtonClicked:")
    }
    
    private func createRightBarButton() {
        self.rightBarButton = UIBarButtonItem(title: "Map", style: .Plain, target: self, action: "rightBarButtonClicked:")
        self.rightBarButton.tintColor = UIColor.redColor()
    }
    
    private func showLeftBarButton(show:Bool) {
        if show {
            self.navigationItem.leftBarButtonItem = self.leftBarButton
        } else {
            self.navigationItem.leftBarButtonItem = nil
        }
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
        
    }
    
    // MARK: - Navigation
    
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

    func loadRestaurantsData() {
        let mbLoadingView = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        mbLoadingView.mode = MBProgressHUDMode.Indeterminate;
        
        let prefValue = self.currentPref.filterValues()
        Business.searchWithTerm(self.searchTerm, sort: prefValue.sortMode, categories: prefValue.category, deals: prefValue.deals, distance: prefValue.distanceInMile) { (businesses, error) -> Void in
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            
            self.businesses = businesses
            self.filteredBusinesses = businesses
            self.restaurantTableView.reloadData()
        }
    }
    
    func loadMoreRestaurantsData() {
        let mbLoadingView = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        mbLoadingView.mode = MBProgressHUDMode.Indeterminate;
        
        let prefValue = self.currentPref.filterValues()
        Business.searchWithTerm(self.searchTerm, sort: prefValue.sortMode, categories: prefValue.category, deals: prefValue.deals, distance: prefValue.distanceInMile, offset: self.businesses.count) { (businesses, error) -> Void in
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            
            self.isMoreDataLoading = false
            self.businesses.appendContentsOf(businesses)
            self.filteredBusinesses = self.businesses
            self.restaurantTableView.reloadData()
        }
    }
}

extension BusinessesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredBusinesses?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RestaurentCell") as! RestaurantTableCell
        cell.bindViewWithBussiness(self.filteredBusinesses![indexPath.row])
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

extension BusinessesViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.searchTerm = searchBar.text
        
        self.loadRestaurantsData()
        
        searchBar.resignFirstResponder()
    }
}

extension BusinessesViewController : UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.searchBar.resignFirstResponder()
        
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
