//
//  ContactViewController.swift
//  Alzheimer
//
//  Created by Rym Ben Jmaa on 11/30/17.
//  Copyright © 2017 Esprit. All rights reserved.
//

import UIKit
import Alamofire
import MessageUI
import CoreData
import StatusAlert
class ContactViewController: UIViewController, MFMailComposeViewControllerDelegate {
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var nom: UILabel!
     var doc:[NSManagedObject] = []
    @IBOutlet weak var smsText: UITextView!
    @IBOutlet weak var prenom: UILabel!
    @IBOutlet weak var subject: UITextField!
    @IBOutlet weak var num: UILabel!
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
                NSFetchRequest<NSManagedObject>(entityName: "Doctor")
            //3
            do {
                doc = try managedContext.fetch(fetchRequest)
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            let adv = doc[0]
            
            self.nom.text = adv.value(forKeyPath: "fn") as? String
            self.prenom.text = adv.value(forKeyPath: "ln") as? String
            self.num.text = adv.value(forKeyPath: "phone") as? String
            self.email.text = adv.value(forKeyPath: "email") as? String
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        smsText.placeholder="Compose your email content..."
        if(Connectivity.isConnectedToInternet()){
        Alamofire.request(SharedData.URL+"getadvice", method:.get).responseJSON{response in
            
            if(response.result.isSuccess)
            {
               
               
                
                
                let dict = response.result.value as? Dictionary<String,AnyObject>
                let groups = dict?["data"] as? Dictionary<String,AnyObject>
                self.email.text = groups!["email"] as? String
                self.prenom.text = groups!["nom"] as? String
                self.nom.text = groups!["prenom"] as? String
                // self.doctor.alpha = 1
                //self.doctor.font = UIFont(name: "Scriptina", size: 17.0)
                self.num.text = (groups!["telephone"] as! String)
                //self.advise.font = UIFont(name: "Scriptina", size: 40.0)
                // self.advise.alpha = 1
                self.resetAllRecords(in: "Doctor")
                guard let appDelegate =
                    UIApplication.shared.delegate as? AppDelegate else {
                        return
                }
                // 1
                let managedContext =
                    appDelegate.persistentContainer.viewContext
                
                // 2
                let entity =
                    NSEntityDescription.entity(forEntityName: "Doctor",
                                               in: managedContext)!
                
                let adv = NSManagedObject(entity: entity,
                                          insertInto: managedContext)
                
                // 3
                adv.setValue(self.nom.text! , forKeyPath: "fn")
                adv.setValue(self.prenom.text!, forKey: "ln")
                adv.setValue(self.num.text!, forKey: "phone")
                adv.setValue(self.email.text!, forKey: "email")
                print(self.prenom.text!)
                // 4
                do {
                    try managedContext.save()
                    self.doc.append(adv)
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
            
            guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
                    return
            }
            
            let managedContext =
                appDelegate.persistentContainer.viewContext
            
            //2
            let fetchRequest =
                NSFetchRequest<NSManagedObject>(entityName: "Doctor")
            //3
            do {
                doc = try managedContext.fetch(fetchRequest)
                let adv = doc[0]
                self.nom.text = adv.value(forKeyPath: "fn") as? String
                self.prenom.text = adv.value(forKeyPath: "ln") as? String
                self.num.text = adv.value(forKeyPath: "phone") as? String
                self.email.text = adv.value(forKeyPath: "email") as? String
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            
            let statusAlert = StatusAlert.instantiate(withImage: UIImage(named: "warning"),
                                                      title: "You are off line",
                                                      message: "Please connect to a network to be updated")
            statusAlert.showInKeyWindow()
            //1
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true,completion: nil)
    }
    @IBAction func contacter(_ sender: Any) {
        let url: NSURL = URL(string: "TEL://" + self.num.text!)! as NSURL
        
        UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    @IBAction func sms(_ sender: Any) {
        
        let mailCompose = MFMailComposeViewController()
        
        mailCompose.mailComposeDelegate = self
        mailCompose.setToRecipients([email.text!])
        mailCompose.setSubject(subject.text!)
        mailCompose.setMessageBody(smsText.text, isHTML: false)
        if MFMailComposeViewController.canSendMail(){
            self.present(mailCompose, animated: true, completion: nil)
        }else {
            print("couldn't send the email")
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
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
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
extension UITextView: UITextViewDelegate {
    
    /// Resize the placeholder when the UITextView bounds change
    override open var bounds: CGRect {
        didSet {
            self.resizePlaceholder()
        }
    }
    
    /// The UITextView placeholder text
    public var placeholder: String? {
        get {
            var placeholderText: String?
            
            if let placeholderLabel = self.viewWithTag(100) as? UILabel {
                placeholderText = placeholderLabel.text
            }
            
            return placeholderText
        }
        set {
            if let placeholderLabel = self.viewWithTag(100) as! UILabel? {
                placeholderLabel.text = newValue
                placeholderLabel.sizeToFit()
                placeholderLabel.numberOfLines = 4
            } else {
                if(newValue != nil){
                    self.addPlaceholder(newValue!)
                }
            }
        }
    }
    
    /// When the UITextView did change, show or hide the label based on if the UITextView is empty or not
    ///
    /// - Parameter textView: The UITextView that got updated
    public func textViewDidChange(_ textView: UITextView) {
        if let placeholderLabel = self.viewWithTag(100) as? UILabel {
            placeholderLabel.isHidden = self.text.count > 0
        }
    }
    
    /// Resize the placeholder UILabel to make sure it's in the same position as the UITextView text
    private func resizePlaceholder() {
        if let placeholderLabel = self.viewWithTag(100) as! UILabel? {
            let labelX = self.textContainer.lineFragmentPadding
            let labelY = self.textContainerInset.top - 2
            let labelWidth = self.frame.width - (labelX * 2)
            let labelHeight = placeholderLabel.frame.height
            placeholderLabel.numberOfLines = 4
            placeholderLabel.frame = CGRect(x: labelX, y: labelY, width: labelWidth, height: labelHeight)
        }
    }
    
    /// Adds a placeholder UILabel to this UITextView
    private func addPlaceholder(_ placeholderText: String) {
        let placeholderLabel = UILabel()
        
        placeholderLabel.text = placeholderText
        placeholderLabel.sizeToFit()
        
        placeholderLabel.font = self.font
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.tag = 100
        placeholderLabel.numberOfLines = 4
        placeholderLabel.isHidden = self.text.count > 0
        
        self.addSubview(placeholderLabel)
        self.resizePlaceholder()
        self.delegate = self
    }
    
}
