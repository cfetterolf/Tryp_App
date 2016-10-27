//
//  ViewControllerSavedLocations.swift
//  Tryp
//
//  Created by Chris Fetterolf on 10/15/16.
//  Copyright © 2016 DeepHause. All rights reserved.
//

import UIKit
import MapKit
import Parse

class ViewControllerSavedLocations: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let textCellIdentifier = "TextCell"
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var tableView: UITableView!
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedLocations.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Places"
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let title = UILabel()
        title.textColor = UIColor.white
        
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor=title.textColor
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath)
        
        let row = (indexPath as NSIndexPath).row
        cell.textLabel?.text = savedArray[row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let row = (indexPath as NSIndexPath).row
        let place = savedArray[row]
        let location = savedLocations[place]
        let latitude = location!.latitude
        let longitude = location!.longitude
        let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        let span:MKCoordinateSpan = MKCoordinateSpanMake(0.5, 0.5)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(coordinate, span)
        
        let newCoordinate = coordinate
        let location2 = CLLocation(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude)
        CLGeocoder().reverseGeocodeLocation(location2, completionHandler: { (placemarks, error) -> Void in
            let title = savedArray[row]
            let annotation = MKPointAnnotation()
            annotation.coordinate = newCoordinate
            annotation.title = title
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.mapView.addAnnotation(annotation)
        })
        self.mapView.setRegion(region, animated: true)
    }

    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    

}
