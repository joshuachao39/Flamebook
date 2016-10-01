//
//  StatusTableViewController.swift
//  FlameBook
//
//  Created by Joshua Chao on 9/23/16.
//  Copyright © 2016 Joshua Chao. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class StatusTableViewController: UITableViewController {
    
    var dbRef:FIRDatabaseReference!
    
    var userEmail: String?
    
    var statuses = [Status]()
    
    @IBAction func loginAndSignUp(_ sender: AnyObject) {
        let userAlert = UIAlertController(title: "Log in or sign up!", message: "Enter your username and password!", preferredStyle: .alert)
        userAlert.addTextField { (textfield: UITextField) in
            textfield.placeholder = "email"
        }
        userAlert.addTextField { (textfield: UITextField) in
            textfield.isSecureTextEntry = true
            textfield.placeholder = "password"
        }
        
        userAlert.addAction(UIAlertAction(title: "Sign in", style: .default, handler: { (action: UIAlertAction) in
            let emailTextField = userAlert.textFields!.first!
            let passwordTextField = userAlert.textFields!.last!
            
            self.userEmail = emailTextField.text!
            
            FIRAuth.auth()?.signIn(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: { (user: FIRUser?, error: Error?) in
                if error != nil {
                    print(error?.localizedDescription)
                }
            })
        }))
        
        userAlert.addAction(UIAlertAction(title: "Sign up", style: .default, handler: { (action: UIAlertAction) in
            let emailTextField = userAlert.textFields!.first!
            let passwordTextField = userAlert.textFields!.last!
            
            self.userEmail = emailTextField.text!
            
            FIRAuth.auth()?.createUser(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: { (user:FIRUser?, error: Error?) in
                if error != nil {
                    print(error?.localizedDescription)
                }
            })

        }))
        
        self.present(userAlert, animated: true, completion: nil)
        
    }

    @IBAction func addStatus(_ sender: AnyObject) {
        let statusAlert = UIAlertController(title: "Status Update", message: "Post your status update", preferredStyle: .alert)
        
        statusAlert.addTextField { (textfield:UITextField) in
            textfield.placeholder = "Your status update"
        }
        
        statusAlert.addAction(UIAlertAction(title: "Send", style: .default, handler: { (action: UIAlertAction) in
            if let statusContent = statusAlert.textFields?.first?.text {
                let status = Status(content: statusContent, addedByUser: self.userEmail!)
                
                let statusRef = self.dbRef.child(statusContent.localizedLowercase)
                
                statusRef.setValue(status.toAnyObject())
            }
            
        }))
        
        self.present(statusAlert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200
        
        dbRef = FIRDatabase.database().reference().child("status-items")
        startObservingDB()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        FIRAuth.auth()?.addStateDidChangeListener({ (auth: FIRAuth, user: FIRUser?) in
            if let user = user {
                print ("Welcome \(user.email!)")
                self.userEmail = user.email!
                
                self.startObservingDB()
            } else {
                print ("You need to sign up first!")
            }
        })
    }
    
    func startObservingDB() {
        dbRef.observe(.value, with: { (snapshot:FIRDataSnapshot) in
            var newStatuses = [Status]()
            
            for status in snapshot.children {
                let statusObject = Status(snapshot: status as! FIRDataSnapshot)
                newStatuses.append(statusObject)
            }
            
            self.statuses = newStatuses
            self.tableView.reloadSections(NSIndexSet(index: 0) as IndexSet , with: .automatic)
            
            
        }) { (error:Error) in
            print(error.localizedDescription)
        }
    }

        // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return statuses.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        // Configure the cell...
        
        let status = statuses[indexPath.row]
        
        if let contentLabel = cell.viewWithTag(1000) as? UILabel {
            contentLabel.text = status.content
        }
        
        if let userLabel = cell.viewWithTag(4000) as? UILabel {
            userLabel.text = status.addedByUser
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var status = statuses[indexPath.row]
        
        let statusRef = self.dbRef.child(status.content.localizedLowercase)
        
        statusRef.setValue(status.toAnyObject())
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let status = statuses[indexPath.row]
            
            status.itemRef?.removeValue()
        }
    }


}
