//
//  SignInViewController.swift
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

class SignInViewController: UIViewController {
    let color = UIColor.white
    var user:[NSManagedObject] = []
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var login: UIButton!
    @IBOutlet weak var email: UITextField!
    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .lightContent
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        email.attributedPlaceholder = NSAttributedString(string: email.placeholder!, attributes: [NSAttributedStringKey.foregroundColor : color])
        password.attributedPlaceholder = NSAttributedString(string: password.placeholder!, attributes: [NSAttributedStringKey.foregroundColor : color])
        login.layer.cornerRadius = 13

        //1
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Connected_user")
        //3
        do {
            user = try managedContext.fetch(fetchRequest)
            if(user.count != 0) {
            let u = user[0]
            email.text = u.value(forKey: "email") as? String
            password.text = u.value(forKey: "pwd") as? String
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
      
       
    }

    @IBAction func Login(_ sender: Any) {
         if(Connectivity.isConnectedToInternet()){
        if(email.text == ""){
            let statusAlert = StatusAlert.instantiate(withImage: UIImage(named: "cancel"),
                                                      title: "Email missing",
                                                      message: "Please insert a correct email address")
            statusAlert.showInKeyWindow()
        }else if(password.text == ""){
            let statusAlert = StatusAlert.instantiate(withImage: UIImage(named: "cancel"),
                                                      title: "Password missing",
                                                      message: "Please insert your password")
            statusAlert.showInKeyWindow()
        }else{
        let parameters: [String: String] = [
            "email": email.text as String! ,
            "password" : password.text as String! ,
            ]
        Alamofire.request(SharedData.URL+"login", method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .responseJSON { response in
                print(response)
                let dict = response.result.value as? Dictionary<String,AnyObject>
                let data = dict?["data"] as? Dictionary<String,AnyObject>
                let suc=dict?["success"] as? Int
                let AlzMail = data?["alzmail"] as? Dictionary<String,AnyObject>
                let role = data?["role"] as? Dictionary<String,AnyObject>
                let token = data?["token"] as? String
                
                if(suc == 1)
                {
                    
                    SharedData.AlzMail = (AlzMail?["alzmail"] as? String!)!
                    SharedData.role = (role?["role"] as? String!)!
                    SharedData.email = self.email.text as String!
                    SharedData.Token = token!
                    SharedData.is_Connected = true
                    self.resetAllRecords(in: "Connected_user")
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
                    person.setValue(self.email.text , forKeyPath: "email")
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
                    
                    let statusAlert = StatusAlert.instantiate(withImage: UIImage(named: "like-1"),
                                                              title: "Success",
                                                              message: "Welcome back")
                    
                    // Presenting created instance
                    statusAlert.showInKeyWindow()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.1) {
                        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "nav")
                        self.show(controller, sender: true)
                    }
    
                }else
                {
                    let statusAlert = StatusAlert.instantiate(withImage: UIImage(named: "cancel"),
                                                              title: "Login failed",
                                                              message: "Check your email/password")
                    //self.view.makeToast("Login failed check your email/password", duration: 3.0, position: .bottom)
                     statusAlert.showInKeyWindow()
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
    func openViewControllerBasedOnIdentifier(_ strIdentifier:String){
        let destViewController : UIViewController = self.storyboard!.instantiateViewController(withIdentifier: strIdentifier)
        
        let topViewController : UIViewController = self.navigationController!.topViewController!
        
        if (topViewController.restorationIdentifier! == destViewController.restorationIdentifier!){
            print("Same ID")
        } else {
            self.navigationController!.pushViewController(destViewController, animated: true)
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
}
