//
//  summaryVC.swift
//  Tryp
//
//  Created by Chris Fetterolf on 10/19/16.
//  Copyright © 2016 DeepHause. All rights reserved.
//

import UIKit
import Parse

class summaryVC: UIViewController {

    let exp = expenseArr[currentSection]
    let totalExp = 0
    
    
    @IBOutlet var expenseTitle: UILabel!
    @IBOutlet var user1: UILabel!
    @IBOutlet var user2: UILabel!
    @IBOutlet var user3: UILabel!
    @IBOutlet var user4: UILabel!
    @IBOutlet var user5: UILabel!
    @IBOutlet var user6: UILabel!
    @IBOutlet var total: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        expenseTitle.text = exp.name
        user1.text = ""
        user2.text = ""
        user3.text = ""
        user4.text = ""
        user5.text = ""
        user6.text = ""
        
        
        var tempUsers = exp.users
        tempUsers.remove(at: exp.users.index(of: (PFUser.current()?.username)!)!)
        
        if tempUsers.count == 0 {
            user1.text = "Just you"
        } else if tempUsers.count == 1 {
            user1.text = tempUsers[0]
        } else if tempUsers.count == 2 {
            user1.text = tempUsers[0]
            user2.text = tempUsers[1]
        } else if tempUsers.count == 3 {
            user1.text = tempUsers[0]
            user2.text = tempUsers[1]
            user3.text = tempUsers[2]
        } else if tempUsers.count == 4 {
            user1.text = tempUsers[0]
            user2.text = tempUsers[1]
            user3.text = tempUsers[2]
            user4.text = tempUsers[3]
        } else if tempUsers.count == 5 {
            user1.text = tempUsers[0]
            user2.text = tempUsers[1]
            user3.text = tempUsers[2]
            user4.text = tempUsers[3]
            user5.text = tempUsers[4]
        } else if tempUsers.count == 6 {
            user1.text = tempUsers[0]
            user2.text = tempUsers[1]
            user3.text = tempUsers[2]
            user4.text = tempUsers[3]
            user5.text = tempUsers[4]
            user6.text = tempUsers[5]
        }

        var sum = 0.0
        
        if exp.users.count == 1 {
            for element in exp.trackExpenses {
                let num = element[1] as! Double
                sum = sum + num
            }
        } else {
            for i in 0...(exp.whoOwesWho.count-1) {
                for j in 0...(exp.whoOwesWho.count-1) {
                    if i != j {
                        sum += (exp.whoOwesWho[i][j] * Double(exp.whoOwesWho.count)) / Double(exp.users.count)
                        break
                    }
                }
            }
        }
        
        let formatted = String(format: "%.2f", sum)
        total.text = "$\(formatted)"


        // Do any additional setup after loading the view.
    }
    
    // MARK: - Config Table
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exp.users.count - 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        var tempUsers = exp.users
        tempUsers.remove(at: exp.users.index(of: (PFUser.current()?.username)!)!)
        
        let userIndex = exp.users.index(of: (PFUser.current()?.username)!)
        var sum = 0.0
        for i in 0...(exp.whoOwesWho.count-1) {
            
            if i != userIndex {
                let difference = exp.whoOwesWho[userIndex!][i] - exp.whoOwesWho[i][userIndex!]
                sum += difference
                break
            }
        }
        // If sum for each expense is POS, then you are owed that amount
        // If sum for each expense is NEG, then you owe others that amount
        
        
        if sum < 0 {
            sum *= -1
            let formatted = String(format: "%.2f", sum)
            cell.textLabel?.text = "You owe \(tempUsers[(indexPath as NSIndexPath).row]) $\(formatted)"
        } else {
            let formatted = String(format: "%.2f", sum)
            cell.textLabel?.text = "\(tempUsers[(indexPath as NSIndexPath).row]) owes you $\(formatted)"
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
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

}
