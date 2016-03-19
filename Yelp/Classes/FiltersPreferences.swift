//
//  FiltersPreferences.swift
//  Yelp
//
//  Created by Tien on 3/18/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

struct FiltersPreferences {
    var deals:Bool = false
    var distanceIndex:Int = 0
    var sortOptionIndex:Int = 0
    var categoryIndexes:[Int] = []
    
    func filterValues() -> (sortMode:YelpSortMode, distanceInMile:Float?, category:[String]?, deals:Bool) {
        var sortMode:YelpSortMode = YelpSortMode.BestMatched
        if (sortOptionIndex == 1) {
            sortMode = YelpSortMode.Distance
        } else if sortOptionIndex == 2 {
            sortMode = YelpSortMode.HighestRated
        }
        
        let distance = YelpFilterDataSource.distanceValues[self.distanceIndex]
        
        var categories:[String] = []
        for index in self.categoryIndexes {
            categories.append(YelpFilterDataSource.categories[index]["code"]!)
        }
        
        return (sortMode, distance > 0 ? distance : nil, categories.count > 0 ? categories : nil, deals)
    }
}
