//
//  SwitchableCell.swift
//  Yelp
//
//  Created by Tien on 3/18/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

class SwitchableCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var stateSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
