//
//  AddAdviceViewController.swift
//  Alzheimer
//
//  Created by ESPRIT on 14/12/2017.
//  Copyright © 2017 Esprit. All rights reserved.
//

import UIKit
import Alamofire
import EMAlertController
import StatusAlert
class AddAdviceViewController: UIViewController {

    @IBOutlet weak var nom: UITextField!
    
    @IBOutlet weak var prenom: UITextField!
    let color = UIColor.white
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var addbtn: UIButton!
   
    @IBOutlet weak var conseil: UITextView!
    override func viewWillAppear(_ animated: Bool) {
        
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    @IBAction func Add(_ sender: Any) {
          if(Connectivity.isConnectedToInternet()){
        if(nom.text == ""){
            let statusAlert = StatusAlert.instantiate(withImage: UIImage(named: "cancel"),
                                                      title: "Last name missing",
                                                      message: "Please insert your last name")
            statusAlert.showInKeyWindow()
        }else if(prenom.text == ""){
            let statusAlert = StatusAlert.instantiate(withImage: UIImage(named: "cancel"),
                                                      title: "First name missing",
                                                      message: "Please insert your first name")
            statusAlert.showInKeyWindow()
        }else if(phone.text == ""){
            let statusAlert = StatusAlert.instantiate(withImage: UIImage(named: "cancel"),
                                                      title: "Phone number missing",
                                                      message: "Please insert your phone number")
            statusAlert.showInKeyWindow()
        }else if(conseil.text == ""){
            let statusAlert = StatusAlert.instantiate(withImage: UIImage(named: "cancel"),
                                                      title: "Advice missing",
                                                      message: "Please insert the advice you want to add")
            statusAlert.showInKeyWindow()
            
        }else if(Int(phone.text!) == nil){
            let statusAlert = StatusAlert.instantiate(withImage: UIImage(named: "cancel"),
                                                      title: "Wrong phone number",
                                                      message: "Please insert a valid phone number")
            statusAlert.showInKeyWindow()
        }
        
        else{
        
        let alert = EMAlertController(title: "Are you sure?!", message: "Is this the advice you want to add?")
        let icon = UIImage(named: "question")
        
        
        let cancel = EMAlertAction(title: "CANCEL", style: .cancel)
        let confirm = EMAlertAction(title: "CONFIRM", style: .normal) {
            let parameters: [String: String] = [
                "nom": self.nom.text as String! ,
                "prenom" : self.prenom.text as String! ,
                "email" : SharedData.email as String! ,
                "telephone" : self.phone.text as String! ,
                "conseil" : self.conseil.text as String! ,
                ]
            Alamofire.request(SharedData.URL+"addadvice", method: .post, parameters: parameters, encoding: JSONEncoding.default)
                .responseJSON { response in
                    print(response)
                    let dict = response.result.value as? Dictionary<String,AnyObject>
                    let suc=dict?["success"] as? Int
                    
                    if(suc == 1)
                    {
                        
                        
                        
                        
                        let statusAlert = StatusAlert.instantiate(withImage: UIImage(named: "success"),
                                                                  title: "Success",
                                                                  message: "Your advice is added with success")
                        
                        // Presenting created instance
                        statusAlert.showInKeyWindow()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                            let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "nav")
                            self.show(controller, sender: true)
                        }
                        
                        
                    }else
                    {
                        let statusAlert = StatusAlert.instantiate(withImage: UIImage(named: "cancel"),
                                                                  title: "Add failed",
                                                                  message: "Check your connection")
                        
                        statusAlert.showInKeyWindow()
                    }
            }
        }
        alert.iconImage = icon
        alert.addAction(action: cancel)
        alert.addAction(action: confirm)
        alert.cornerRadius = 10
        present(alert, animated: true, completion: nil)
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
    override func viewDidLoad() {
        super.viewDidLoad()
        conseil.placeholder = "What's today advice "
        
        nom.attributedPlaceholder = NSAttributedString(string: nom.placeholder!, attributes: [NSAttributedStringKey.foregroundColor : color])
        prenom.attributedPlaceholder = NSAttributedString(string: prenom.placeholder!, attributes: [NSAttributedStringKey.foregroundColor : color])
        phone.attributedPlaceholder = NSAttributedString(string: phone.placeholder!, attributes: [NSAttributedStringKey.foregroundColor : color])
        prenom.layer.cornerRadius = 13
        phone.layer.cornerRadius = 13
        nom.layer.cornerRadius = 13
        conseil.layer.cornerRadius = 13
        addbtn.layer.cornerRadius = 13
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
   
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}

