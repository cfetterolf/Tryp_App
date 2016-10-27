//
//  addCostViewController.swift
//  Tryp
//
//  Created by Chris Fetterolf on 10/18/16.
//  Copyright © 2016 DeepHause. All rights reserved.
//

import UIKit
import Parse

class addCostViewController: UIViewController {

    @IBOutlet var costName: UITextField!
    
    @IBOutlet var costAmount: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        costAmount.keyboardType = UIKeyboardType.DecimalPad
        let rightAddButtonItem:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.save, target: self, action: #selector(addCostViewController.saveItem))
        self.navigationItem.setRightBarButton(rightAddButtonItem, animated: true)
        self.navigationItem.title  = "Add Cost"
        
        // Do any additional setup after loading the view.
    }
    
    func saveItem() {
        
        if self.costName.text == "" || self.costAmount.text == "" {
            displayAlert("Error", message: "Enter a description and an amount.")
        } else {
            
            let amount = Double(self.costAmount.text!)!
            
            // Internally update Expense's trackExpenses
            var tempArr = [AnyObject]()
            tempArr.append(self.costName.text! as AnyObject)
            tempArr.append(amount as AnyObject)
            expenseArr[currentSection].trackExpenses.append(tempArr)
            
            // Update WhoOwesWho
            let divis = amount/(Double(expenseArr[currentSection].users.count))
            let userIndex = expenseArr[currentSection].users.index(of: (PFUser.current()?.username)!)
            for i in 0...(expenseArr[currentSection].whoOwesWho.count-1) {
                if i != userIndex {
                    expenseArr[currentSection].whoOwesWho[userIndex!][i] += divis
                }
            }
            
            // Update in Parse
            let query = PFQuery(className: "Expense")
            query.getObjectInBackground(withId: expenseArr[currentSection].objID) {
                (object: PFObject?, error: Error?) -> Void in
                if error == nil && object != nil {
                    // Success
                    object!["trackExpenses"] = expenseArr[currentSection].trackExpenses
                    object!["whoOwesWho"] = expenseArr[currentSection].whoOwesWho
                    object!.saveInBackground(block: { (success, error) in
                        if (success) {
                            // The object has been saved.
                        } else {
                            // There was a problem, check error.description
                        }
                        
                    })
                } else {
                    print(error)
                }
            }
            performSegueWithIdentifier("itemSaved", sender: self)
        }
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    func displayAlert(_ title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
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
