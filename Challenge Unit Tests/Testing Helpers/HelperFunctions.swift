//
//  HelperFunctions.swift
//  Challenge Unit Tests
//
//  Created by Thomas Cartotto on 2018-08-16.
//  Copyright © 2018 com.skipptheline.ios. All rights reserved.
//

import XCTest

fileprivate class HelperFunctions {}

func loadJSON(_ fileName: String) -> [AnyHashable: Any]
{
    let bundle = Bundle(for: HelperFunctions.self)
    let path = bundle.path(forResource: fileName, ofType: "json")!
    let jsonData = try! Data(contentsOf: URL(fileURLWithPath: path))
    let json = try! JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as! [AnyHashable: Any]
    return json
}
