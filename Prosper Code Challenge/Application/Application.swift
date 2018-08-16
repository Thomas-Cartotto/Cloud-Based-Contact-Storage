//
//  Application.swift
//  Prosper Code Challenge
//
//  Created by Thomas Cartotto on 2018-08-15.
//  Copyright © 2018 com.skipptheline.ios. All rights reserved.
//

import Foundation
import Firebase

open class Application
{
    fileprivate static let _sharedApplication = Application()
    
    open var currentUser: AppUser?
    open var currentDeviceToken: String?
    
    public static let ViewPass = Notification.Name("ViewPass")
    
    open class func shared() -> Application
    {
        return Application._sharedApplication
    }
    
    open var tabBarColor = UIColor(red: 59/255, green: 79/255, blue: 102/255, alpha: 1)
    
    public func loadCurrentUser(userId: String, completion: @escaping (_ error: Bool, _ user: AppUser?) ->())
    {
        APIClient.loadUserData(userID: userId, success:
        {
            (user: AppUser) in
            self.currentUser = user
            completion(false, user)
        },
        failure:
        {
            (error: Bool) in
            completion(true, nil)
        })
    }
}


extension Notification.Name
{
    static let scheduleUpdated = Notification.Name("schedule-updates")
}

