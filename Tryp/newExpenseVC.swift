//
//  newExpenseVC.swift
//  Tryp
//
//  Created by Chris Fetterolf on 10/18/16.
//  Copyright © 2016 DeepHause. All rights reserved.
//

import UIKit
import Parse


class newExpenseVC: UIViewController {

    @IBOutlet var user1: UITextField!
    @IBOutlet var user2: UITextField!
    @IBOutlet var user3: UITextField!
    @IBOutlet var user4: UITextField!
    @IBOutlet var user5: UITextField!
    @IBOutlet var user6: UITextField!
    
    @IBOutlet var expenseName: UITextField!
    
    @IBOutlet var sliderValue: UISlider!
    
    let step: Float = 1
    var roundedValue:Float = 0.0
    
    @IBAction func sliderMoved(_ sender: AnyObject) {
        roundedValue = round(sender.value / step) * step
        sliderValue.value = roundedValue
        displayUsers(roundedValue)
        
    }
    
    func displayUsers(_ value:Float) {
        if value == 0 {
            user1.isHidden = true
            user2.isHidden = true
            user3.isHidden = true
            user4.isHidden = true
            user5.isHidden = true
            user6.isHidden = true
        } else if value == 1 {
            user1.isHidden = false
            user2.isHidden = true
            user3.isHidden = true
            user4.isHidden = true
            user5.isHidden = true
            user6.isHidden = true
        } else if value == 2 {
            user1.isHidden = false
            user2.isHidden = false
            user3.isHidden = true
            user4.isHidden = true
            user5.isHidden = true
            user6.isHidden = true
        } else if value == 3 {
            user1.isHidden = false
            user2.isHidden = false
            user3.isHidden = false
            user4.isHidden = true
            user5.isHidden = true
            user6.isHidden = true
        } else if value == 4 {
            user1.isHidden = false
            user2.isHidden = false
            user3.isHidden = false
            user4.isHidden = false
            user5.isHidden = true
            user6.isHidden = true
        } else if value == 5 {
            user1.isHidden = false
            user2.isHidden = false
            user3.isHidden = false
            user4.isHidden = false
            user5.isHidden = false
            user6.isHidden = true
        } else { // Value is 6
            user1.isHidden = false
            user2.isHidden = false
            user3.isHidden = false
            user4.isHidden = false
            user5.isHidden = false
            user6.isHidden = false
        }
    }
    
    @IBAction func save(_ sender: AnyObject) {
        
        let name = expenseName.text
        
        if name == "" {
            displayAlert("Error", message: "Must include a name for the expense.")
        } else if (user1.isHidden == false && user1.text == "") || (user2.isHidden == false && user2.text == "") || (user3.isHidden == false && user3.text == "") || (user4.isHidden == false && user4.text == "") || (user5.isHidden == false && user5.text == "") || (user6.isHidden == false && user6.text == "") {
            
            displayAlert("Error", message: "Must provide usernames for all users included in the expense")
        } else {
            let users:[String] = getUsers()
            let whoOwesWho = Array(repeating: Array(repeating: 0.0, count: users.count), count: users.count)
            let trackExpenses = [[AnyObject]]()
            
            let exp = Expense()
            exp.name = name!
            exp.users = users
            exp.whoOwesWho = whoOwesWho
            exp.trackExpenses = trackExpenses
            expenseArr.append(exp)
            
            let expense = PFObject(className: "Expense")
            expense.acl?.getPublicReadAccess = true
            expense.acl?.getPublicWriteAccess = true
            //Save to Parse
            expense["users"] = users
            expense["name"] = name
            expense["trackExpenses"] = trackExpenses
            expense["whoOwesWho"] = whoOwesWho
            expense.saveInBackground(block: { (sucess, error) in
                if error != nil {
                    self.displayAlert("Error", message: (error?.localizedDescription)!)
                } else {
                    // Success
                    let ojId = expense.objectId
                    expenseArr.last?.objID = ojId!
                    print(expenseArr.last?.objID)
                }
            })
            
            // Get objID from Parse
            
            
            performSegue(withIdentifier: "backToExpenses", sender: self)
        }   
    }
    
    // Returns an array of users for the expense, as given by 
    // the slider and textFields
    func getUsers() -> [String] {
        
        var users = [String]()
        users.append((PFUser.current()?.username)!)
        
        if roundedValue == 0 {
            return users
        } else if roundedValue == 1 {
            users.append(user1.text!)
            return users
        } else if roundedValue == 2 {
            users.append(user1.text!)
            users.append(user2.text!)
            return users
        } else if roundedValue == 3 {
            users.append(user1.text!)
            users.append(user2.text!)
            users.append(user3.text!)
            return users
        } else if roundedValue == 4 {
            users.append(user1.text!)
            users.append(user2.text!)
            users.append(user3.text!)
            users.append(user4.text!)
            return users
        } else if roundedValue == 5 {
            users.append(user1.text!)
            users.append(user2.text!)
            users.append(user3.text!)
            users.append(user4.text!)
            users.append(user5.text!)
            return users
        } else { //roundedValue = 6
            users.append(user1.text!)
            users.append(user2.text!)
            users.append(user3.text!)
            users.append(user4.text!)
            users.append(user5.text!)
            users.append(user6.text!)
            return users
        }
    }
    
    @IBAction func cancel(_ sender: AnyObject) {
        performSegue(withIdentifier: "backToExpenses", sender: self)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        user1.isHidden = false
        user2.isHidden = false
        user3.isHidden = false
        user4.isHidden = true
        user5.isHidden = true
        user6.isHidden = true
        
        // Do any additional setup after loading the view.
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
