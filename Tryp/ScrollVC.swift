//
//  ScrollVC.swift
//  Tryp
//
//  Created by Chris Fetterolf on 10/20/16.
//  Copyright © 2016 DeepHause. All rights reserved.
//

import UIKit

class ScrollVC: UIViewController, UITableViewDelegate {

    @IBOutlet var totalSpent: UILabel!
    @IBOutlet var goToExpenses: UIButton!
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.layer.cornerRadius = 10
        tableView.layer.masksToBounds = true
        
    }
    @IBAction func goToExp(_ sender: AnyObject) {
        indx = 2
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
        totalSpent.text = "$\(formatted)"
        
        goToExpenses.titleLabel?.lineBreakMode = .byWordWrapping
        goToExpenses.titleLabel?.textAlignment = .center

    }

    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expenseArr.count
    }

    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = expenseArr[(indexPath as NSIndexPath).row].name
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
