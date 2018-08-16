//
//  ContactTests.swift
//  Challenge Unit Tests
//
//  Created by Thomas Cartotto on 2018-08-16.
//  Copyright © 2018 com.skipptheline.ios. All rights reserved.
//

import XCTest
import ObjectMapper

@testable import Pods_Prosper_Code_Challenge
@testable import Prosper_Code_Challenge

class ContactTests: XCTestCase
{
    
    func testEquality()
    {
        let contactOne = Contact(avatarURL: nil, fullName: nil, email: nil, phoneNumber: nil, timeAdded: nil, contactID: nil)
        contactOne.contactID = "Npcm9x1GAfJKQXATNfBP"
        contactOne.fullName = "Thomas"
        
        let contactTwo = Contact(avatarURL: nil, fullName: nil, email: nil, phoneNumber: nil, timeAdded: nil, contactID: nil)
        contactTwo.contactID = "Npcm9x1GAfJKQXATNfBP"
        contactTwo.fullName = "Mike"
        
        XCTAssertEqual(contactOne, contactTwo)
        
        contactOne.contactID = "Npcm9x1JLOYGDXATNfBP" //Changed
        XCTAssertNotEqual(contactOne, contactTwo)
    }
    
    func testManualInitilization() // Programatic Initilization
    {
        let testContact = Contact(avatarURL: "test.com", fullName: "Mike", email: "mike@gmail.com", phoneNumber: "(647) 224-3434", timeAdded: 127283.00, contactID: "HDSLDHDKDJDKL78")
        
        XCTAssertEqual(testContact.avatarImageURL, "test.com")
        XCTAssertEqual(testContact.fullName, "Mike")
        XCTAssertEqual(testContact.email, "mike@gmail.com")
        XCTAssertEqual(testContact.phoneNumber, "(647) 224-3434")
        XCTAssertEqual(testContact.timeAdded, 127283.00)
        XCTAssertEqual(testContact.contactID, "HDSLDHDKDJDKL78")
        
        testContact.email = nil
        
        XCTAssertNil(testContact.email)
        
    }
    
    func testAutomaticInitilization() // Object Mapping from network pull
    {
        guard let contact = Mapper<Contact>().map(JSONObject: loadJSON("ContactResponse")) else {XCTFail("Did not map properly"); return}
        
        XCTAssertEqual(contact.email, "mike@gmail.com")
        XCTAssertEqual(contact.contactID, "nm31455LudF9hMm2xSEILOgLuh2")
        XCTAssertEqual(contact.fullName, "Elon Musk")
        XCTAssertEqual(contact.timeAdded, 1534361511)
        XCTAssertEqual(contact.phoneNumber, "(647) 967-1003")
        XCTAssertEqual(contact.avatarImageURL, "https://firebasestorage.googleapis.com/v0/b/prosper-code-challenge.appspot.com/o/Users%2Fnm31wcgDLudF9hMm2xSEILOgLuh2%2FContacts%2FElonMusk-974773054.jpg?alt=media&token=1015b7da-5323-4a6d-a20e-95872e7e84ae")
    }
}
