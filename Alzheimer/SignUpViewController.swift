//
//  SignUpViewController.swift
//  Alzheimer
//
//  Created by Rym Ben Jmaa on 11/29/17.
//  Copyright © 2017 Esprit. All rights reserved.
//

import UIKit
import Alamofire
import Toast_Swift
import CoreData
import StatusAlert
class SignUpViewController: UIViewController {
  var user:[NSManagedObject] = []
     let color = UIColor.white
    @IBOutlet weak var username: UITextField!
   
    @IBOutlet weak var Email: UITextField!

    @IBOutlet weak var signup: UIButton!
    
    @IBOutlet weak var password: UITextField!

    @IBOutlet weak var confirm_pwd: UITextField!
   
    @IBOutlet weak var alzMail: UITextField!
    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .lightContent
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        signup.layer.cornerRadius = 13
        username.attributedPlaceholder = NSAttributedString(string: username.placeholder!, attributes: [NSAttributedStringKey.foregroundColor : color])
        Email.attributedPlaceholder = NSAttributedString(string: Email.placeholder!, attributes: [NSAttributedStringKey.foregroundColor : color])
        password.attributedPlaceholder = NSAttributedString(string: password.placeholder!, attributes: [NSAttributedStringKey.foregroundColor : color])
        confirm_pwd.attributedPlaceholder = NSAttributedString(string: confirm_pwd.placeholder!, attributes: [NSAttributedStringKey.foregroundColor : color])
        alzMail.attributedPlaceholder = NSAttributedString(string: alzMail.placeholder!, attributes: [NSAttributedStringKey.foregroundColor : color])
        
    }

    @IBAction func SignUp(_ sender: Any) {
         if(Connectivity.isConnectedToInternet()){
        if(Email.text == ""){
            let statusAlert = StatusAlert.instantiate(withImage: UIImage(named: "cancel"),
                                                      title: "Email address missing",
                                                      message: "Please insert a correct email address")
            statusAlert.showInKeyWindow()
        }else if(password.text == ""){
            let statusAlert = StatusAlert.instantiate(withImage: UIImage(named: "cancel"),
                                                      title: "Password missing",
                                                      message: "Please insert your password")
            statusAlert.showInKeyWindow()
        }
        else if((password.text?.count)! < 6){
            let statusAlert = StatusAlert.instantiate(withImage: UIImage(named: "cancel"),
                                                      title: "Password must contain at least 6 characters",
                                                      message: "Please insert a correct password")
            statusAlert.showInKeyWindow()
        }else if(confirm_pwd.text == ""){
            let statusAlert = StatusAlert.instantiate(withImage: UIImage(named: "cancel"),
                                                      title: "Password confirmation missing",
                                                      message: "Please insert your password confirmation")
            statusAlert.showInKeyWindow()
        }else if(password.text != confirm_pwd.text){
            let statusAlert = StatusAlert.instantiate(withImage: UIImage(named: "cancel"),
                                                      title: "Password confirmation doesn't match",
                                                      message: "Please check your password and its confirmation")
            statusAlert.showInKeyWindow()
        }else if(alzMail.text == "" ){
            let statusAlert = StatusAlert.instantiate(withImage: UIImage(named: "cancel"),
                                                      title: "Patient email address missing",
                                                      message: "Please insert the email address of the patient")
            statusAlert.showInKeyWindow()
        }else{
        
        let parameters: [String: String] = [
            "username": username.text as String! ,
            "email": Email.text as String! ,
            "alzmail": alzMail.text as String! ,
            "password" : password.text as String!,
            "password_confirmation" : confirm_pwd.text as String!,
            "role": "assistant",
            ]
        Alamofire.request(SharedData.URL+"register", method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .responseJSON { response in
                print(response)
                let dict = response.result.value as? Dictionary<String,AnyObject>
                //let data = dict?["data"] as? Dictionary<String,AnyObject>
                let suc=dict?["success"] as? Int
                let token = dict?["token"] as? String
                // print(token)
                if(suc == 1)
                {
                    self.resetAllRecords(in: "Connected_user")
                    SharedData.email = self.Email.text as String!
                    SharedData.is_Connected = true
                    SharedData.AlzMail = self.alzMail.text as String!
                    SharedData.Token = token!
                   // self.openViewControllerBasedOnIdentifier("Home")
                    guard let appDelegate =
                        UIApplication.shared.delegate as? AppDelegate else {
                            return
                    }
                    
                    // 1
                    let managedContext =
                        appDelegate.persistentContainer.viewContext
                    
                    // 2
                    let entity =
                        NSEntityDescription.entity(forEntityName: "Connected_user",
                                                   in: managedContext)!
                    
                    let person = NSManagedObject(entity: entity,
                                                 insertInto: managedContext)
                    
                    // 3
                    person.setValue(self.Email.text , forKeyPath: "email")
                    person.setValue(SharedData.AlzMail,forKeyPath :"malade")
                    person.setValue(SharedData.role , forKeyPath : "role")
                    person.setValue(self.password.text, forKeyPath: "pwd")
                    // 4
                    do {
                        try managedContext.save()
                        self.user.append(person)
                    } catch let error as NSError {
                        print("Could not save to CoreData. \(error), \(error.userInfo)")
                    }
                    let msg = "Welcome "+self.username.text! as String!
                    let statusAlert = StatusAlert.instantiate(withImage: UIImage(named: "like-1"),
                                                              title: "Success",
                                                              message: msg)
                    
                    // Presenting created instance
                    statusAlert.showInKeyWindow()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.1) {
                        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "nav")
                        self.show(controller, sender: true)
                    }

                    
                }
            }
        }
         }else{
            let statusAlert = StatusAlert.instantiate(withImage: UIImage(named: "warning"),
                                                      title: "You are off line",
                                                      message: "Please connect to a network")
            statusAlert.showInKeyWindow()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.1) {
                UIApplication.shared.open(URL(string: "App-Prefs:root=WIFI")!, options: [:], completionHandler: nil)
            }
        }
    }
        

    func resetAllRecords(in entity : String) // entity = Your_Entity_Name
    {
        
        let context = ( UIApplication.shared.delegate as! AppDelegate ).persistentContainer.viewContext
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        do
        {
            try context.execute(deleteRequest)
            try context.save()
        }
        catch
        {
            print ("There was an error")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
