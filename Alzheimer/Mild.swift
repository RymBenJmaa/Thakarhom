//
//  Mild.swift
//  Alzheimer
//
//  Created by Rym Ben Jmaa on 11/16/17.
//  Copyright © 2017 Esprit. All rights reserved.
//

import UIKit
import Alamofire
class Mild: BaseViewController, UITableViewDataSource, UITableViewDelegate {
   
    var details: UpdateSympViewController?
    @IBOutlet weak var tableView: UITableView!
    var array = [String]()


    var feedItems = [Dictionary<String, AnyObject>]()
    override func viewDidAppear(_ animated: Bool) {

    }
    override func viewWillAppear(_ animated: Bool) {
        feedItems.removeAll()
        
        let urlPath = URL(string: SharedData.URL+"getsymp")
        
        Alamofire.request(urlPath!,method:.get).responseJSON { responsep in
            if(responsep.result.isSuccess){
                // let userm = UserModel()
                
                let dictp = responsep.result.value! as? Dictionary<String, AnyObject>
                let dictp1 = dictp?["data"] as? NSArray
                
                for symps in (dictp1! as NSArray) {
                    let symp = symps as? Dictionary<String, AnyObject>
                    let typ = symp!["type"] as! String?
                    let id = symp!["id"] as! Int?
                    if(typ == "Mild")
                    {
                        let x : Int = id!
                        self.array.append(String(x))
                        self.feedItems.append(symp!)
                        self.tableView.reloadData()
                    }
                    
                }
                
            }else if(responsep.result.isFailure){
                print("le le")
            }
            
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
        if segue.identifier == "updateMild" {

                let index : Int = (tableView.indexPathForSelectedRow?.row)!
                
                self.details = segue.destination as? UpdateSympViewController
                let nearby = feedItems[index]
                self.details?.descr = nearby["description"] as? String
                self.details?.typ = (nearby["type"] as! String)
                self.details?.id = (nearby["id"] as! Int)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedItems.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "mildCell")!
        let nearby = self.feedItems[indexPath.row]
            as Dictionary<String, AnyObject>
        let desc = nearby["description"] as! String?
        
        let lblTitle : UILabel = cell.contentView.viewWithTag(2) as! UILabel
        
        lblTitle.text = desc
        
        
        return cell
        
        
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 70.0;//Choose your custom row height
    }

}
