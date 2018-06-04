//
//  SymptomesVC.swift
//  Alzheimer
//
//  Created by Rym Ben Jmaa on 11/15/17.
//  Copyright © 2017 Esprit. All rights reserved.
//

import UIKit
import Alamofire
import DGElasticPullToRefresh
import StatusAlert
import CoreData
class SymptomesVC: UIViewController, UITableViewDataSource, UITableViewDelegate  {
var details: UpdateSympViewController?
    var array = [String]()
    var refreshControl: UIRefreshControl!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    var symptomes:[NSManagedObject] = []
    var feedItems = [Dictionary<String, AnyObject>]()
    var tipe = [String]()
     var arrayMenu = [Dictionary<String,String>]()
    @IBOutlet weak var tableView: UITableView!
  
   
    
 
    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .lightContent
        
       
        loader.startAnimating()
         if(Connectivity.isConnectedToInternet()){
            array.removeAll()
            tipe.removeAll()
            feedItems.removeAll()
        let urlPath = URL(string: SharedData.URL+"getsymp")
        
        Alamofire.request(urlPath!,method:.get).responseJSON { responsep in
            if(responsep.result.isSuccess){
                let dictp = responsep.result.value! as? Dictionary<String, AnyObject>
                let dictp1 = dictp?["data"] as? NSArray
                 self.resetAllRecords(in: "Symptomes")
                for symps in (dictp1! as NSArray) {
                    let symp = symps as? Dictionary<String, AnyObject>
                    let typ = symp!["type"] as! String?
                    
                    self.tipe.append(typ!)
                   
                    let id = symp!["id"] as! Int?
                    let x : Int = id!
                    self.array.append(String(x))
                    self.feedItems.append(symp!)
                   
                    guard let appDelegate =
                        UIApplication.shared.delegate as? AppDelegate else {
                            return
                    }
                    // 1
                    let managedContext =
                        appDelegate.persistentContainer.viewContext
                    
                    // 2
                    let entity =
                        NSEntityDescription.entity(forEntityName: "Symptomes",
                                                   in: managedContext)!
                    
                    let symp1 = NSManagedObject(entity: entity,
                                                 insertInto: managedContext)
                    
                    // 3
                    symp1.setValue(symp!["description"]!, forKeyPath: "desc")
                    symp1.setValue(typ!, forKey: "typ")
                    // 4
                    do {
                        try managedContext.save()
                        self.symptomes.append(symp1)
                        
                    } catch let error as NSError {
                        print("Could not save. \(error), \(error.userInfo)")
                    }
                }
                    if (!self.feedItems.isEmpty) {
                        
                        self.tableView.reloadData()
                        self.loader.stopAnimating()
                        self.loader.isHidden = true
                        
                    }else{
                        let statusAlert = StatusAlert.instantiate(withImage: UIImage(named: "cancel"),
                                                                  title: "No Entries",
                                                                  message: "We're sorry there's no symptomes yet")
                        statusAlert.showInKeyWindow()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.1) {
                            let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "nav")
                            self.show(controller, sender: true)
                        }
                    }
            }else if(responsep.result.isFailure){
                print("le le")
            }
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
                NSFetchRequest<NSManagedObject>(entityName: "Symptomes")
            //3
            do {
                symptomes = try managedContext.fetch(fetchRequest)
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            let statusAlert = StatusAlert.instantiate(withImage: UIImage(named: "warning"),
                                                      title: "You are off line",
                                                      message: "Please connect to a network to be updated")
            statusAlert.showInKeyWindow()
             self.tableView.reloadData()
        }
    }
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if (SharedData.role == "medecin"){
            return true
        }else{
            return false
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "update" {
            
            let index : Int = (tableView.indexPathForSelectedRow?.row)!
            
            self.details = segue.destination as? UpdateSympViewController
            let nearby = feedItems[index]
            self.details?.descr = nearby["description"] as? String
            self.details?.typ = (nearby["type"] as! String)
            self.details?.id = (nearby["id"] as! Int)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
      
        
        // Initialize tableView
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = UIColor.white
        tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            
             if(Connectivity.isConnectedToInternet()){
                self?.feedItems.removeAll()
                self?.array.removeAll()
                self?.tipe.removeAll()
            let urlPath = URL(string: SharedData.URL+"getsymp")
            Alamofire.request(urlPath!,method:.get).responseJSON { responsep in
                if(responsep.result.isSuccess){
                    let dictp = responsep.result.value! as? Dictionary<String, AnyObject>
                    let dictp1 = dictp?["data"] as? NSArray
                    
                    for symps in (dictp1! as NSArray) {
                        let symp = symps as? Dictionary<String, AnyObject>
                        let typ = symp!["type"] as! String?
                        self?.tipe.append(typ!)
                        let id = symp!["id"] as! Int?
                        let x : Int = id!
                        self?.array.append(String(x))
                        self?.feedItems.append(symp!)
                        self?.resetAllRecords(in: "Symptomes")
                        guard let appDelegate =
                            UIApplication.shared.delegate as? AppDelegate else {
                                return
                        }
                        // 1
                        let managedContext =
                            appDelegate.persistentContainer.viewContext
                        
                        // 2
                        let entity =
                            NSEntityDescription.entity(forEntityName: "Symptomes",
                                                       in: managedContext)!
                        
                        let symp1 = NSManagedObject(entity: entity,
                                                    insertInto: managedContext)
                        
                        // 3
                        symp1.setValue(symp!["description"]!, forKeyPath: "desc")
                        symp1.setValue(typ!, forKey: "typ")
                        // 4
                        do {
                            try managedContext.save()
                            
                            self?.symptomes.append(symp1)
                        } catch let error as NSError {
                            print("Could not save. \(error), \(error.userInfo)")
                        }
                    }
                    
                    if(!(self?.feedItems.isEmpty)!){
                        self?.tableView.reloadData()
                        self?.tableView.dg_stopLoading()
                    }else{
                        let statusAlert = StatusAlert.instantiate(withImage: UIImage(named: "cancel"),
                                                                  title: "No Entries",
                                                                  message: "We're sorry there's no symptomes yet")
                        statusAlert.showInKeyWindow()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.1) {
                            let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "nav")
                            self?.show(controller, sender: true)
                            }
                    }
                }else if(responsep.result.isFailure){
                    print("le le")
                }
                
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
                    NSFetchRequest<NSManagedObject>(entityName: "Symptomes")
                //3
                do {
                    self?.symptomes = try managedContext.fetch(fetchRequest)
                   
                } catch let error as NSError {
                    print("Could not fetch. \(error), \(error.userInfo)")
                }
                let statusAlert = StatusAlert.instantiate(withImage: UIImage(named: "warning"),
                                                          title: "You are off line",
                                                          message: "Please connect to a network to be updated")
                statusAlert.showInKeyWindow()
                self?.tableView.reloadData()
                self?.tableView.dg_stopLoading()
            }
            }, loadingView: loadingView)
        tableView.dg_setPullToRefreshFillColor(UIColor(red: 0.34, green: 0.00, blue: 0.15, alpha: 1.0))
        tableView.dg_setPullToRefreshBackgroundColor(tableView.backgroundColor!)
            
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(Connectivity.isConnectedToInternet()){
            return feedItems.count
           
        }else{
            return symptomes.count
        }
            
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "sympCell")!
        if(Connectivity.isConnectedToInternet()){
        let nearby = self.feedItems[indexPath.row]
            as Dictionary<String, AnyObject>
        let desc = nearby["description"] as! String?
        
        let lblTitle : UILabel = cell.contentView.viewWithTag(2) as! UILabel
        
        lblTitle.text = desc
        let imgIcon : UIImageView = cell.contentView.viewWithTag(1) as! UIImageView
        if(self.tipe[indexPath.row] == "Mild")
        {
        
        imgIcon.image = #imageLiteral(resourceName: "exclamation")
        }else if (self.tipe[indexPath.row] == "Moderate"){
          imgIcon.image = #imageLiteral(resourceName: "Moderate")
        }else if (self.tipe[indexPath.row] == "Severe"){
           imgIcon.image = #imageLiteral(resourceName: "Severe")
        }
        }
        else{
         
            let lblTitle : UILabel = cell.contentView.viewWithTag(2) as! UILabel
            let syy = symptomes[indexPath.row]
            let imgIcon : UIImageView = cell.contentView.viewWithTag(1) as! UIImageView
            lblTitle.text = (syy.value(forKeyPath: "desc") as! String)
         
            let tip =  syy.value(forKeyPath: "typ") as! String
            
            if(tip == "Mild"){
                imgIcon.image = #imageLiteral(resourceName: "exclamation")
            }else if (tip == "Moderate"){
                imgIcon.image = #imageLiteral(resourceName: "Moderate")
            }else if (tip == "Severe"){
                imgIcon.image = #imageLiteral(resourceName: "Severe")
            }
        }
        return cell
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 70.0;//Choose your custom row height
    }
    
}
