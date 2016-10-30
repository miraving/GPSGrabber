//
//  ViewController.swift
//  GPSGrabber
//
//  Created by Vitalii Obertynskyi on 10/27/16.
//  Copyright © 2016 Vitalii Obertynskyi. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import GoogleMaps

final class ViewController: UIViewController {

    @IBOutlet var mapView: GMSMapView!
    @IBOutlet var emptyView: UIView!
    @IBOutlet var contentView: UIView!
    
    private lazy var locationManager: CLLocationManager = {
       
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
        manager.requestAlwaysAuthorization()
        return manager
    }()

    
    
    @IBAction func enabledChanged(_ sender: UISwitch) {
       
        if sender.isOn {
            self.configureLocationManagger()
            self.locationManager.startUpdatingLocation()
            self.mapView.animate(toZoom: 16)
        } else {
            self.locationManager.stopUpdatingLocation()
            (UIApplication.shared.delegate as! AppDelegate).dataManager.saveContext()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        self.checkLocatiomAuthorizedAccess()
    }
    
    private func configureLocationManagger() {
        
        let accuracyValues = [
            kCLLocationAccuracyBestForNavigation,
            kCLLocationAccuracyBest,
            kCLLocationAccuracyNearestTenMeters,
            kCLLocationAccuracyHundredMeters,
            kCLLocationAccuracyKilometer,
            kCLLocationAccuracyThreeKilometers]
        
        let value = UserDefaults.standard.integer(forKey: "locationAccuracyValue")
        self.locationManager.desiredAccuracy = accuracyValues[value]
    }
    
    func checkLocatiomAuthorizedAccess() {
        
        if CLLocationManager.authorizationStatus() == .notDetermined {
            self.locationManager.requestAlwaysAuthorization()
            return
        }
        
        
        let isHideMap = (CLLocationManager.authorizationStatus() == .authorizedAlways)
        self.contentView.isHidden = !isHideMap
        self.emptyView.isHidden = isHideMap
        
        if isHideMap == false {
            
            let alertController = UIAlertController(title: "Location access is denied", message: "Please take access for application", preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alertController.addAction(UIAlertAction(title: "Go to app Settings", style: .default, handler: { (action) in    
                self.goToSettings()
            }))
            
            self.present(alertController, animated: true, completion: nil)
            
        } else {
            self.mapView.isMyLocationEnabled = true
        }
    }
    
    @IBAction func goToSettings() {
        
        UIApplication.shared.open(URL(string:UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
    }
}

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
       
        guard let mostRecentLocation = locations.last else {
            return
        }
        // Add another annotation to the map.
        let annotation = MKPointAnnotation()
        annotation.coordinate = mostRecentLocation.coordinate
        
        if UIApplication.shared.applicationState == .active {
            self.mapView.animate(toLocation: mostRecentLocation.coordinate)
        }
        let app = UIApplication.shared.delegate as! AppDelegate
        app.dataManager.saveToCacheLocation(coordinate: mostRecentLocation.coordinate)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        self.checkLocatiomAuthorizedAccess()
    }
}
