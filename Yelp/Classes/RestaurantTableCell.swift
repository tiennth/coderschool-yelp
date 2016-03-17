//
//  YelpTableCell.swift
//  Yelp
//
//  Created by Tien on 3/15/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

class RestaurantTableCell: UITableViewCell {

    @IBOutlet weak var overviewImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var reviewCountLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension RestaurantTableCell {
    func bindViewWithBussiness(business:Business) {
        // Setting image
        if let _ = business.imageURL {
            self.overviewImageView.setImageWithURL(business.imageURL!)
        }
        
        self.nameLabel.text = business.name
        self.addressLabel.text = business.address
        if let _ = business.reviewCount {
            self.reviewCountLabel.text = "\(business.reviewCount!.intValue) Reviews"
        }
        if let _ = business.distance {
            self.distanceLabel.text = "\(business.distance!)"
        } else {
            self.distanceLabel.text = "--"
        }
        self.categoryLabel.text = business.categories
    }
}
