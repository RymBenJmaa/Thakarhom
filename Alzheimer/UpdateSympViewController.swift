//
//  UpdateSympViewController.swift
//  Alzheimer
//
//  Created by ESPRIT on 14/12/2017.
//  Copyright © 2017 Esprit. All rights reserved.
//

import UIKit
import Alamofire
import EMAlertController
import StatusAlert

class UpdateSympViewController: UIViewController {
    @IBOutlet weak var savebtn: UIButton!
    @IBOutlet weak var desc: UITextView!
    var id: Int?
    var descr: String?
    var typ: String?
    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .lightContent
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        desc.layer.cornerRadius = 13
        desc.text = descr
        savebtn.layer.cornerRadius = 13
        // Do any additional setup after loading the view.
    }

   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func save(_ sender: Any) {
         if(Connectivity.isConnectedToInternet()){
        if(desc.text == ""){
            let statusAlert = StatusAlert.instantiate(withImage: UIImage(named: "cancel"),
                                                      title: "Symptom field empty",
                                                      message: "Please insert a new symptom or cancel")
            statusAlert.showInKeyWindow()
            
        }else{
        let alert = EMAlertController(title: "Are you sure?!", message: "Is this the new update?")
        let icon = UIImage(named: "question")
        
        
        let cancel = EMAlertAction(title: "CANCEL", style: .cancel)
        let confirm = EMAlertAction(title: "CONFIRM", style: .normal) {
        let x : Int = self.id!
        let parameters: [String: String] = [
            "id": String(x) as String! ,
            "description": self.desc.text as String! ,
            "type" : self.typ as String! ,
            ]
        Alamofire.request(SharedData.URL+"updatesymp", method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .responseJSON { response in
                print(response)
                let dict = response.result.value as? Dictionary<String,AnyObject>
                let suc=dict?["success"] as? Int

                if(suc == 1)
                {

                   
                    let statusAlert = StatusAlert.instantiate(withImage: UIImage(named: "success"),
                                                              title: "Success",
                                                              message: "The symptom is updated with success")
                    
                    // Presenting created instance
                    statusAlert.showInKeyWindow()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "nav")
                        self.show(controller, sender: true)
                    }
                    
                }else
                {
                    let statusAlert = StatusAlert.instantiate(withImage: UIImage(named: "cancel"),
                                                              title: "Update failed",
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
