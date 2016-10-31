//
//  AppDelegate.swift
//  GPSGrabber
//
//  Created by Vitalii Obertynskyi on 10/27/16.
//  Copyright © 2016 Vitalii Obertynskyi. All rights reserved.
//

import UIKit
import GoogleMaps
import AWSCore
import AWSCognito

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var dataManager = DataManager()
    var reachability: AWSKSReachability!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // google
        GMSServices.provideAPIKey("AIzaSyCqdO8rNETPFysAp18baxr8EckWAYc33SA")
        // amazon
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .euCentral1, identityPoolId:"eu-central-1:cea63a1d-de3f-4dca-bf03-af4c80162a3d")
        let configuration = AWSServiceConfiguration(region: .euCentral1, credentialsProvider:credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        reachabilitySetup()
        // internal settings set
        registerSettingBundle()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        dataManager.saveContext()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        registerSettingBundle()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
        dataManager.saveContext()
    }

    func registerSettingBundle() {
        
        let pathStr = Bundle.main.bundlePath
        let settingsBundlePath = pathStr.appending("/Settings.bundle")
        let finalPath = settingsBundlePath.appending("/Root.plist")
        let settingsDict = NSDictionary(contentsOfFile: finalPath)
        let prefSpecifierArray = settingsDict?.object(forKey: "PreferenceSpecifiers") as! NSArray
        
        var defaults:[String:AnyObject] = [:]
        for item in prefSpecifierArray {
            
            if let dict = item as? [String: AnyObject] {
               
                if let key = dict["Key"] as! String! {
                  
                    let defaultValue = dict["DefaultValue"] as? NSNumber
                    defaults[key] = defaultValue
                }
            }
        }
        UserDefaults.standard.register(defaults: defaults)
    }
    
    func reachabilitySetup() {
       
        self.reachability = AWSKSReachability.toInternet()
        self.reachability.onReachabilityChanged = { reachabile in
            
            if self.reachability.reachable == true {
                self.dataManager.uploadCache()
            }
        }
    }
}

