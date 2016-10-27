//
//  ViewControllerMyTripsTableViewController.swift
//  Tryp
//
//  Created by Chris Fetterolf on 10/8/16.
//  Copyright © 2016 DeepHause. All rights reserved.
//

import UIKit
import Parse

class ViewControllerMyTrips: UITableViewController {

    func displayAlert(_ title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func ext(_ sender: AnyObject) {
        if myTrips.count == 0 {
            displayAlert("Add a New Trip First!", message: "")
        } else if currentTrip == "" {
            displayAlert("Select a Trip First!", message: "")
        } else {
            //dismissViewControllerAnimated(true, completion: nil)
            performSegue(withIdentifier: "exit", sender: self)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        let rightAddButtonItem:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(ViewControllerMyTrips.addItem))
        self.navigationItem.setRightBarButtonItems([editButtonItem,rightAddButtonItem], animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return myTrips.count
    }
 
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        // Configure the cell...
        let row = (indexPath as NSIndexPath).row
        cell.textLabel?.text = myTrips[row]

        if myTrips[row] == currentTrip {
            var imageView : UIImageView
            imageView  = UIImageView(frame:CGRect(x: 20, y: 20, width: 30, height: 30))
            imageView.image = UIImage(named: "van_icon3x.png")
            cell.accessoryView = imageView
        } else if favoriteTrips.contains(myTrips[(indexPath as NSIndexPath).row]) {
            var imageView : UIImageView
            imageView  = UIImageView(frame:CGRect(x: 20, y: 20, width: 20, height: 20))
            imageView.image = UIImage(named:"heart.png")
            // then set it as cellAccessoryType
            cell.accessoryView = imageView
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let alertController = UIAlertController(title: "\(myTrips[(indexPath as NSIndexPath).row])", message: "", preferredStyle: UIAlertControllerStyle.actionSheet)
        let action1 = UIAlertAction(title: "Make Current Trip", style: UIAlertActionStyle.default, handler: {(alert :UIAlertAction!) in
            
            //Make current trip 1st index
            currentTrip = myTrips[(indexPath as NSIndexPath).row]
            myTrips.remove(at: (indexPath as NSIndexPath).row)
            myTrips.insert(currentTrip, at: 0)
            
            // Set Trip Info
            let user = PFUser.current()
            user!["currentTripString"] = currentTrip
            user!["myTrips"] = myTrips
            user?.saveInBackground()
            
            let query2 = PFQuery(className: "Trip")
            query2.whereKey("user", equalTo: (PFUser.current()?.username)!)
            query2.whereKey("tripName", equalTo: currentTrip)
            query2.getFirstObjectInBackground(block: { (object, error) in
                if error != nil {
                    print(error)
                } else {
                    tripArray = object!["places"] as! [String : PFGeoPoint]
                    savedLocations = object!["savedPlaces"] as! [String : PFGeoPoint]
                    placesArray = object!["placesArray"] as! [String]
                    savedArray = object!["savedPlacesArray"] as! [String]
                }
            })
            // Make cell have van icon
            let cell:UITableViewCell = tableView.cellForRow(at: indexPath)!
            var imageViewVan : UIImageView
            imageViewVan  = UIImageView(frame:CGRect(x: 20, y: 20, width: 30, height: 30))
            imageViewVan.image = UIImage(named: "van_icon3x.png")
            cell.accessoryView = imageViewVan
            
            tableView.reloadData()
            
            var count = 0
            for cell in tableView.visibleCells {
                if cell.accessoryView == imageViewVan {
                    if favoriteTrips.contains(myTrips[count]) {
                        var imageView2 : UIImageView
                        imageView2  = UIImageView(frame:CGRect(x: 20, y: 20, width: 20, height: 20))
                        imageView2.image = UIImage(named:"heart.png")
                        cell.accessoryView = imageView2
                    } else {
                        cell.accessoryView = nil
                    }
                }
                count += 1
            }
        

            
        })
        alertController.addAction(action1)
        
        let faveAction = UIAlertAction(title: "Add to Favorites", style: UIAlertActionStyle.default, handler: {(alert :UIAlertAction!) in
            
            if favoriteTrips.contains(myTrips[(indexPath as NSIndexPath).row]) != true {
                //Add Trip to favorites
                favoriteTrips.append(myTrips[(indexPath as NSIndexPath).row])
                let user = PFUser.current()
                user!["favoriteTrips"] = favoriteTrips
                user!.saveInBackground()
                
                if myTrips[(indexPath as NSIndexPath).row] != currentTrip {
                    let cell:UITableViewCell = tableView.cellForRow(at: indexPath)!
                    var imageView : UIImageView
                    imageView  = UIImageView(frame:CGRect(x: 20, y: 20, width: 20, height: 20))
                    imageView.image = UIImage(named:"heart.png")
                    cell.accessoryView = imageView
                }
                
                //cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            } else {
                self.displayAlert("Error", message: "\(myTrips[(indexPath as NSIndexPath).row]) already in Favorites")
            }
            
            
        })
        alertController.addAction(faveAction)
        
        let removeAction = UIAlertAction(title: "Remove from Favorites", style: UIAlertActionStyle.destructive, handler: {(alert :UIAlertAction!) in
            
            if favoriteTrips.contains(myTrips[(indexPath as NSIndexPath).row]) {
                //Remove Trip from favorites
                favoriteTrips.remove(at: favoriteTrips.index(of: myTrips[(indexPath as NSIndexPath).row])!)
                let user = PFUser.current()
                user!["favoriteTrips"] = favoriteTrips
                user!.saveInBackground()
                
                let cell:UITableViewCell = tableView.cellForRow(at: indexPath)!
                
                if myTrips[(indexPath as NSIndexPath).row] == currentTrip {
                    var imageView : UIImageView
                    imageView  = UIImageView(frame:CGRect(x: 20, y: 20, width: 30, height: 30))
                    imageView.image = UIImage(named: "van_icon3x.png")
                    cell.accessoryView = imageView
                    cell.accessoryView = imageView
                } else {
                    cell.accessoryView = nil
                }
                //cell.accessoryType = UITableViewCellAccessoryType.None
            } else {
                self.displayAlert("Error", message: "\(myTrips[(indexPath as NSIndexPath).row]) not in Favorites")
            }
            
        })
        alertController.addAction(removeAction)
        
        let cancelAction = UIAlertAction(title: "Back", style: UIAlertActionStyle.cancel, handler: {(alert :UIAlertAction!) in
            // Dismiss View
        })
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
        
        
    }
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            if myTrips.count == 0 {
                currentTrip = ""
            } else if myTrips[(indexPath as NSIndexPath).row] == currentTrip {
                // If deleting current Trip, set current Trip to start of array
                currentTrip = ""
            }
            myTrips.remove(at: (indexPath as NSIndexPath).row)
            
            // Update current trip in User class
            let user = PFUser.current()!
            user["myTrips"] = myTrips
            user["currentTripString"] = currentTrip
            user.saveInBackground(block: { (success, error) in
                if (success) {
                    // The object has been saved.
                } else {
                    // There was a problem, check error.description
                    print(error)
                }
            })
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    func addItem() {
        performSegue(withIdentifier: "addItem", sender: self)
    }

    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to toIndexPath: IndexPath) {
        let tripItem = myTrips[(fromIndexPath as NSIndexPath).row]
        myTrips.remove(at: (fromIndexPath as NSIndexPath).row)
        myTrips.insert(tripItem, at: (toIndexPath as NSIndexPath).row)
        let user = PFUser.current()
        user!["myTrips"] = myTrips
        user?.saveInBackground()
    }
    

    
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
