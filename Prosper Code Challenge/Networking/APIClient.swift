//
//  APIService.swift
//  Prosper Code Challenge
//
//  Created by Thomas Cartotto on 2018-08-15.
//  Copyright © 2018 com.skipptheline.ios. All rights reserved.
//

import Foundation
import FirebaseFirestore
import ObjectMapper
import FirebaseStorage

open class APIClient
{
    open class func loadUserData (userID: String, success: ((_ user: AppUser) -> ())?, failure: ((_ error: Bool) -> ())?)
    {
        let db = Firestore.firestore()
        db.collection("Users").document(userID).getDocument()
        {
            (querySnapshot, err) in
            
            if err != nil
            {
                failure!(true)
            }
            else
            {
                let data = querySnapshot!.data() as NSDictionary?
                if let user = Mapper<AppUser>().map(JSONObject: data)
                {
                    success!(user)
                }
            }
        }
    }
    
    open class func createUser (userID: String, email: String, success: ((_ user: AppUser) -> ())?, failure: ((_ error: Bool) -> ())?)
    {
        let db = Firestore.firestore()
        db.collection("Users").document(userID).setData([
            "userID": userID,
            "email": email
        ])
        {err in
            if err != nil
            {
                failure!(true)
            }
            else
            {
                success!(AppUser(email: email, userID: userID))
            }
        }
    }
    
    open class func loadUserContacts (userID: String, success: ((_ contacts: [Contact]) -> ())?, failure: ((_ error: Bool) -> ())?)
    {
        let db = Firestore.firestore()
        db.collection("Users").document(userID).collection("contacts").getDocuments()
        {
            (querySnapshot, err) in
            
            if err != nil
            {
                failure!(true)
            }
            else
            {
                var tempContacts = [Contact]()
                for document in querySnapshot!.documents
                {
                    let data = document.data() as NSDictionary?
                    if let contact = Mapper<Contact>().map(JSONObject: data)
                    {
                        tempContacts.append(contact)
                    }
                }
                success!(tempContacts.sorted(by: {$0.fullName ?? "A" < $1.fullName ?? "B"}))
            }
        }
    }
    
    open class func deleteContact (userID: String, contactID: String, success: ((_ result: Bool) -> ())?, failure: ((_ error: Bool) -> ())?)
    {
        let db = Firestore.firestore()
        db.collection("Users").document(userID).collection("contacts").document(contactID).delete()
        { err in
            if err != nil
            {
                failure!(true)
            }
            else
            {
                success!(true)
            }
        }
    }
    
    open class func createContact (userID: String, imageData: Data, firstName: String, lastName: String, email: String, phoneNumber: String, timeAdded: Double, success: ((_ contact: Contact) -> ())?, failure: ((_ error: Bool) -> ())?)
    {
        let contactID = NSUUID().uuidString
        let db = Firestore.firestore()
        
        let storageRef = Storage.storage().reference().child("Users").child(userID).child("Contacts").child("\(contactID).jpg")
        storageRef.putData(imageData, metadata: nil)
        {
            (metadata, error) in
            storageRef.downloadURL
            {
                (url, error) in
                guard let downloadURL = url else {failure!(true); return}
                
                if error == nil
                {
                    db.collection("Users").document(userID).collection("contacts").document(contactID).setData([
                        "contactID": contactID,
                        "fullName": "\(firstName) \(lastName)",
                        "email": email,
                        "phoneNumber": phoneNumber,
                        "avatarImageURL": downloadURL.absoluteString,
                        "timeAdded": timeAdded
                        ])
                    {err in
                        if err != nil
                        {
                            failure!(true)
                        }
                        else
                        {
                            success!(Contact(avatarURL: downloadURL.absoluteString, fullName: "\(firstName) \(lastName)", email: email, phoneNumber: phoneNumber, timeAdded: timeAdded, contactID: contactID))
                        }
                    }
                }
                else
                {
                    failure!(true)
                }
            }
        }
    }
}
