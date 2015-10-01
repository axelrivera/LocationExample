//
//  MainViewController.swift
//  LocationExample
//
//  Created by Axel Rivera on 9/25/15.
//  Copyright © 2015 Axel Rivera. All rights reserved.
//

import UIKit

class MainViewController: UITableViewController {
    
    let CellIdentifier = "Cell"
    
    var places = PlaceArray()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.title = "Places"
        
        loadPlaces()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func loadView() {
        self.tableView = UITableView(frame: CGRectZero, style: .Plain)
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: UIBarButtonSystemItem.Add,
            target: self,
            action: Selector("addAction:")
        )
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadPlaces() {
        if let json = readJSONFromFilePath(pathInDocumentsDirectory(PlacesFilename)) {
            if let jsonPlaces = json.array {
                places = jsonPlaces.map { (jsonObject) -> Place in
                    return Place(json: jsonObject)
                }
            }
        }
    }
    
    func savePlaces() {
        let placesRaw = places.map { (place) -> [String: AnyObject] in
            return place.dictionary
        }
        
        writeObjectAsJSON(placesRaw, filePath: pathInDocumentsDirectory(PlacesFilename))
    }
    
}

extension MainViewController {
    
    func addAction(sender: AnyObject?) {
        let editController = EditViewController(place: nil)
        
        editController.saveBlock = { [unowned self] (place) in
            self.places.append(place)
            self.tableView.reloadData()
            
            self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
        }
        
        editController.cancelBlock = { () -> Void in
            self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
        }
        
        let navController = UINavigationController(rootViewController: editController)
        
        self.navigationController?.presentViewController(navController, animated: true, completion: nil)
    }
    
}

// MARK: - UITableViewDataSource Methods

extension MainViewController {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier) as UITableViewCell!
        
        if cell == nil {
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: CellIdentifier)
            cell.textLabel?.font = UIFont.systemFontOfSize(15.0)
            cell.detailTextLabel?.font = UIFont.systemFontOfSize(12.0)
            cell.detailTextLabel?.textColor = UIColor.lightGrayColor()
        }
        
        let place = places[indexPath.row]
        
        cell.textLabel?.text = place.title
        cell.detailTextLabel?.text = place.city
        
        cell.selectionStyle = .Default
        cell.accessoryType = .DisclosureIndicator
        
        return cell
    }
    
}

// MARK: - UITableViewDelegate Methods

extension MainViewController {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let place = places[indexPath.row]
        
        let editController = EditViewController(place: place)
        
        editController.saveBlock = { [unowned self] (editedPlace) in
            if let index = self.places.indexOf(editedPlace) {
                self.places[index] = editedPlace
                self.tableView.reloadData()
                
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
        
        self.navigationController?.pushViewController(editController, animated: true)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 48.0
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            self.places.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
    }
    
}
