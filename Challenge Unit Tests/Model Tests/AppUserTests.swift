//
//  AppUserTests.swift
//  Challenge Unit Tests
//
//  Created by Thomas Cartotto on 2018-08-16.
//  Copyright © 2018 com.skipptheline.ios. All rights reserved.
//

import XCTest
import ObjectMapper


@testable import Pods_Prosper_Code_Challenge
@testable import Prosper_Code_Challenge

class AppUserTests: XCTestCase
{
    
    func testEquality()
    {
        let userOne = AppUser(email: nil, userID: nil)
        userOne.userID = "Npcm9x1GAfJKQXATNfBP"
        userOne.email = "mike@gmail.com"
        
        let userTwo = AppUser(email: nil, userID: nil)
        userTwo.userID = "Npcm9x1GAfJKQXATNfBP"
        userTwo.email = "mike@gmail.com"
        
        XCTAssertEqual(userTwo, userOne)
        
        userOne.userID = "Npcm9x1JLOYGDXATNfBP" //Changed
        XCTAssertNotEqual(userOne, userTwo)
    }
    
    func testManualInitilization() // Programatic Initilization
    {
        let testUser = AppUser(email: "mike@gmail.com", userID: "Npcm9x1JLOYGDXATNfBP")
        
        XCTAssertEqual(testUser.email, "mike@gmail.com")
        XCTAssertEqual(testUser.userID, "Npcm9x1JLOYGDXATNfBP")
        
        testUser.email = nil
        
        XCTAssertNil(testUser.email)
        
    }
    
    func testAutomaticInitilization() // Object Mapping from network pull
    {
        guard let user = Mapper<AppUser>().map(JSONObject: loadJSON("AppUserResponse")) else {XCTFail("Did not map properly"); return}
        
        XCTAssertEqual(user.email, "mike@gmail.com")
        XCTAssertEqual(user.userID, "nm31455LudF9hMm2xSEILOgLuh2")
    }
}
