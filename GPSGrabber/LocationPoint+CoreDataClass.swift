//
//  LocationPoint+CoreDataClass.swift
//  GPSGrabber
//
//  Created by Vitalii Obertynskyi on 10/27/16.
//  Copyright © 2016 Vitalii Obertynskyi. All rights reserved.
//

import Foundation
import CoreData


public class LocationPoint: NSManagedObject {

    func coordinateToString() -> String {
        
        let result = String("\(self.lat) / \(self.lon)")
        return result!
    }
    
    func dateTimeToString() -> String {
     
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss [dd-MMM]"
        return formatter.string(from: self.dateTime as! Date)
    }
}
