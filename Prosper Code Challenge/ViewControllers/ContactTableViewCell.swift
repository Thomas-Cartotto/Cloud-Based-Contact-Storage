//
//  ContactTableViewCell.swift
//  Prosper Code Challenge
//
//  Created by Thomas Cartotto on 2018-08-15.
//  Copyright © 2018 com.skipptheline.ios. All rights reserved.
//

import UIKit

class ContactTableViewCell: UITableViewCell
{
    
    @IBOutlet weak var avatarImageView: UIImageView?
    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var shadowView: UIView?
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        // Adding Style to the avatar Image View
        self.avatarImageView?.layer.cornerRadius = 35
        self.avatarImageView?.clipsToBounds = true
        
        // Adding Depth to Avatar Image
        self.shadowView?.clipsToBounds = false
        self.shadowView?.layer.shadowColor = UIColor.black.cgColor
        self.shadowView?.layer.shadowOpacity = 0.5
        self.shadowView?.layer.shadowOffset = CGSize.zero
        self.shadowView?.layer.shadowRadius = 3
        self.shadowView?.layer.shadowPath = UIBezierPath(roundedRect: (self.shadowView?.bounds)!, cornerRadius: 35).cgPath
    }
}
