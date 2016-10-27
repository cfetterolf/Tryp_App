//
//  AddLocation.swift
//  Tryp
//
//  Created by Chris Fetterolf on 10/15/16.
//  Copyright © 2016 DeepHause. All rights reserved.
//

import UIKit
import Parse
import MapKit


class AddLocation: UIViewController {
   
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    
    
    @IBAction func back(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        indx = 1
        titleLabel.text = Title
        subtitleLabel.text = Subtitle
        
        
    }
    
    func displayAlert(_ title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func addLocation(_ sender: AnyObject) {
        
        if tripArray.index(forKey: Title) != nil {
            self.displayAlert("Error", message: "\(Title) has already been added!")
            return
        }
        
        // Interally update locationsTuple
        tripArray[Title] = locationsOfPinDrop
        placesArray.append(Title)
        
        // Update locations/places array in Parse
        let query = PFQuery(className: "Trip")
        query.whereKey("user", equalTo:(PFUser.current()?.username)!)
        query.whereKey("tripName", equalTo: currentTrip)
        query.findObjectsInBackground { (objects, error) in
            if error != nil {
                print(error)
            } else {
                for object in objects! {
                    object["places"] = tripArray
                    object["placesArray"] = placesArray
                    object.saveInBackground(block: { (success, error) in
                        if (success) {
                            // The object has been saved.
                        } else {
                            // There was a problem, check error.description
                            print(error)
                        }
                    })
                }
            }
        }
        
        displayAlert("Added Location to Trip!", message: "")
        
    }
    
    @IBAction func removeLocation(_ sender: AnyObject) {
        
        if tripArray.index(forKey: Title) == nil {
            self.displayAlert("Error", message: "\(Title) not yet added to Trip!")
            return
        }
        
        // Internal Update
        tripArray.removeValue(forKey: Title)
        placesArray.remove(at: placesArray.index(of: Title)!)
        
        // Update locations/places array in Parse
        let query = PFQuery(className: "Trip")
        query.whereKey("user", equalTo:(PFUser.current()?.username)!)
        query.whereKey("tripName", equalTo: currentTrip)
        query.findObjectsInBackground { (objects, error) in
            if error != nil {
                print(error)
            } else {
                for object in objects! {
                    object["places"] = tripArray
                    object["placesArray"] = placesArray
                    object.saveInBackground(block: { (success, error) in
                        if (success) {
                            // The object has been saved.
                        } else {
                            // There was a problem, check error.description
                            print(error)
                        }
                    })
                }
            }
        }
        
        displayAlert("Removed Location from Trip", message: "")
        
    }
    
    
    
    @IBAction func saveLocation(_ sender: AnyObject) {
        
        if savedLocations.index(forKey: Title) != nil {
            self.displayAlert("Error", message: "\(Title) has already been saved")
        } else {
            // Interally update tripArray
            savedLocations[Title] = locationsOfPinDrop
            savedArray.append(Title)
            
            // Update Dict in Parse
            let query = PFQuery(className: "Trip")
            query.whereKey("user", equalTo:(PFUser.current()?.username)!)
            query.whereKey("tripName", equalTo: currentTrip)
            query.findObjectsInBackground { (objects, error) in
                if error != nil {
                    print(error)
                } else {
                    for object in objects! {
                        object["savedPlaces"] = savedLocations
                        object["savedPlacesArray"] = savedArray
                        object.saveInBackground()
                    }
                }
            }
            displayAlert("Saved Location!", message: "")
        }
    }
    
    
    
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
    func getImageURL(url: String) -> String {
        let url = NSURL(string: url)
        var imageURL = ""
        let session = NSURLSession.sharedSession();
        let task = session.dataTaskWithURL(url!) { (data, response, error) in
            if error != nil {
                print(error)
            } else {
                if let data = data {
                    do { let jsonResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                        
                        if jsonResult.count > 0 {
                            if let items = jsonResult["items"] as? NSArray {
                                let firstObject = items.firstObject as! NSDictionary
                                if let link = firstObject["link"] {
                                    imageURL = link as! String
                                    
                                }
                                
                            }
                            
                        }
                    } catch {}
                }
                
                
            }
            
            
            
        }
        task.resume()
        
        return imageURL
        
    }
    */
    
}

