//
//  InitialViewController.swift
//  Prosper Code Challenge
//
//  Created by Thomas Cartotto on 2018-08-15.
//  Copyright © 2018 com.skipptheline.ios. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class InitialViewController: UIViewController, UITextFieldDelegate
{
    
    @IBOutlet weak var signUpButton: UIButton?
    @IBOutlet weak var logoImage: UIImageView?
    @IBOutlet weak var emailTextFeild: UITextField?
    @IBOutlet weak var passwordTextFeild: UITextField?
    @IBOutlet weak var continueButton: UIButton?
    @IBOutlet weak var passwordNote: UILabel?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.setupViews()
        self.checkForAuthentication()
    }
    
    // MARK: View Setup Functions

    func setupViews() -> Void
    {
        // Adding a gradient to the background view
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        gradientLayer.colors = [UIColor(red:0.81, green:0.85, blue:0.87, alpha:1.0).cgColor, UIColor(red:0.89, green:0.92, blue:0.94, alpha:1.0).cgColor]
        self.view.layer.insertSublayer(gradientLayer, at: 0)
        
        // Adding Style to Buttons
        self.signUpButton?.layer.cornerRadius = 18
        self.signUpButton?.clipsToBounds = true
        self.signUpButton?.layer.borderWidth = 1
        self.signUpButton?.layer.borderColor = UIColor.black.cgColor
        self.continueButton?.layer.cornerRadius = 18
        self.continueButton?.clipsToBounds = true
        self.continueButton?.layer.borderWidth = 1.5
        self.continueButton?.layer.borderColor = UIColor.black.cgColor
        
        //Adding Style to the Text Feilds
        self.emailTextFeild?.attributedPlaceholder = NSAttributedString(string: "Enter Email", attributes: [NSAttributedStringKey.foregroundColor: UIColor.darkGray])
        self.emailTextFeild?.layer.borderColor = UIColor.clear.cgColor

        self.passwordTextFeild?.attributedPlaceholder = NSAttributedString(string: "Enter Password", attributes: [NSAttributedStringKey.foregroundColor: UIColor.darkGray])
        self.passwordTextFeild?.layer.borderColor = UIColor.clear.cgColor

    }
    
    func checkForAuthentication() -> Void
    {
        if Auth.auth().currentUser?.uid != nil
        {
            Application.shared().loadCurrentUser(userId: (Auth.auth().currentUser?.uid)!, completion:
            {
                (error, user) in
                
                if error
                {
                   self.annimateNoButtonSelected()
                }
                else
                {
                    UIView.animate(withDuration: 0.9, delay: 0, options: [.allowUserInteraction], animations:
                    {
                        self.signUpButton?.alpha = 0
                        self.logoImage?.alpha = 0
                    })
                    {
                        (error) in
                        let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "RootNavigationController") as! UINavigationController
                        self.present(vc, animated: false, completion: nil)
                    }
                }
            })
        }
        else
        {
            self.annimateNoButtonSelected()
        }
    }
    
    // MARK: View Annimation Functions
    
    func annimateNoButtonSelected() -> Void
    {
        UIView.animate(withDuration: 1.2, delay: 0, options: [.allowUserInteraction], animations:
        {
            self.signUpButton?.alpha = 1
        },completion: nil)
    }
    
    @IBAction func showTextFeilds(_ sender: Any)
    {
        UIView.animate(withDuration: 1.2, delay: 0, options: [.allowUserInteraction], animations:
        {
            self.signUpButton?.alpha = 0
            self.logoImage?.alpha = 0
            self.emailTextFeild?.alpha = 1
            self.passwordTextFeild?.alpha = 1
            self.continueButton?.alpha = 1
            self.passwordNote?.alpha = 1
        }) { (error) in self.emailTextFeild?.becomeFirstResponder()}
    }
    
    @IBAction func loginSignupButtonPressed(_ sender: Any)
    {
        self.loginAndSignup()
    }
    
    // MARK: Login and User creation functions
    
    func loginAndSignup() -> Void
    {
        
        guard let emailText = self.emailTextFeild?.text, !emailText.isEmpty else {self.showBasicError(title: "Whoops", message: "Please enter both an email and password. If you dont have a password, enter one and an account will be made for you.", buttonTitle: "Ok") ; return}
        guard let passwordText = self.passwordTextFeild?.text, !passwordText.isEmpty else {self.showBasicError(title: "Whoops", message: "Please enter both an email and password. If you dont have a password, enter one and an account will be made for you.", buttonTitle: "Ok") ; return}
        
        
        Auth.auth().createUser(withEmail: emailText, password: passwordText)
        {
            (newUser, error) in
            
            if error != nil || newUser?.uid == nil
            {
                Auth.auth().signIn(withEmail: emailText, password: passwordText)
                {
                    (user, error) in
                    
                    if error != nil && user?.uid != nil
                    {
                        Application.shared().loadCurrentUser(userId: (newUser?.uid)!, completion:
                        {
                            (error, existingAppUser) in
                            
                            if existingAppUser != nil && !error
                            {
                                let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "RootNavigationController") as! UINavigationController
                                self.present(vc, animated: false, completion: nil)
                            }
                            else
                            {
                                self.showBasicError(title: "Unknown Error", message: "There has likely been a network error. Please try again.", buttonTitle: "Ok")
                            }
                        })
                    }
                    else
                    {
                        self.showBasicError(title: "Incorrect Entry", message: "Please make sure you have entered your password correctly and that your email is valid.", buttonTitle: "Ok")
                    }
                }
            }
            else
            {
                APIClient.createUser(userID: (newUser?.uid)!, email: emailText, success:
                {
                    (NewAppUser) in
                    
                    Application.shared().currentUser = NewAppUser
                    let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "RootNavigationController") as! UINavigationController
                    self.present(vc, animated: false, completion: nil)
                    
                }, failure:
                {
                    (error) in
                    
                    self.showBasicError(title: "Unknown Error", message: "There has likely been a network error. Please try again.", buttonTitle: "Ok")
                })
            }
        }
    }

    
    // MARK: Text Feild Delagate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if (textField === self.emailTextFeild)
        {
            self.emailTextFeild?.resignFirstResponder()
            self.passwordTextFeild?.becomeFirstResponder()
        }
        else
        {
            self.loginAndSignup()
        }
        return true
    }
    
    
    // MARK: User Facing Errors
    
    func showBasicError(title: String, message: String, buttonTitle: String) -> Void
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
