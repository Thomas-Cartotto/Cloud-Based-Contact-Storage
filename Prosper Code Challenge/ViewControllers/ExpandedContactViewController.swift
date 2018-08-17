//
//  ExpandedContactViewController.swift
//  Prosper Code Challenge
//
//  Created by Thomas Cartotto on 2018-08-15.
//  Copyright © 2018 com.skipptheline.ios. All rights reserved.
//

import UIKit
import AlamofireImage
import AFDateHelper

class ExpandedContactViewController: UIViewController
{
    
    weak var currentContact: Contact?
    
    @IBOutlet weak var profileImage: UIImageView?
    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var emailLabel: UITextView?
    @IBOutlet weak var phoneLabel: UITextView?
    @IBOutlet weak var dateAddedLabel: UILabel?
    
    var dateLabelState = 0
    var dateOptions: [String]?

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
        
        // Change the style of the imageView
        self.profileImage?.layer.cornerRadius = (self.profileImage?.frame.width ?? 136)/2
        self.profileImage?.clipsToBounds = true
        self.profileImage?.layer.borderWidth = 1
        self.profileImage?.layer.borderColor = UIColor.black.cgColor
        
        // Populate views with data
        self.nameLabel?.text = self.currentContact?.fullName
        self.emailLabel?.text = self.currentContact?.email
        self.phoneLabel?.text = self.currentContact?.phoneNumber
        self.profileImage?.af_setImage(withURL: URL(string: self.currentContact?.avatarImageURL ?? "noImage")!, placeholderImage: nil, filter: nil, progress: nil, progressQueue: .global(qos: .default), imageTransition: .crossDissolve(0.6), runImageTransitionIfCached: false, completion: nil)
        guard let timeOfCreation = self.currentContact?.timeAdded else {self.dateAddedLabel?.text = "In the Past"; return}
        let date = Date(timeIntervalSince1970: timeOfCreation)
        self.dateOptions = [date.toStringWithRelativeTime().capitalized, date.toString(style: .short)]
        self.dateAddedLabel?.text = self.dateOptions?[self.dateLabelState] ?? "No date data"
        
        // Add gesture to label
        self.dateAddedLabel?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(userTapDateLabel(tapGestureRecognizer:))))
    }
    
    @objc func userTapDateLabel(tapGestureRecognizer: UITapGestureRecognizer)
    {
        self.dateLabelState = self.dateLabelState == 0 ? 1:0
        self.dateAddedLabel?.text = self.dateOptions?[self.dateLabelState] ?? "No date data"
    }
    
    deinit
    {
        self.profileImage?.image = nil
        self.currentContact = nil
    }
}
