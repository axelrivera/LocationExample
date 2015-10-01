//
//  FileUtils.swift
//  LocationExample
//
//  Created by Axel Rivera on 9/26/15.
//  Copyright © 2015 Axel Rivera. All rights reserved.
//

import Foundation

func pathInDocumentsDirectory(fileName: String) -> String {
    var documentStr = String()
    
    let document = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
    if !document.isEmpty {
        documentStr = (document[0] as NSString).stringByAppendingPathComponent(fileName)
    }
    
    return documentStr
}

func deletePathInDocumentDirectory(fileName: String) -> Bool {
    let filePath = pathInDocumentsDirectory(fileName)
    do {
        try NSFileManager.defaultManager().removeItemAtPath(filePath)
        return true
    } catch {
        return false
    }
}
