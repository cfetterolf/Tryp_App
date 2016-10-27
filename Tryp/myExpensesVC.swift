//
//  myExpensesVC.swift
//  Tryp
//
//  Created by Chris Fetterolf on 10/18/16.
//  Copyright © 2016 DeepHause. All rights reserved.
//

import UIKit
import Parse

var currentSection = 0

class myExpensesVC: UIViewController, UITableViewDelegate {

    @IBOutlet var totalCost: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let rightAddButtonItem:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(myExpensesVC.addItem))
        self.navigationItem.setRightBarButton(rightAddButtonItem, animated: true)
        // Do any additional setup after loading the view.
    }
    
    func addItem() {
        performSegue(withIdentifier: "addExpense", sender: self)
    }

    
    override func viewWillAppear(_ animated: Bool) {
        indx = 2
        
        // Compute Total Sum
        var sum = 0.0
        for exp in expenseArr {
            if exp.users.count == 1 {
                for element in exp.trackExpenses {
                    let num = element[1] as! Double
                    sum += num
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
        }
        let formatted = String(format: "%.2f", sum)
        totalCost.text = "$\(formatted)"
        
    }
    
    func computeTotalCost() {
        
        for exp in expenseArr {
            
            let userIndex = exp.users.index(of: (PFUser.current()?.username)!)
            var sum = 0.0
            for i in 0...(exp.whoOwesWho.count-1) {
                
                if i != userIndex {
                    let difference = exp.whoOwesWho[userIndex!][i] - exp.whoOwesWho[i][userIndex!]
                    sum += difference
                }
            }
            print("\(exp.name) - \(sum)")

        }
        
    }
    
    /* Is philosohpy combating reason?
     The two are distinct entities?  There must be two doctrines
 
 */

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Config Table
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return expenseArr.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expenseArr[section].trackExpenses.count + 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(expenseArr[section].name)"
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let title = UILabel()
        title.textColor = UIColor.white
        
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor=title.textColor
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        
        // If penultimate row of section
        if (indexPath as NSIndexPath).row  == expenseArr[(indexPath as NSIndexPath).section].trackExpenses.count {
            cell.textLabel?.text = "Add cost"
            cell.textLabel?.textColor = UIColor.lightGray
            cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            cell.textLabel?.textAlignment = .left
        } else if (indexPath as NSIndexPath).row == expenseArr[(indexPath as NSIndexPath).section].trackExpenses.count + 1 {
            // Last row of section
            cell.textLabel?.text = "Summary"
            cell.textLabel?.textColor = UIColor.init(hue: 0.57, saturation: 0.96, brightness: 1.0, alpha: 1.0)
            cell.textLabel?.textAlignment = .center
            cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        } else {
            // Config...
            cell.accessoryType = UITableViewCellAccessoryType.none
            let str1 = expenseArr[(indexPath as NSIndexPath).section].trackExpenses[(indexPath as NSIndexPath).row][0] as? String
            let str2 = expenseArr[(indexPath as NSIndexPath).section].trackExpenses[(indexPath as NSIndexPath).row][1] as? Double
            let formatted = String(format: "%.2f", str2!)
            cell.textLabel?.text = "$\(formatted) - \(str1!)"
            cell.textLabel?.textColor = UIColor.black
            cell.textLabel?.textAlignment = .left
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        
        // If penultimate row in Section selected, segue to Add Cost VC
        if (indexPath as NSIndexPath).row  == expenseArr[(indexPath as NSIndexPath).section].trackExpenses.count {
            currentSection = (indexPath as NSIndexPath).section
            performSegue(withIdentifier: "addCost", sender: self)
        } else if (indexPath as NSIndexPath).row == expenseArr[(indexPath as NSIndexPath).section].trackExpenses.count + 1 {
            // Last row of section
            currentSection = (indexPath as NSIndexPath).section
            performSegue(withIdentifier: "summary", sender: self)
        }
        
        
        
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
