//
//  AddContactViewController.swift
//  Prosper Code Challenge
//
//  Created by Thomas Cartotto on 2018-08-16.
//  Copyright © 2018 com.skipptheline.ios. All rights reserved.
//

import UIKit
import SVProgressHUD

protocol ContactAddedDelegate
{
    func didAddNewContact()
}

class AddContactViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    
    @IBOutlet weak var profileImage: UIImageView?
    @IBOutlet weak var firstName: UITextField?
    @IBOutlet weak var lastName: UITextField?
    @IBOutlet weak var email: UITextField?
    @IBOutlet weak var phoneNumber: UITextField?
    @IBOutlet weak var saveContactButton: UIButton?
    @IBOutlet weak var shadowView: UIView?
    
    var addDelegate: ContactAddedDelegate!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.setupViews()
    }
    
    func setupViews() -> Void
    {
        // Adding a gradient to the background view
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        gradientLayer.colors = [UIColor(red:0.81, green:0.85, blue:0.87, alpha:1.0).cgColor, UIColor(red:0.89, green:0.92, blue:0.94, alpha:1.0).cgColor]
        self.view.layer.insertSublayer(gradientLayer, at: 0)
        self.title = "Add Contact"
        
        // Setting Up Text Feilds
        self.firstName?.attributedPlaceholder = NSAttributedString(string: "First Name", attributes: [NSAttributedStringKey.foregroundColor: UIColor.darkGray])
        self.firstName?.layer.borderColor = UIColor.clear.cgColor
        self.lastName?.attributedPlaceholder = NSAttributedString(string: "Last Name", attributes: [NSAttributedStringKey.foregroundColor: UIColor.darkGray])
        self.lastName?.layer.borderColor = UIColor.clear.cgColor
        self.email?.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedStringKey.foregroundColor: UIColor.darkGray])
        self.email?.layer.borderColor = UIColor.clear.cgColor
        self.phoneNumber?.attributedPlaceholder = NSAttributedString(string: "Phone Number", attributes: [NSAttributedStringKey.foregroundColor: UIColor.darkGray])
        self.phoneNumber?.layer.borderColor = UIColor.clear.cgColor
        
        //Setup Avatar Image
        self.profileImage?.layer.cornerRadius = (self.profileImage?.frame.width ?? 120)/2
        self.profileImage?.clipsToBounds = true
        self.profileImage?.layer.borderWidth = 1
        self.profileImage?.layer.borderColor = UIColor.black.cgColor
        
        // Adding Depth to Avatar Image
        self.shadowView?.clipsToBounds = false
        self.shadowView?.layer.shadowColor = UIColor.black.cgColor
        self.shadowView?.layer.shadowOpacity = 0.5
        self.shadowView?.layer.shadowOffset = CGSize.zero
        self.shadowView?.layer.shadowRadius = 4
        self.shadowView?.layer.shadowPath = UIBezierPath(roundedRect: (self.shadowView?.bounds)!, cornerRadius: (self.profileImage?.frame.width ?? 120)/2).cgPath
        
        //Setup Button
        self.saveContactButton?.layer.cornerRadius = 18
        self.saveContactButton?.clipsToBounds = true
        self.saveContactButton?.layer.borderWidth = 1.5
        self.saveContactButton?.layer.borderColor = UIColor.black.cgColor
        
        // Adding gesture control
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(userSwipeImage(tapGestureRecognizer:)))
        self.profileImage?.addGestureRecognizer(swipe)
        self.profileImage?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(userTapImageView(tapGestureRecognizer:))))
        self.view?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(userTapScreen(tapGestureRecognizer:))))
    }
    
    @IBAction func saveContact(_ sender: Any)
    {
        self.uploadContact()
    }
    
    // MARK: Gesture Control Functions
    
    @objc func userSwipeImage(tapGestureRecognizer: UITapGestureRecognizer)
    {
        self.profileImage?.image = nil
        self.profileImage?.layer.borderColor = UIColor.black.cgColor
        UIView.animate(withDuration: 0.4, animations:
        {
            self.shadowView?.alpha = 0
        })
    }
    
    @objc func userTapScreen(tapGestureRecognizer: UITapGestureRecognizer)
    {
        self.view.endEditing(true)
    }
    
    @objc func userTapImageView(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let choosePhotoPrompt = UIAlertController(title: "Contact Photo",
                                       message: "You can add a photo to help identify a contact",
                                       preferredStyle: .actionSheet)
        
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        func presentCamera(_ _: UIAlertAction) {
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true)
        }
        
        let cameraAction = UIAlertAction(title: "Camera",
                                         style: .default,
                                         handler: presentCamera)
        
        func presentLibrary(_ _: UIAlertAction) {
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true)
        }
        
        let libraryAction = UIAlertAction(title: "Photo Library",
                                          style: .default,
                                          handler: presentLibrary)
        
        func presentAlbums(_ _: UIAlertAction) {
            imagePicker.sourceType = .savedPhotosAlbum
            self.present(imagePicker, animated: true)
        }
        
        let albumsAction = UIAlertAction(title: "Saved Albums",
                                         style: .default,
                                         handler: presentAlbums)
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel,
                                         handler: nil)
        
        choosePhotoPrompt.addAction(cameraAction)
        choosePhotoPrompt.addAction(libraryAction)
        choosePhotoPrompt.addAction(albumsAction)
        choosePhotoPrompt.addAction(cancelAction)
        
        self.present(choosePhotoPrompt, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        picker.dismiss(animated: true)
        
        guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else {
            print("No image found")
            return
        }
        
        self.profileImage?.image = nil
        self.profileImage?.image = image
        self.profileImage?.layer.borderColor = UIColor.clear.cgColor
        UIView.animate(withDuration: 0.6, animations:
        {
            self.shadowView?.alpha = 1
        })
    }
    
    // MARK: Uploading the Contact
    
    func uploadContact() -> Void
    {
        guard let firstName = self.firstName?.text, !firstName.isEmpty, let lastName = self.lastName?.text, !lastName.isEmpty, let email = self.email?.text, !lastName.isEmpty, let phoneNumber = self.phoneNumber?.text, !phoneNumber.isEmpty, let image = self.profileImage?.image else {self.showBasicError(title: "Contact Incomplete", message: "Ensure all feilds are filled out and a photo has been selected", buttonTitle: "Ok"); return}
        
        guard let imageData = UIImagePNGRepresentation(image) else {return}
        
        let timeAdded = Date().timeIntervalSince1970
        
        self.view.endEditing(true)
        SVProgressHUD.show()
        self.view.isUserInteractionEnabled = false
        
        Application.shared().currentUser?.addNewContact(imageData: imageData, firstName: firstName.replacingOccurrences(of: " ", with: ""), lastName: lastName.replacingOccurrences(of: " ", with: ""), email: email.replacingOccurrences(of: " ", with: ""), phoneNumber: self.format(phoneNumber: phoneNumber) ?? phoneNumber, timeAdded: timeAdded, completion:
        {
            (error) in
            
            self.view.isUserInteractionEnabled = true

            if error
            {
                self.showBasicError(title: "Error", message: "Contact was not saved. Please try again", buttonTitle: "Ok")
            }
            else
            {
                SVProgressHUD.dismiss()
                self.addDelegate.didAddNewContact()
                self.navigationController?.popViewController(animated: true)
            }
        })
    }
    
    // MARK: User Facing Errors
    
    func showBasicError(title: String, message: String, buttonTitle: String) -> Void
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: Text Feild Delagate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        switch textField
        {
            case self.firstName:
                self.firstName?.resignFirstResponder()
                self.lastName?.becomeFirstResponder()
            case self.lastName:
                self.lastName?.resignFirstResponder()
                self.email?.becomeFirstResponder()
            case self.email:
                self.email?.resignFirstResponder()
                self.phoneNumber?.becomeFirstResponder()
            default:
                self.uploadContact()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        if textField == self.phoneNumber
        {
            guard let text = textField.text else { return true }
            let newLength = text.utf16.count + string.utf16.count - range.length
            return newLength <= 10 
        }
        return true
    }
    
    deinit
    {
        self.profileImage?.image = nil
    }
    
    // MARK: Phone Number formatter (not mine, found at https://stackoverflow.com/questions/32364055/formattting-phone-number-in-swift)
    
    func format(phoneNumber sourcePhoneNumber: String) -> String? {
        // Remove any character that is not a number
        let numbersOnly = sourcePhoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        let length = numbersOnly.count
        let hasLeadingOne = numbersOnly.hasPrefix("1")
        
        // Check for supported phone number length
        guard length == 7 || length == 10 || (length == 11 && hasLeadingOne) else {
            return nil
        }
        
        let hasAreaCode = (length >= 10)
        var sourceIndex = 0
        
        // Leading 1
        var leadingOne = ""
        if hasLeadingOne {
            leadingOne = "1 "
            sourceIndex += 1
        }
        
        // Area code
        var areaCode = ""
        if hasAreaCode {
            let areaCodeLength = 3
            guard let areaCodeSubstring = numbersOnly.substring(start: sourceIndex, offsetBy: areaCodeLength) else {
                return nil
            }
            areaCode = String(format: "(%@) ", areaCodeSubstring)
            sourceIndex += areaCodeLength
        }
        
        // Prefix, 3 characters
        let prefixLength = 3
        guard let prefix = numbersOnly.substring(start: sourceIndex, offsetBy: prefixLength) else {
            return nil
        }
        sourceIndex += prefixLength
        
        // Suffix, 4 characters
        let suffixLength = 4
        guard let suffix = numbersOnly.substring(start: sourceIndex, offsetBy: suffixLength) else {
            return nil
        }
        
        return leadingOne + areaCode + prefix + "-" + suffix
    }
    
}

extension String
{
    internal func substring(start: Int, offsetBy: Int) -> String? {
        guard let substringStartIndex = self.index(startIndex, offsetBy: start, limitedBy: endIndex) else {
            return nil
        }
        guard let substringEndIndex = self.index(startIndex, offsetBy: start + offsetBy, limitedBy: endIndex) else {
            return nil
        }
        return String(self[substringStartIndex ..< substringEndIndex])
    }
}
