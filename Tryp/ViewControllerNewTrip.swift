//
//  ViewControllerNewTrip.swift
//  Tryp
//
//  Created by Chris Fetterolf on 10/10/16.
//  Copyright © 2016 DeepHause. All rights reserved.
//

import UIKit
import Parse

class ViewControllerNewTrip: UIViewController {
    
    @IBOutlet weak var textField: UITextField!
    
    @IBAction func createNewTrip(_ sender: AnyObject) {
        
        if myTrips.contains(textField.text!) == true {
            displayAlert("Trip with name \(textField.text!) taken", message: "Call your new trip something else")
            textField.text = ""
        } else {
            // Set set new Trip to current Trip
            currentTrip = self.textField.text!
            myTrips.insert(currentTrip, at: 0)
            
            // Clear Internal data structures except "Saved"
            tripArray = [String: PFGeoPoint]()
            placesArray = [String]()
            
            
            
            // Make a new Trip
            let trip = PFObject(className:"Trip")
            trip["tripName"] = currentTrip
            trip["places"] = tripArray
            trip["savedPlaces"] = savedLocations
            trip["user"] = PFUser.current()?.username
            trip["placesArray"] = placesArray
            trip["savedPlacesArray"] = savedArray
            trip.saveInBackground(block: { (success, error) in
                if (success) {
                    // The object has been saved.
                    print("saved")
                } else {
                    // There was a problem, check error.description
                    print(error)
                }
            })
            
            // Update current trip in User class
            let user = PFUser.current()!
            user["currentTripString"] = currentTrip
            user["myTrips"] = myTrips
            user.saveInBackground(block: { (success, error) in
                if (success) {
                    // The object has been saved.
                } else {
                    // There was a problem, check error.description
                    print(error)
                }
            })
            
            displayAlert("\(currentTrip) added!", message: "")
            self.textField.text=""
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    func displayAlert(_ title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

   

}
