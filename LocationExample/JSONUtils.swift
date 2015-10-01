//
//  JSONUtils.swift
//  LocationExample
//
//  Created by Axel Rivera on 9/26/15.
//  Copyright © 2015 Axel Rivera. All rights reserved.
//

import Foundation

import SwiftyJSON

func writeObjectAsJSON(object: AnyObject, filePath: String) {
    let json = JSON(object)
    writeJSON(json, filePath: filePath)
}

func writeJSON(json: JSON, filePath: String) {
    if let string = json.rawString(NSUTF8StringEncoding, options: []) {
        do {
            try string.writeToFile(filePath, atomically: true, encoding: NSUTF8StringEncoding)
        } catch {
            // Do Nothing
        }
    }
}

func readJSONFromFilePath(filePath: String) -> JSON? {
    var json: JSON?
    
    if let data = NSData(contentsOfFile: filePath) {
        var error: NSError?
        let jsonInFile = JSON(data: data, options: .AllowFragments, error: &error)
        if error == nil {
            json = jsonInFile
        }
    }
    
    return json
}