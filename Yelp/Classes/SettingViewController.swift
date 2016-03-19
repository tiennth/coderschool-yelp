//
//  SettingViewController.swift
//  Yelp
//
//  Created by Tien on 3/17/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {
    @IBOutlet weak var filterTableView: UITableView!
    
    let sectionTitles = ["", "Distance", "Sort By", "Category"]
    var distanceExpanded = false
    var sortExpanded = false
    var categoryExpanded = false
    
    var currentPref:FiltersPreferences!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
}

extension SettingViewController:UITableViewDataSource {
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sectionTitles[section]
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRow = 0
        switch section {
        case 0:
            numberOfRow = 1
        case 1:
            if distanceExpanded {
                numberOfRow = YelpFilterDataSource.distanceValues.count
            } else {
                numberOfRow = 1
            }
        case 2:
            if sortExpanded {
                numberOfRow = YelpFilterDataSource.sortOptionValues.count
            } else {
                numberOfRow = 1
            }
        case 3:
            if categoryExpanded {
                numberOfRow = YelpFilterDataSource.categories.count + 1 // Plus 1 for "collapse" row
            } else {
                numberOfRow = 5 // Just show 4 categories, 1 left for "Show All" row
            }
        default:
            break
        }
        return numberOfRow
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row
        
        var cell : UITableViewCell? = nil
        if section == 0 {
            let switchCell = tableView.dequeueReusableCellWithIdentifier("SwitchableCell") as! SwitchableCell
            switchCell.titleLabel.text = "Offering a Deal"
            switchCell.delegate = self
            switchCell.stateSwitch.on = self.currentPref.deals
            
            cell = switchCell
        } else if section == 1 {
            let imageCell = tableView.dequeueReusableCellWithIdentifier("ImageCell") as! ImageCell
            if distanceExpanded {
                imageCell.titleLabel.text = self.distanceTitleFromIndex(row)
            } else {
                imageCell.titleLabel.text = self.distanceTitleFromIndex(self.currentPref.distanceIndex)
            }
            
            cell = imageCell
        } else if section == 2 {
            let imageCell = tableView.dequeueReusableCellWithIdentifier("ImageCell") as! ImageCell
            if sortExpanded {
                imageCell.titleLabel.text = self.sortOptionTitleFromIndex(row)
            } else {
                imageCell.titleLabel.text = self.sortOptionTitleFromIndex(self.currentPref.sortOptionIndex)
            }
            
            cell = imageCell
        } else if section == 3 {
            if row == tableView.numberOfRowsInSection(section) - 1 {
                // For the last row
                let textCell = tableView.dequeueReusableCellWithIdentifier("TextCell") as! TextCell
                textCell.titleLabel.text = categoryExpanded ? "Show less" : "Show All"
                
                cell = textCell
            } else {
                let switchCell = tableView.dequeueReusableCellWithIdentifier("SwitchableCell") as! SwitchableCell
                switchCell.titleLabel.text = self.categoryTitleFromIndex(row)
                switchCell.delegate = self
                switchCell.stateSwitch.on = self.currentPref.categoryIndexes.contains(row)
                cell = switchCell
            }
        }
        
        guard let _ = cell else {
            return UITableViewCell()
        }
        
        return cell!
    }
    
    private func distanceTitleFromIndex(index:Int) -> String {
        let mile = YelpFilterDataSource.distanceValues[index]
        
        if mile == 0 {
            return "Auto"
        }
        return "\(mile) miles"
    }
    
    private func sortOptionTitleFromIndex(index:Int) -> String {
        return YelpFilterDataSource.sortOptionValues[index]
    }
    
    private func categoryTitleFromIndex(index:Int) -> String {
        return YelpFilterDataSource.categories[index]["name"]!; // Fail will crash to notice
    }
}

extension SettingViewController:UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let section = indexPath.section
        let row = indexPath.row
        
        switch section {
        case 1:
            if distanceExpanded {
                // reload section
                self.currentPref.distanceIndex = row
            }
            distanceExpanded = !distanceExpanded
            tableView.reloadSections(NSIndexSet(index: section), withRowAnimation: UITableViewRowAnimation.Automatic)
        case 2:
            if sortExpanded {
                // reload section
                self.currentPref.sortOptionIndex = row
            }
            sortExpanded = !sortExpanded
            tableView.reloadSections(NSIndexSet(index: section), withRowAnimation: UITableViewRowAnimation.Automatic)
        case 3:
            if row == tableView.numberOfRowsInSection(section) - 1 {
                categoryExpanded = !categoryExpanded
                tableView.reloadSections(NSIndexSet(index: section), withRowAnimation: UITableViewRowAnimation.Automatic)
            }
        default:
            break
        }
    }
}

extension SettingViewController: SwitchableCellDelegate {
    func switchableCell(cell: SwitchableCell, valueDidChanged newValue: Bool) {
        let indexPath = self.filterTableView.indexPathForCell(cell)
        guard let _ = indexPath else {
            return
        }
        
        let row = indexPath!.row
        let section = indexPath!.section
        
        if section == 3 {
            print("Before \(self.currentPref.categoryIndexes)")
            if newValue {
                self.currentPref.categoryIndexes.append(row)
            } else {
                let indexOfRow = self.currentPref.categoryIndexes.indexOf(row)
                if indexOfRow != nil {
                    self.currentPref.categoryIndexes.removeAtIndex(indexOfRow!)
                }
            }
            print("End \(self.currentPref.categoryIndexes)")
        } else if section == 0 {
            self.currentPref.deals = newValue
        }
        
    }
}