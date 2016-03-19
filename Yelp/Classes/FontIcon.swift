//
//  FontIcon.swift
//  Yelp
//
//  Created by Tien on 3/19/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

extension UIFont {
//    + (UIFont *)ioniconsOfSize:(CGFloat)size {
//    return [UIFont fontWithName:@"Ionicons" size:size];
//    }
//    
//    + (void)printAllFontName {
//    for (NSString* family in [UIFont familyNames])
//    {
//    NSLog(@"%@", family);
//    
//    for (NSString* name in [UIFont fontNamesForFamilyName: family])
//    {
//    NSLog(@"  %@", name);
//    }
//    }
//    }
    
    class func ioniconsOfSize(size:CGFloat) -> UIFont {
        return UIFont(name: "ionicons", size: size)!;
    }
}
