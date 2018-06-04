//
//  AdviseViewController.swift
//  Alzheimer
//
//  Created by Rym Ben Jmaa on 11/30/17.
//  Copyright © 2017 Esprit. All rights reserved.
//

import UIKit
import Alamofire
import StatusAlert
import CoreData
class AdviseViewController: UIViewController {

    @IBOutlet weak var advise: UILabel!
     var ad:[NSManagedObject] = []
    @IBOutlet weak var add: UIButton!
    @IBOutlet weak var doctor: UILabel!
    
    @IBOutlet weak var connect: UIButton!
    override func viewWillAppear(_ animated: Bool) {
         UIApplication.shared.statusBarStyle = .lightContent
        
        if(!Connectivity.isConnectedToInternet()){
            
            let statusAlert = StatusAlert.instantiate(withImage: UIImage(named: "warning"),
                                                      title: "You are off line",
                                                      message: "Please connect to a network to be updated")
            statusAlert.showInKeyWindow()
            //1
            guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
                    return
            }
            
            let managedContext =
                appDelegate.persistentContainer.viewContext
            
            //2
            let fetchRequest =
                NSFetchRequest<NSManagedObject>(entityName: "Advice")
            //3
            do {
                ad = try managedContext.fetch(fetchRequest)
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            let adv = ad[0]
            self.advise.text = adv.value(forKeyPath: "descrip") as? String
            self.doctor.text = adv.value(forKeyPath: "auteur") as? String
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
    }
    override func viewDidLoad() {
         super.viewDidLoad()
        if (SharedData.is_Connected)
        {
            connect.setImage(UIImage(named: "logout1"), for: .normal)
        }
        if (SharedData.role == "medecin"){
            add.isHidden = false
        }
        if(Connectivity.isConnectedToInternet()){
       
       
        Alamofire.request(SharedData.URL+"getadvice", method:.get).responseJSON{response in
            
            if(response.result.isSuccess)
            {
               

                let dict = response.result.value as? Dictionary<String,AnyObject>
                let groups = dict?["data"] as? Dictionary<String,AnyObject>
            
                self.doctor.text = groups!["prenom"] as! String+" "+(groups!["nom"] as! String)
               
                self.advise.text = "“ "+(groups!["conseil"] as! String)+" ”"
                
                self.resetAllRecords(in: "Advice")
                guard let appDelegate =
                    UIApplication.shared.delegate as? AppDelegate else {
                        return
                }
                // 1
                let managedContext =
                    appDelegate.persistentContainer.viewContext
                
                // 2
                let entity =
                    NSEntityDescription.entity(forEntityName: "Advice",
                                               in: managedContext)!
                
                let adv = NSManagedObject(entity: entity,
                                          insertInto: managedContext)
                
                // 3
                adv.setValue(self.advise.text! , forKeyPath: "descrip")
                adv.setValue(self.doctor.text!, forKey: "auteur")
                // 4
                do {
                    try managedContext.save()
                    self.ad.append(adv)
                } catch let error as NSError {
                    print("Could not save to CoreData. \(error), \(error.userInfo)")
                }
                
            }
                
            else if(response.result.isFailure){
                print("no advise!!")
            }
            // Do any additional setup after loading the view.
            }
        }else{
            
            //1
            guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
                    return
            }
            
            let managedContext =
                appDelegate.persistentContainer.viewContext
            
            //2
            let fetchRequest =
                NSFetchRequest<NSManagedObject>(entityName: "Advice")
            //3
            do {
                ad = try managedContext.fetch(fetchRequest)
                let adv = ad[0]
                
                self.advise.text = adv.value(forKeyPath: "descrip") as? String
                self.doctor.text = adv.value(forKeyPath: "auteur") as? String
            } catch let error as NSError {
                
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            
            let statusAlert = StatusAlert.instantiate(withImage: UIImage(named: "warning"),
                                                      title: "You are off line",
                                                      message: "Please connect to a network to be updated")
            statusAlert.showInKeyWindow()
        }
        // Do any additional setup after loading the view.
    }
    @IBAction func Disconnect(_ sender: Any) {
         if(Connectivity.isConnectedToInternet()){
        if (SharedData.is_Connected)
        {print(SharedData.Token)
            let urlPath = URL(string: SharedData.URL+"disconnect?token="+SharedData.Token)
            Alamofire.request(urlPath!,method:.get ).responseJSON { responsep in
                if(responsep.result.isSuccess){
                    
                    
                    SharedData.is_Connected = false
                    SharedData.AlzMail = ""
                    SharedData.email = ""
                    SharedData.role = ""
                    SharedData.Token = ""
                    self.connect.setImage(UIImage(named: "user1"), for: .normal)
                    let statusAlert = StatusAlert.instantiate(withImage: UIImage(named: "broken-heart"),
                                                              title: "Sorry to see you go",
                                                              message: "Come back soon")
                    
                    statusAlert.showInKeyWindow()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "nav")
                        self.show(controller, sender: true)
                    }
                }else if(responsep.result.isFailure){
                    let statusAlert = StatusAlert.instantiate(withImage: UIImage(named: "cancel"),
                                                              title: "Oups",
                                                              message: "Something went wrong")
                    
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
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
