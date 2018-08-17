//
//  ContactsViewController.swift
//  Prosper Code Challenge
//
//  Created by Thomas Cartotto on 2018-08-15.
//  Copyright © 2018 com.skipptheline.ios. All rights reserved.
//

import UIKit
import SVProgressHUD
import FirebaseAuth

class ContactsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, ContactAddedDelegate
{
    
    @IBOutlet weak var contactTableView: UITableView?
    
    private let refreshControl = UIRefreshControl()
    
    var mutableContacts = [Contact]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.setupViews()
        self.reloadContactData()
    }
    
    // MARK: - Setting up the view

    func setupViews() -> Void
    {
        // Adding a gradient to the background view
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        gradientLayer.colors = [UIColor(red:0.81, green:0.85, blue:0.87, alpha:1.0).cgColor, UIColor(red:0.89, green:0.92, blue:0.94, alpha:1.0).cgColor]
        self.view.layer.insertSublayer(gradientLayer, at: 0)
        
        // Making the navigation bar compleatly transparent
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true

        // Creating Buttons on the navigation controller
        let addButton = UIBarButtonItem.init(image: UIImage(named: "add-button")!.withRenderingMode(.alwaysOriginal), style: .done, target: self, action: #selector(self.addContact))
        let logoutButton = UIBarButtonItem.init(image: UIImage(named: "exit")!.withRenderingMode(.alwaysOriginal), style: .done, target: self, action: #selector(self.logout))
        self.navigationItem.rightBarButtonItems = [addButton, logoutButton]
        self.navigationController?.navigationBar.alpha = 0

        // Adding the transition annimation
        UIView.animate(withDuration: 0.9, delay: 0, options: [.allowUserInteraction], animations:
        {
            self.contactTableView?.alpha = 1
            self.navigationController?.navigationBar.alpha = 1
        }, completion: nil)
        
        // Adding the refresh controller and tableview data
        self.refreshControl.addTarget(self, action: #selector(refreshContacts(_:)), for: .valueChanged)
        if #available(iOS 10.0, *)
        {
            self.contactTableView?.refreshControl = refreshControl
        }
        else
        {
            self.contactTableView?.addSubview(refreshControl)
        }
    }
    
    // MARK: - Loading data into the AppUser then to local storage for mutation (optional)

    func reloadContactData() -> Void
    {
        SVProgressHUD.show()
        Application.shared().currentUser?.reloadContacts(completion:
        {
            (error, newContacts) in
            
            if error
            {
                self.showBasicError(title: "Error Reloading Data", message: "Sorry. Please try again.", buttonTitle: "Ok")
            }
            else
            {
                self.mutableContacts = newContacts!
                self.contactTableView?.reloadData()
                SVProgressHUD.dismiss()
            }
        })
    }
    
    // MARK: - Table View Delegate Functions
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        self.contactTableView?.isScrollEnabled = Application.shared().currentUser?.contacts?.count == 0 ? false:true
        return self.mutableContacts.count == 0 ? 1:self.mutableContacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if self.mutableContacts.count == 0
        {
            let cell = UITableViewCell()
            cell.textLabel?.text = "No Contacts - Tap Here to Add ↑  "
            cell.backgroundColor = UIColor.clear
            cell.textLabel?.textAlignment = .right
            cell.textLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 20)
            cell.textLabel?.adjustsFontSizeToFitWidth = true
            return cell
        }
        else
        {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "Contact", for: indexPath) as? ContactTableViewCell,
                let name = self.mutableContacts[indexPath.row].fullName,
                let avatarURl = self.mutableContacts[indexPath.row].avatarImageURL else {return UITableViewCell()}
            
            cell.nameLabel?.text = name
            cell.avatarImageView?.af_setImage(withURL: URL(string: avatarURl)!, placeholderImage: UIImage(named: "1095867-200"), filter: nil, progress: nil, progressQueue: .global(qos: .background), imageTransition: .crossDissolve(0.5) , runImageTransitionIfCached: false, completion:
            {
                (response) in
                UIView.animate(withDuration: 0.6, animations:
                {
                    cell.shadowView?.alpha = 1
                })
            })
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        if self.mutableContacts.count == 0
        {
            return false
        }
        else
        {
            return true
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
    {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete")
        {
            (rowAction, indexPath) in
            
            SVProgressHUD.show()
            guard let contactID = self.mutableContacts[indexPath.row].contactID,
                    let userID = Application.shared().currentUser?.userID else {return}
            
            APIClient.deleteContact(userID: userID, contactID: contactID, success:
            {
                (result) in
                self.reloadContactData()
            },
            failure:
            {
                (error) in
                self.showBasicError(title: "Error Deleting", message: "Sorry an error has occured when trying to delete this contact. Please try Again", buttonTitle: "Ok")
            })
        }
        
        let hideAction = UITableViewRowAction(style: .normal, title: "Hide")
        {
            (rowAction, indexPath) in
            
            self.mutableContacts.remove(at: indexPath.row)
            self.contactTableView?.reloadData()
        }
        hideAction.backgroundColor = UIColor(red: 0/255, green: 114/255, blue: 198/255, alpha: 1)
        
        return [deleteAction, hideAction]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if let contactExpansionVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ExpandedContact") as? ExpandedContactViewController
        {
            contactExpansionVC.currentContact = self.mutableContacts[indexPath.row]
            if let navigator = navigationController
            {
                navigator.pushViewController(contactExpansionVC, animated: true)
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        if (self.contactTableView?.contentOffset.y)! >= CGFloat(-32.0)
        {
            if (self.contactTableView?.contentOffset.y)! <= CGFloat(0.0)
            {
                self.navigationController?.navigationBar.alpha = 1 - ((32 + (self.contactTableView?.contentOffset.y)!) * 0.031) // 0.028 is pre-calculated
            }
            else
            {
                self.navigationController?.navigationBar.alpha = 0
            }
        }
        else
        {
            self.navigationController?.navigationBar.alpha = 1
        }
    }
    
    // MARK: - Add Contact Delegate Function

    func didAddNewContact()
    {
        if Application.shared().currentUser?.contacts != nil
        {
            self.mutableContacts = (Application.shared().currentUser?.contacts)!
            self.contactTableView?.reloadData()
        }
    }
    
    // MARK: Navigation Bar Functions
    
    @objc func addContact() -> Void
    {
        if let addContactVc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddContact") as? AddContactViewController
        {
            if let navigator = navigationController
            {
                addContactVc.addDelegate = self
                navigator.pushViewController(addContactVc, animated: true)
            }
        }
    }
    
    @objc func logout() -> Void
    {
        do {
            try! Auth.auth().signOut()
            Application.shared().currentUser = nil
            let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "InitialScreen")
            self.present(vc, animated: true, completion: nil)
        } catch (let error) {
            print((error as NSError).code)
        }
    }
    
    @objc private func refreshContacts(_ sender: Any)
    {
        guard let stableContacts = Application.shared().currentUser?.contacts else {return}
        self.mutableContacts = stableContacts
        self.contactTableView?.reloadData()
        self.refreshControl.endRefreshing()
        // Note this is not pulling from the database but is done to show how self.mutableContacts can be changed and then reset (ie filter or search)
    }
    
    // MARK: User Facing Errors
    
    func showBasicError(title: String, message: String, buttonTitle: String) -> Void
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

