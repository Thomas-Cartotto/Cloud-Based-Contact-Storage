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
    @IBOutlet weak var passwordNote: UITextView?
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView?
    
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
        self.continueButton?.layer.cornerRadius = 18
        self.continueButton?.clipsToBounds = true
        self.continueButton?.layer.borderWidth = 1.5
        self.continueButton?.layer.borderColor = UIColor.darkGray.cgColor
        
        //Adding Style to the Text Feilds
        self.emailTextFeild?.attributedPlaceholder = NSAttributedString(string: "Enter Email", attributes: [NSAttributedStringKey.foregroundColor: UIColor.darkGray])
        self.emailTextFeild?.layer.borderColor = UIColor.clear.cgColor

        self.passwordTextFeild?.attributedPlaceholder = NSAttributedString(string: "Enter Password", attributes: [NSAttributedStringKey.foregroundColor: UIColor.darkGray])
        self.passwordTextFeild?.layer.borderColor = UIColor.clear.cgColor

    }
    
    // MARK: Logging in and processing functions
    
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
                    self.annimateLogin()
                }
            })
        }
        else
        {
            self.annimateNoButtonSelected()
        }
    }
    
    // MARK: Login and User creation functions
    
    func loginAndSignup() -> Void
    {
        
        guard let emailText = self.emailTextFeild?.text, !emailText.isEmpty else {self.showBasicError(title: "Whoops", message: "Please enter both an email and password. If you dont have a password, enter one and an account will be made for you.", buttonTitle: "Ok") ; return}
        guard let passwordText = self.passwordTextFeild?.text, !passwordText.isEmpty else {self.showBasicError(title: "Whoops", message: "Please enter both an email and password. If you dont have a password, enter one and an account will be made for you.", buttonTitle: "Ok") ; return}
        
        self.annimateSignInLoading(show: false)
        
        Auth.auth().createUser(withEmail: emailText, password: passwordText)
        {
            (newUser, createError) in
            
            if createError != nil || newUser?.uid == nil
            {
                Auth.auth().signIn(withEmail: emailText, password: passwordText)
                {
                    (currentUser, signinError) in
                    
                    if signinError == nil && currentUser?.uid != nil
                    {
                        Application.shared().loadCurrentUser(userId: (currentUser?.uid)!, completion:
                            {
                                (error, existingAppUser) in
                                
                                if existingAppUser != nil && !error
                                {
                                    self.annimateLogin()
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
                guard let newUserID = newUser?.uid else {self.showBasicError(title: "Unknown Error", message: "There has likely been a network error. Please try again.", buttonTitle: "Ok"); return}
                
                APIClient.createUser(userID: newUserID, email: emailText, success:
                    {
                        (NewAppUser) in
                        
                        Application.shared().currentUser = NewAppUser
                        self.annimateLogin()
                }, failure:
                    {
                        (error) in
                        
                        self.showBasicError(title: "Unknown Error", message: "There has likely been a network error. Please try again.", buttonTitle: "Ok")
                })
            }
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
    
    func annimateLogin() -> Void
    {
        UIView.animate(withDuration: 0.9, delay: 0, options: [.allowUserInteraction], animations:
        {
            self.signUpButton?.alpha = 0
            self.logoImage?.alpha = 0
            self.emailTextFeild?.alpha = 0
            self.passwordTextFeild?.alpha = 0
            self.continueButton?.alpha = 0
            self.passwordNote?.alpha = 0
            self.loadingActivityIndicator?.alpha = 0
        })
        { (error) in
            let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "RootNavigationController") as! UINavigationController
            self.present(vc, animated: false, completion: nil)
        }
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
    
    func annimateSignInLoading(show: Bool) -> Void
    {
        let title = show ? "Continue":""
        self.continueButton?.setTitle(title, for: .normal)
        if show {self.loadingActivityIndicator?.stopAnimating()} else {self.loadingActivityIndicator?.startAnimating()}
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
        self.annimateSignInLoading(show: true)
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    deinit
    {
        self.logoImage?.image = nil
    }
}
