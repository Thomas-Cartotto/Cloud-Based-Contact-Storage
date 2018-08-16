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
    
    open override func isEqual(_ object: Any?) -> Bool
    {
        guard let rhs = object as? AppUser else { return false }
        return self == rhs
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
}

extension AppUser: Mappable
{
    public func mapping(map: Map)
    {
        self.email         <- map["email"]
        self.userID          <- map["userID"]
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

