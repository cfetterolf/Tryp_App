//
//  ViewControllerAddLocation.swift
//  Tryp
//
//  Created by Chris Fetterolf on 10/12/16.
//  Copyright © 2016 DeepHause. All rights reserved.
//

import UIKit
import Parse
import MapKit


class ViewControllerAddLocation: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = Title
        subtitleLabel.text = Subtitle
        
        
    }
    
    func displayAlert(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }

    
    @IBAction func addLocation(sender: AnyObject) {
        
    
        
        if tripArray.indexForKey(Title) != nil {
            self.displayAlert("Error", message: "\(Title) has already been added!")
        } else {
            // Interally update tripArray
            tripArray[Title] = locationsOfPinDrop
            placesArray.append(Title)
            
            // Update locations/places array in Parse
            var query = PFQuery(className: "Trip")
            query.whereKey("user", equalTo:(PFUser.currentUser()?.username)!)
            query.whereKey("tripName", equalTo: currentTrip)
            query.findObjectsInBackgroundWithBlock { (objects, error) in
                if error != nil {
                    print(error)
                } else {
                    if objects?.count < 2 {
                        for object in objects! {
                            print("adding to Parse")
                            print(tripArray)
                            print(object)
                            object["places"] = tripArray
                            object["placesArray"] = placesArray
                            object.saveInBackgroundWithBlock {
                                (success: Bool, error: NSError?) -> Void in
                                if (success) {
                                    // The object has been saved.
                                } else {
                                    // There was a problem, check error.description
                                }
                            }
                            
                        }
                    } else {
                        self.displayAlert("Error", message: "More than 1 Trip with name \(currentTrip)")
                    }
                }
            }
            
            //Success!
          
            displayAlert("Added Location to Trip!", message: "")
            
        }
        
    }
    
    @IBAction func removeLocation(sender: AnyObject) {
        if tripArray.indexForKey(Title) != nil && placesArray.contains(Title) {
            
            // Internal Update
            tripArray.removeValueForKey(Title)
            placesArray.removeAtIndex(placesArray.indexOf(Title)!)
            
            // Update locations/places array in Parse
            var query = PFQuery(className: "Trip")
            query.whereKey("user", equalTo:(PFUser.currentUser()?.username)!)
            query.whereKey("tripName", equalTo: currentTrip)
            query.findObjectsInBackgroundWithBlock { (objects, error) in
                if error != nil {
                    print(error)
                } else {
                    for object in objects! {
                        object["places"] = tripArray
                        object["placesArray"] = placesArray
                        object.saveInBackgroundWithBlock {
                            (success: Bool, error: NSError?) -> Void in
                            if (success) {
                                // The object has been saved.
                            } else {
                                // There was a problem, check error.description
                            }
                        }
                    }
                }
            }
            
            displayAlert("Removed Location from Trip", message: "")
            
        } else {
            self.displayAlert("Error", message: "\(Title) not yet added to Trip!")
        }

        
        
    }
    @IBAction func saveLocation(sender: AnyObject) {
        
        if savedLocations.indexForKey(Title) != nil {
            self.displayAlert("Error", message: "\(Title) has already been saved")
        } else {
            // Interally update tripArray
            savedLocations[Title] = locationsOfPinDrop
            savedArray.append(Title)
            
            // Update Dict in Parse
            var query = PFQuery(className: "Trip")
            query.whereKey("user", equalTo:(PFUser.currentUser()?.username)!)
            query.whereKey("tripName", equalTo: currentTrip)
            query.findObjectsInBackgroundWithBlock { (objects, error) in
                if error != nil {
                    print(error)
                } else {
                    for object in objects! {
                        object["savedPlaces"] = savedLocations
                        object["savedPlacesArray"] = savedArray
                        object.saveInBackgroundWithBlock {
                            (success: Bool, error: NSError?) -> Void in
                            if (success) {
                                // The object has been saved.
                            } else {
                                // There was a problem, check error.description
                            }
                        }
                    }
                }
            }
            displayAlert("Saved Location!", message: "")
        }
    }
    
    
    
    
    
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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
    
    
}

