//
//  AppUser.swift
//  Prosper Code Challenge
//
//  Created by Thomas Cartotto on 2018-08-15.
//  Copyright © 2018 com.skipptheline.ios. All rights reserved.
//

import Foundation
import ObjectMapper

open class AppUser: NSObject
{
    open var email: String?
    open var userID: String?
    open var contacts: [Contact]?
    
    public required init?(map: Map) {}
    public init(email: String?, userID: String?)
    {
        super.init()
        self.email = email
        self.userID = userID
    }
    
    public func reloadContacts(completion: @escaping (_ error: Bool, _ contacts: [Contact]?) ->())
    {
        guard let userID = self.userID else {completion(true, nil); return}
        
        APIClient.loadUserContacts(userID: userID, success:
        {
            (contacts: [Contact]) in
            self.contacts = contacts
            completion(false, contacts)
        },
        failure:
        {
            (error: Bool) in
            completion(true, nil)
        })
    }
    
    public func addNewContact(imageData: Data, firstName: String, lastName: String, email: String, phoneNumber: String, timeAdded: Double, completion: @escaping (_ error: Bool) ->())
    {
        guard let userID = self.userID else {completion(true); return}

        APIClient.createContact(userID: userID, imageData: imageData, firstName: firstName, lastName: lastName, email: email, phoneNumber: phoneNumber, timeAdded: timeAdded, success:
        {
            (newContact: Contact) in
            if self.contacts == nil
            {
                self.contacts = [newContact]
            }
            else
            {
                self.contacts?.append(newContact)
            }
            self.contacts = self.contacts?.sorted(by: {$0.fullName ?? "A" < $1.fullName ?? "B"})
            completion(false)
        },
        failure:
        {
            (error: Bool) in
            completion(true)
        })
    }
}

extension AppUser: Mappable
{
    public func mapping(map: Map)
    {
        self.email         <- map["email"]
    }
}

public func ==(lhs: AppUser, rhs: AppUser) -> Bool
{
    if rhs.userID == lhs.userID
    {
        return true
    }
    else
    {
        return false
    }
}

public func != (lhs: AppUser, rhs: AppUser) -> Bool
{
    return !(lhs == rhs)
}
