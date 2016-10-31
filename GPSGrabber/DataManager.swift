//
//  DataManager.swift
//  GPSGrabber
//
//  Created by Vitalii Obertynskyi on 10/27/16.
//  Copyright © 2016 Vitalii Obertynskyi. All rights reserved.
//

import Foundation
import CoreLocation
import CoreData
import AWSCognito

class DataManager {
    // Initialize the Cognito Sync client
    var syncClient: AWSCognito?
    
    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "GPSGrabber")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveContext () {
       
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func uploadCache() {
        DispatchQueue.global(qos: .background).async {
            
            let context = self.persistentContainer.viewContext
            let fetch: NSFetchRequest<LocationPoint> = LocationPoint.fetchRequest()
            var objects: [LocationPoint] = []
            do {
                objects = try context.fetch(fetch)
            } catch {
                print("smth wrong")
            }
            
            if objects.count > 0 {
                
                for point in objects {
                    
                    let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(point.lat),
                                                            longitude: CLLocationDegrees(point.lon))
                    self.saveDataToCognito(value: coordinate, dateTime: point.dateTime as! Date, completionBlock: {
                        // rem cache item
                        context.delete(point)
                        self.saveContext()
                    })
                }
            }
        }
    }
    
    func saveToCacheLocation(coordinate: CLLocationCoordinate2D) {
        
        DispatchQueue.global(qos: .background).async {
        
            let app = UIApplication.shared.delegate as! AppDelegate
            
            if app.reachability.reachable == true {
             
                self.saveDataToCognito(value: coordinate)
                
            } else {
            
                let managerContext = app.dataManager.persistentContainer.viewContext
                let point = LocationPoint(context: managerContext)
                point.lat = Float(coordinate.latitude)
                point.lon = Float(coordinate.longitude)
                point.dateTime = NSDate(timeIntervalSinceNow: 0)
                dump(point)
                managerContext.insert(point)
            }
        }
    }
    
    private func saveDataToCognito(value: CLLocationCoordinate2D, dateTime: Date = Date(), completionBlock: (() -> Void)? = nil) {
       
        if self.syncClient == nil {
            self.syncClient = AWSCognito.default()
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MMM-dd-HH-mm-ss"
        var key = dateFormatter.string(from: dateTime)
        if UIApplication.shared.applicationState == .active {
            key = "active_" + key
        } else {
            key = "backgroung_" + key
        }
        let dataset = self.syncClient?.openOrCreateDataset(key)
        dataset?.setString(String(value.latitude), forKey:"lat")
        dataset?.setString(String(value.longitude), forKey:"lon")
        dataset?.synchronize().continue({ (task: AWSTask) -> AnyObject? in
            // my handler code here
            dump(task)
            
            if (completionBlock != nil) {
                
                completionBlock!()
            }
            
            return nil
        })
    }
}
