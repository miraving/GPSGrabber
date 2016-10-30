//
//  LocationPoint+CoreDataProperties.swift
//  GPSGrabber
//
//  Created by Vitalii Obertynskyi on 10/27/16.
//  Copyright © 2016 Vitalii Obertynskyi. All rights reserved.
//

import Foundation
import CoreData


extension LocationPoint {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LocationPoint> {
        
        return NSFetchRequest<LocationPoint>(entityName: "LocationPoint");
    }

    @NSManaged public var lat: Float
    @NSManaged public var lon: Float
    @NSManaged public var dateTime: NSDate?

}
