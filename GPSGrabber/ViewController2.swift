//
//  ViewController2.swift
//  GPSGrabber
//
//  Created by Vitalii Obertynskyi on 10/27/16.
//  Copyright © 2016 Vitalii Obertynskyi. All rights reserved.
//

import UIKit
import CoreData
import AWSSQS

class ViewController2: UITableViewController {

    private var frController: NSFetchedResultsController<LocationPoint>?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.frController?.delegate = self
        
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.dataManager.persistentContainer.viewContext
        
        let request = NSFetchRequest<LocationPoint>(entityName:"LocationPoint")
        let sort = NSSortDescriptor(key: "dateTime", ascending: false)
        request.sortDescriptors = [sort]
        self.frController = NSFetchedResultsController(fetchRequest: request,
                                                              managedObjectContext: context,
                                                              sectionNameKeyPath: nil,
                                                              cacheName: nil)
        do {
            try self.frController?.performFetch()
        } catch {
            print("Smth wrong")
        }
    }

    @IBAction func uploadCache() {
        
        let app = UIApplication.shared.delegate as! AppDelegate
        app.dataManager.uploadCache()
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.frController?.fetchedObjects?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        if let object = frController?.fetchedObjects?[indexPath.row] {
            cell.textLabel?.text = object.coordinateToString()
            cell.detailTextLabel?.text = object.dateTimeToString()
        }
        
        return cell
    }
}

extension ViewController2: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        self.tableView.reloadData()
    }
}
