//
//  editTripTVC.swift
//  Tryp
//
//  Created by Chris Fetterolf on 10/24/16.
//  Copyright © 2016 DeepHause. All rights reserved.
//

import UIKit
import Parse

class editTripTVC: UITableViewController {

    @IBAction func back(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem
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
        return tripArray.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String {
        return "\(currentTrip)"
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let title = UILabel()
        
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor=title.textColor
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        // Configure the cell...
        
        let row = (indexPath as NSIndexPath).row
        cell.textLabel?.text = placesArray[row]

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            // Delete the row from the data source
            tripArray.removeValue(forKey: placesArray[(indexPath as NSIndexPath).row])
            placesArray.remove(at: (indexPath as NSIndexPath).row)
            
            // Update Parse in Background
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

            
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to toIndexPath: IndexPath) {

        let placeToMove = placesArray[(fromIndexPath as NSIndexPath).row]
        placesArray.remove(at: (fromIndexPath as NSIndexPath).row)
        placesArray.insert(placeToMove, at: (toIndexPath as NSIndexPath).row)
        
        // Update Parse
        let query = PFQuery(className: "Trip")
        query.whereKey("user", equalTo:(PFUser.current()?.username)!)
        query.whereKey("tripName", equalTo: currentTrip)
        query.findObjectsInBackground { (objects, error) in
            if error != nil {
                print(error)
            } else {
                for object in objects! {
                    object["placesArray"] = placesArray
                    object.saveInBackground()
                }
            }
        }
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
