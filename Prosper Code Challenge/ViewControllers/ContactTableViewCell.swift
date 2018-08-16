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
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        // Adding Style to the avatar Image View
        self.avatarImageView?.layer.cornerRadius = 35
        self.avatarImageView?.clipsToBounds = true
        self.avatarImageView?.layer.borderWidth = 1
        self.avatarImageView?.layer.borderColor = UIColor.black.cgColor
    }
}
