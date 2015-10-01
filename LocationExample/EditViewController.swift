//
//  EditViewController.swift
//  LocationExample
//
//  Created by Axel Rivera on 9/25/15.
//  Copyright © 2015 Axel Rivera. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class EditViewController: UITableViewController {
    
    let TextFieldCellIdentifier = "TextFieldCell"
    let MapCellIdentifier = "MapCell"
    
    let mapViewHeight: CGFloat = 300.0
    
    var titleTextField: UITextField!
    var cityTextField: UITextField!
    var mapView: MKMapView!
    
    var dataSource = TableSectionArray()
    
    var place: Place!
    
    var currentCoordinate: CLLocationCoordinate2D?
    
    lazy var locationManager: CLLocationManager = {
       return CLLocationManager()
    }()
        
    var saveBlock: ((place: Place) -> Void)?
    var cancelBlock: (() -> Void)?
    
    var isEdit = false
    
    init(place: Place?) {
        super.init(nibName: nil, bundle: nil)
        
        self.title = "Place"
        
        if let placeToEdit = place {
            self.place = placeToEdit
            isEdit = true
        } else {
            self.place = Place()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func loadView() {
        self.tableView = UITableView(frame: CGRectZero, style: .Grouped)
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.keyboardDismissMode = .Interactive
        
        if let _ = cancelBlock {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .Cancel,
                target: self,
                action: Selector("dismissAction:")
            )
        }
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .Save,
            target: self,
            action: Selector("saveAction:")
        )
        
        titleTextField = UITextField()
        titleTextField.textAlignment = .Left
        titleTextField.placeholder = "Castillo San Felipe del Morro"
        titleTextField.autocapitalizationType = .Words
        titleTextField.clearButtonMode = .WhileEditing
        titleTextField.contentVerticalAlignment = .Center
        
        cityTextField = UITextField()
        cityTextField.textAlignment = .Left
        cityTextField.placeholder = "San Juan"
        cityTextField.autocapitalizationType = .Words
        cityTextField.clearButtonMode = .WhileEditing
        cityTextField.contentVerticalAlignment = .Center
        
        mapView = MKMapView()
        mapView.delegate = self
        mapView.scrollEnabled = false
        
        mapView.layer.cornerRadius = 5.0
        mapView.layer.borderWidth = singlePixelLineMetric()
        mapView.layer.borderColor = UIColor.lightGrayColor().CGColor
        
        if isEdit {
            if let annotation = place.annotation {
                mapView.addAnnotation(annotation)
                setMapRegionWithCenter(annotation.coordinate, animated: false)
            }
        }
        
        updateDataSource()
        
        // Default Values
        
        titleTextField.text = place.title
        cityTextField.text = place.city
        currentCoordinate = place.coordinate
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if !isEdit {
            locationManager.requestWhenInUseAuthorization()
            mapView.showsUserLocation = true
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if !isEdit {
            mapView.showsUserLocation = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateDataSource() {
        var content: TableRow!
        var rows = TableRowArray()
        var sections = TableSectionArray()
        
        content = TableRow(text: "Title")
        content.object = titleTextField
        content.groupIdentifier = TextFieldCellIdentifier
        
        rows.append(content)
        
        content = TableRow(text: "City")
        content.object = cityTextField
        content.groupIdentifier = TextFieldCellIdentifier
        
        rows.append(content)
        
        let title = isEdit ? "Edit Place" : "Add Place"
        sections.append(TableSection(title: title, rows: rows))
        
        rows = TableRowArray()
        
        content = TableRow(object: mapView)
        content.groupIdentifier = MapCellIdentifier
        content.height = mapViewHeight + 30.0
        rows.append(content)
        
        sections.append(TableSection(title: nil, rows: rows))
        
        self.dataSource = sections
        self.tableView.reloadData()
    }
    
    func setMapRegionWithCenter(center: CLLocationCoordinate2D?, animated: Bool) {
        if let coordinate = center {
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            mapView.setRegion(MKCoordinateRegion(center: coordinate, span: span), animated: animated)
        }
    }

}

// MARK: - Selector Methods

extension EditViewController {
    
    func dismissAction(sender: AnyObject?) {
        if let cancelBlock = self.cancelBlock {
            cancelBlock()
        }
    }
    
    func saveAction(sender: AnyObject?) {
        let title = titleTextField.text ?? String()
        let city = cityTextField.text ?? String()
        
        let showError = title.isEmpty || city.isEmpty
        if showError {
            let actionController = UIAlertController(title: "Missing Values", message: "Complete all fields", preferredStyle: .Alert)
            
            let cancelAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
            actionController.addAction(cancelAction)
            
            self.presentViewController(actionController, animated: true, completion: nil)
            
            return
        }
        
        place.title = title
        place.city = city
        place.coordinate = currentCoordinate
        
        if let saveBlock = self.saveBlock {
            saveBlock(place: place)
        }
    }
    
}

extension EditViewController: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        if !isEdit {
            currentCoordinate = userLocation.coordinate
            setMapRegionWithCenter(currentCoordinate, animated: true)
        }
    }
    
    func mapView(mapView: MKMapView, didFailToLocateUserWithError error: NSError) {
        mapView.showsUserLocation = false
        
        let message = "Unable to get the current location. You will not be able to save the current Place without a location. Try again?"
        
        let alertView = UIAlertController(title: "Error", message: message, preferredStyle: .Alert)
        
        let confirmationAction = UIAlertAction(title: "YES", style: .Default) { [unowned self] (action) -> Void in
            self.mapView.showsUserLocation = true
        }
        alertView.addAction(confirmationAction)
        
        let cancelAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
        alertView.addAction(cancelAction)
        
        self.navigationController?.presentViewController(alertView, animated: true, completion: nil)
    }
    
}

// MARK: - UITableViewDataSource Methods

extension EditViewController {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].rows.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let row = dataSource[indexPath.section].rows[indexPath.row]
        let groupIdentifier = row.groupIdentifier ?? String()
        
        if let textField = row.object as? UITextField where groupIdentifier == TextFieldCellIdentifier {
            var cell = tableView.dequeueReusableCellWithIdentifier(TextFieldCellIdentifier) as UITableViewCell!
            if cell == nil {
                cell = UITableViewCell(style: .Default, reuseIdentifier: TextFieldCellIdentifier)
                cell.textLabel?.font = UIFont.systemFontOfSize(14.0)
            }
            
            let padding: CGFloat = 30.0 + 80.0
            textField.frame = CGRectMake(0.0, 0.0, tableView.bounds.size.width - padding, 30.0)
            
            cell.textLabel?.text = row.text
            cell.accessoryView = textField
            
            cell.selectionStyle = .None
            
            return cell
        }
        
        if let mapView = row.object as? MKMapView where groupIdentifier == MapCellIdentifier {
            var cell = tableView.dequeueReusableCellWithIdentifier(MapCellIdentifier) as UITableViewCell!
            if cell == nil {
                cell = UITableViewCell(style: .Default, reuseIdentifier: MapCellIdentifier)
                cell.textLabel?.font = UIFont.systemFontOfSize(14.0)
            }
            
            mapView.frame = CGRectMake(0.0, 15.0, tableView.bounds.size.width - 30.0, mapViewHeight)
            
            cell.accessoryView = mapView
            
            cell.selectionStyle = .None
            
            return cell
        }
        
        return UITableViewCell(style: .Default, reuseIdentifier: nil)
    }
    
}

// MARK: - UITableViewDelegate Methods

extension EditViewController {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return dataSource[indexPath.section].rows[indexPath.row].height ?? 44.0
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataSource[section].title
    }
    
}

