//
//  ViewControllerSignUp.swift
//  Tryp
//
//  Created by Chris Fetterolf on 10/8/16.
//  Copyright © 2016 DeepHause. All rights reserved.
//

import UIKit
import Parse

class ViewControllerSignUp: UIViewController, UITextFieldDelegate {

    @IBOutlet var username: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet weak var tripName: UITextField!
    @IBOutlet var nickname: UITextField!
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    func displayAlert(_ title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    
    
    
    
    
    @IBAction func signUp(_ sender: AnyObject) {
        
        if username.text == "" || password.text == "" || tripName.text == "" {
            
            displayAlert("Error", message: "Please enter a valid email, password, and Trip")
            
        } else {
            
            activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            UIApplication.shared.beginIgnoringInteractionEvents()
            
            var errorMessage = "Please try again later"
            
            let user = PFUser()
            user.username = username.text
            user.email = username.text
            user.password = password.text
            currentTrip = tripName.text!
            user["currentTripString"] = currentTrip
            myTrips.append(currentTrip)
            user["myTrips"] = myTrips
            user["favoriteTrips"] = favoriteTrips
            
           
            // Internal update
             UserDefaults.standard.set(tripName.text, forKey: "currentTrip")
            
            user.signUpInBackground(block: { (success, error) in
                
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
                
                if error == nil {
                    // Make a new Trip
                    let trip = PFObject(className:"Trip")
                    trip["tripName"] = self.tripName.text
                    trip["places"] = tripArray
                    trip["placesArray"] = placesArray
                    trip["savedPlaces"] = savedLocations
                    trip["user"] = self.username.text
                    trip["savedPlacesArray"] = savedArray
                    trip.saveInBackground(block: { (success, error) in
                        if (success) {
                            // The object has been saved.
                        } else {
                            // There was a problem, check error.description
                            print(error)
                        }
                    })
                    
                    self.performSegue(withIdentifier: "signUp", sender: self)
                    
                    
                } else {
                    
                    self.displayAlert("Failed Signup", message: errorMessage)
                }
            })
        }
    }
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.username.delegate = self;
        self.password.delegate = self;
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewControllerSignUp.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

}
