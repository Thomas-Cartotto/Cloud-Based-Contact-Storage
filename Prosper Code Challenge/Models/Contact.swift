//
//  Contact.swift
//  Prosper Code Challenge
//
//  Created by Thomas Cartotto on 2018-08-15.
//  Copyright © 2018 com.skipptheline.ios. All rights reserved.
//

import Foundation
import ObjectMapper

open class Contact: NSObject
{
    open var avatarImageURL: String?
    open var fullName: String?
    open var email: String?
    open var phoneNumber: String?
    open var timeAdded: Double?
    open var contactID: String?
    
    public required init?(map: Map) {}
    public init(avatarURL: String?, fullName: String?, email: String?, phoneNumber: String?, timeAdded: Double?, contactID: String?)
    {
        super.init()
        
        self.avatarImageURL = avatarURL
        self.fullName = fullName
        self.email = email
        self.phoneNumber = phoneNumber
        self.timeAdded = timeAdded
        self.contactID = contactID
    }
    
    open override func isEqual(_ object: Any?) -> Bool
    {
        guard let rhs = object as? Contact else { return false }
        return self == rhs
    }
}

extension Contact: Mappable
{
    public func mapping(map: Map)
    {
        self.avatarImageURL    <- map["avatarImageURL"]
        self.fullName          <- map["fullName"]
        self.phoneNumber       <- map["phoneNumber"]
        self.timeAdded         <- map["timeAdded"]
        self.email             <- map["email"]
        self.contactID         <- map["contactID"]

    }
}

public func ==(lhs: Contact, rhs: Contact) -> Bool
{
    if rhs.contactID == lhs.contactID
    {
        return true
    }
    else
    {
        return false
    }
}

public func !=(lhs: Contact, rhs: Contact) -> Bool
{
    return !(lhs == rhs)
}


