  //
//  ViewController.swift
//  Alzheimer
//
//  Created by Rym Ben Jmaa on 11/15/17.
//  Copyright © 2017 Esprit. All rights reserved.
//

import UIKit
import Alamofire
class ViewController: UIViewController {
    
    @IBOutlet weak var connect: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
     //   UINavigationBar.title
        if (SharedData.is_Connected)
        {
            connect.image = UIImage(named: "logout")

        }
   
}

    @IBAction func disconnect(_ sender: Any) {
        if (SharedData.is_Connected)
        {print(SharedData.Token)
            let urlPath = URL(string: SharedData.URL+"disconnect?token="+SharedData.Token)
            Alamofire.request(urlPath!,method:.get ).responseJSON { responsep in
                if(responsep.result.isSuccess){
             
                    let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "nav")
                    self.show(controller, sender: true)
                    SharedData.is_Connected = false
                    SharedData.AlzMail = ""
                    SharedData.email = ""
                    SharedData.role = ""
                    SharedData.Token = ""
                    self.connect.image = UIImage(named: "user")
                }else if(responsep.result.isFailure){
                    print("le le")
                    
                }
                
            }
        }else{
            let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignIn")
            self.present(controller, animated: true)
            
        }
    }
    

    @objc func myRightSideBarButtonItemTapped(_ sender:UIBarButtonItem!)
{
    print("myLeftSideBarButtonItemTapped")
}
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

