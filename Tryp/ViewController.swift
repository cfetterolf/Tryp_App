//
//  ViewController.swift
//  Tryp
//
//  Created by Chris Fetterolf on 10/9/16.
//  Copyright © 2016 DeepHause. All rights reserved.
//  search engine ID: 005621246323813691966:xpcgp8jfcay

import UIKit
import MapKit
import CoreLocation
import Parse

var locationsOfPinDrop: PFGeoPoint?
var locationToAdd: MKMapItem?
var placeName: String = ""
var imageURL = ""
var Title: String = ""
var Subtitle: String = ""

protocol HandleMapSearch {
    func dropPinZoomIn(_ placemark:MKPlacemark)
}

class ViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var mapItems = [MKMapItem]()

    var selectedPin:MKPlacemark? = nil
    
    var resultSearchController:UISearchController? = nil
    
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet var tableView: UITableView!
    

    let textCellIdentifier = "TextCell"
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    func addActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    @IBAction func editTrip(_ sender: AnyObject) {
        performSegue(withIdentifier: "edit", sender: self)
    }
    
    
    @IBAction func showTrip(_ sender: AnyObject) {
        
        addActivityIndicator()
        mapView.removeAnnotations(mapView.annotations)
        self.dropPin(placesArray[0], time: 0)
        calculateSegmentDirections(0, time: 0, routes: [])
        
    }
    
    func calculateSegmentDirections(_ index: Int, time: TimeInterval, routes: [MKRoute]) {
        // 1
        let request: MKDirectionsRequest = MKDirectionsRequest()
        request.source = mapItems[index]
        request.destination = mapItems[index+1]
        // 2
        request.requestsAlternateRoutes = true
        // 3
        request.transportType = .automobile
        // 4
        let directions = MKDirections(request: request)
        directions.calculate (completionHandler: {
            (response: MKDirectionsResponse?, error: NSError?) in
            if let routeResponse = response?.routes {
                
                let quickestRouteForSegment: MKRoute =
                    routeResponse.sorted(by: {$0.expectedTravelTime <
                        $1.expectedTravelTime})[0]
                
                var timeVar = time
                var routesVar = routes
                
                routesVar.append(quickestRouteForSegment)
                timeVar += quickestRouteForSegment.expectedTravelTime
                
                self.dropPin(placesArray[index+1], time: quickestRouteForSegment.expectedTravelTime)
                
                if index+2 < placesArray.count {
                    self.calculateSegmentDirections(index+1, time: timeVar, routes: routesVar)
                } else {
                    self.showRoute(routesVar, time: timeVar)
                    self.activityIndicator.stopAnimating()
                }

            } else if let _ = error {
                let alert = UIAlertController(title: nil,
                    message: "Directions not available.", preferredStyle: .alert)
                let okButton = UIAlertAction(title: "OK",
                style: .cancel) { (alert) -> Void in
                }
                alert.addAction(okButton)
                self.present(alert, animated: true,
                    completion: nil)
            }
        } as! MKDirectionsHandler)
    }
    
    func showRoute(_ routes: [MKRoute], time: TimeInterval) {
        for route in routes {
            plotPolyline(route)
            
        }
        //printTimeToLabel(time)
    }
    
    func dropPin(_ place: String, time: TimeInterval) {
        let location = tripArray[place]
        let latitude = location!.latitude
        let longitude = location!.longitude
        let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        let newCoordinate = coordinate
        let location2 = CLLocation(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude)
        
        CLGeocoder().reverseGeocodeLocation(location2, completionHandler: { (placemarks, error) -> Void in
            
            // Place details
            let placeMark = MKPlacemark(placemark: (placemarks?[0])!)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = placeMark.coordinate
            
            annotation.title = place
            if time == 0 {
                annotation.subtitle = "Start"
            } else {
                let timeString = self.stringFromTimeInterval(time)
                annotation.subtitle = "Segment Time: \(timeString)"
            }
            
            Title = place
            Subtitle = annotation.subtitle!
            
            locationToAdd = MKMapItem(placemark:
                MKPlacemark(coordinate: placeMark.location!.coordinate,
                    addressDictionary: placeMark.addressDictionary as! [String:AnyObject]?))
            
            self.mapView.addAnnotation(annotation)
        })
    }
    
    func stringFromTimeInterval(_ interval: TimeInterval) -> String {
        let interval = Int(interval)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        return String(format: "%02d:%02d", hours, minutes)
    }
    
    func plotPolyline(_ route: MKRoute) {
        mapView.add(route.polyline)
        if mapView.overlays.count == 1 {
            mapView.setVisibleMapRect(route.polyline.boundingMapRect,
                                      edgePadding: UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0),
                                      animated: true)
        }
            // 3
        else {
            let polylineBoundingRect =  MKMapRectUnion(mapView.visibleMapRect,
                                                       route.polyline.boundingMapRect)
            mapView.setVisibleMapRect(polylineBoundingRect,
                                      edgePadding: UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0),
                                      animated: true)
        }
    }
    
    func getLocationsFinal(_ index: Int) {
        
        if placesArray.count > index {
            
            let location = tripArray[placesArray[index]]
            
            let coordinate = CLLocationCoordinate2DMake(location!.latitude, location!.longitude)
            
            let location2 = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            
            CLGeocoder().reverseGeocodeLocation(location2, completionHandler: { (placemarks, error) -> Void in
                
                let placeMark = MKPlacemark(placemark: (placemarks?[0])!)
                
                self.mapItems.append(MKMapItem(placemark: placeMark))
                
                print(placesArray[index])
                
                self.getLocationsFinal(index + 1)
                
            })
            
        }
        
    }
    

    
    override func viewWillAppear(_ animated: Bool) {
        indx = 1
        
        getLocationsFinal(0)
        
        self.tableView.reloadData()
        
    }
    
    // MARK: Format TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tripArray.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(currentTrip)"
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
        cell.textLabel?.text = placesArray[row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let row = (indexPath as NSIndexPath).row
        let place = placesArray[row]
        let location = tripArray[place]
        let latitude = location!.latitude
        let longitude = location!.longitude
        let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        let span:MKCoordinateSpan = MKCoordinateSpanMake(0.5, 0.5)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(coordinate, span)

        let newCoordinate = coordinate
        let location2 = CLLocation(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude)

        CLGeocoder().reverseGeocodeLocation(location2, completionHandler: { (placemarks, error) -> Void in
            
            // Place details
            let placeMark = MKPlacemark(placemark: (placemarks?[0])!)
            self.selectedPin = placeMark
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = placeMark.coordinate
            annotation.title = placeMark.name
            if let city = placeMark.locality,
                let state = placeMark.administrativeArea {
                annotation.subtitle = "\(city) \(state)"
            }
            // Sets search parameter placeName
            placeName = "\(placeMark.name!) \(annotation.subtitle!)"
            
            Title = place
            Subtitle = annotation.subtitle!
            
            locationToAdd = MKMapItem(placemark:
                MKPlacemark(coordinate: placeMark.location!.coordinate,
                    addressDictionary: placeMark.addressDictionary as! [String:AnyObject]?))
            
            self.mapView.addAnnotation(annotation)
            let span = MKCoordinateSpanMake(0.1, 0.1)
            let region = MKCoordinateRegionMake(placeMark.coordinate, span)
            self.mapView.setRegion(region, animated: true)
            
            let location = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
            locationsOfPinDrop = PFGeoPoint(location: location)
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up TableView
        tableView.delegate = self
        tableView.dataSource = self
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        mapView.showsPointsOfInterest = true
        
        let uilpgr = UILongPressGestureRecognizer(target: self, action: #selector(ViewController1.action(_:)))
        uilpgr.minimumPressDuration = 2.0
        mapView.addGestureRecognizer(uilpgr)
        
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.titleView = resultSearchController?.searchBar
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self
        
    }
    
    func getDirections(){
        if let selectedPin = selectedPin {
            let mapItem = MKMapItem(placemark: selectedPin)
            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
            mapItem.openInMaps(launchOptions: launchOptions)
        }
    }
    
    func action(_ gestureRecognizer:UIGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            let touchPoint = gestureRecognizer.location(in: self.mapView)
            let newCoordinate = self.mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
            let location = CLLocation(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude)
            CLGeocoder().reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
                var title = ""
                if (error == nil) {
                    if let p = placemarks?[0] {
                        var subThoroughfare:String = ""
                        var thoroughfare:String = ""
                        if p.subThoroughfare != nil {
                            subThoroughfare = p.subThoroughfare!
                        }
                        if p.thoroughfare != nil {
                            thoroughfare = p.thoroughfare!
                        }
                        title = "\(subThoroughfare) \(thoroughfare)"
                    }
                }
                if title.trimmingCharacters(in: CharacterSet.whitespaces) == "" {
                    title = "Added \(Date())"
                }
                let annotation = MKPointAnnotation()
                annotation.coordinate = newCoordinate
                annotation.title = title
                
                Title = title
                Subtitle = ""
                
                locationsOfPinDrop = PFGeoPoint(location: location)
                
                self.mapView.removeAnnotations(self.mapView.annotations)
                self.mapView.addAnnotation(annotation)
            })
        }
    }
    
}

extension ViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpanMake(0.2, 0.2)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }
}

extension ViewController: HandleMapSearch {
    
    // Gets location of search
    func dropPinZoomIn(_ placemark:MKPlacemark){
        // cache the pin
        selectedPin = placemark
        
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        // Sets search parameter placeName
        placeName = "\(placemark.name!) \(annotation.subtitle!)"
        
        Title = placemark.name!
        Subtitle = annotation.subtitle!
        
        locationToAdd = MKMapItem(placemark:
            MKPlacemark(coordinate: placemark.location!.coordinate,
                addressDictionary: placemark.addressDictionary as! [String:AnyObject]?))
        
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
        
        let location = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
        locationsOfPinDrop = PFGeoPoint(location: location)
    }
}

extension ViewController : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView?.pinTintColor = UIColor.orange
        pinView?.canShowCallout = true
        pinView?.animatesDrop = true
        
        //creates addTrip button on right
        let addTripButton = UIButton(type: UIButtonType.contactAdd)
        pinView?.rightCalloutAccessoryView = addTripButton
        
        //sets up Tryp directions button
        let smallSquare = CGSize(width: 30, height: 30)
        let button = UIButton(frame: CGRect(origin: CGPoint.zero, size: smallSquare))
        button.setBackgroundImage(UIImage(named: "van_icon3x"), for: UIControlState())
        button.addTarget(self, action: #selector(ViewController.getDirections), for: .touchUpInside)
        pinView?.leftCalloutAccessoryView = button
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        //I don't know how to convert this if condition to swift 1.2 but you can remove it since you don't have any other button in the annotation view
        if (control as? UIButton)?.buttonType == UIButtonType.contactAdd {
            mapView.deselectAnnotation(view.annotation, animated: false)
            
            //segue to popUpView
            performSegue(withIdentifier: "info", sender: view)
            
            /*
            let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("sbPopUpID") as! PopUpViewController
            self.navigationController?.addChildViewController(popOverVC)
            popOverVC.view.frame = (self.navigationController?.view.frame)!
            self.navigationController!.view.addSubview(popOverVC.view)
            popOverVC.didMoveToParentViewController(self)
            */
        }
    }
    
    func mapView(_ mapView: MKMapView,
                 rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        if (overlay is MKPolyline) {
            polylineRenderer.strokeColor =
                UIColor.blue.withAlphaComponent(0.5)
            polylineRenderer.lineWidth = 5
        }
        return polylineRenderer
    }

    
    
    
}
