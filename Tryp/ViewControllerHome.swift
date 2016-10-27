//
//  ViewControllerHome.swift
//  Tryp
//
//  Created by Chris Fetterolf on 10/6/16.
//  Copyright © 2016 DeepHause. All rights reserved.
//

import UIKit
import Parse
import MapKit

var tripArray = [String: PFGeoPoint]()
var savedLocations = [String: PFGeoPoint]()
var currentTrip = ""
var placesArray = [String]()
var savedArray = [String]()
var myTrips = [String]()
var favoriteTrips = [String]()
var expenseArr = [Expense]()

var indx = 0

class ViewControllerHome: UIViewController, UITextFieldDelegate {

    @IBOutlet var username: UITextField!
    @IBOutlet var password: UITextField!
    
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    func displayAlert(_ title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        expenseArr = [Expense]()
        
        // Do any additional setup after loading the view.
        self.username.delegate = self;
        self.password.delegate = self;
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewControllerHome.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    
    override func viewDidAppear(_ animated: Bool) {
        
        // Check if app has been launched before
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if launchedBefore  {
            //not first launch
            if PFUser.current()?.username != nil {
                
                // Login successful
                self.setTripInfo()
            }
        }
        else {
            //First launch
            UserDefaults.standard.set(true, forKey: "launchedBefore")
          
            //print("frist")
        }
        
        
    }
    

    @IBAction func login(_ sender: AnyObject) {
        
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        PFUser.logInWithUsername(inBackground: username.text!, password: password.text!, block: { (user, error) in
            
            var errorMessage = "Please try again later"
            
            self.activityIndicator.stopAnimating()
            
            UIApplication.shared.endIgnoringInteractionEvents()
            
            if user != nil {
                
                //Logged in!
                
                self.setTripInfo()
                
                
            } else {
                
                self.displayAlert("Failed Login", message: "")
            }
        })
    }
    
    
    // Retrieves all info from Parse Server
    func setTripInfo() {
        
        let query = PFQuery(className: "_User")
        query.getObjectInBackground(withId: (PFUser.current()?.objectId)!, block: { (object, error) in
            if error != nil {
                print(error)
            } else {
                // Set name of current Trip
                currentTrip = object!["currentTripString"] as! String
                myTrips = object!["myTrips"] as! [String]
                favoriteTrips = object!["favoriteTrips"] as! [String]
                
                // Get info about this trip
                let query2 = PFQuery(className: "Trip")
                query2.whereKey("user", equalTo: (PFUser.current()?.username)!)
                query2.whereKey("tripName", equalTo: currentTrip)
                query2.getFirstObjectInBackground(block: { (object, error) in
                    if error != nil {
                        print(error)
                    } else {
                        tripArray = object!["places"] as! [String : PFGeoPoint]
                        placesArray = object!["placesArray"] as! [String]
                        savedLocations = object!["savedPlaces"] as! [String : PFGeoPoint]
                        savedArray = object!["savedPlacesArray"] as! [String]
                        
                        self.performSegue(withIdentifier: "login", sender: self)
                    }
                })
                
            }
        })
        // Set expenses Info in expenseArr
        let query3 = PFQuery(className:"Expense")
        query3.whereKey("users", equalTo:(PFUser.current()?.username)!)
        query3.findObjectsInBackground { (objects, error) in
            if error == nil {
                // The find succeeded.
                // Do something with the found objects
                if let objects = objects {
                    for object in objects {
                        let exp = Expense()
                        exp.name = object["name"] as! String
                        exp.users = object["users"] as! [String]
                        exp.whoOwesWho = object["whoOwesWho"] as! [[Double]]
                        exp.trackExpenses = object["trackExpenses"] as! [[AnyObject]]
                        exp.objID = object.objectId!
                        expenseArr.append(exp)
                    }
                }
                
            } else {
                // Log details of the failure
            }
        }

    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
