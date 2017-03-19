//
//  FileManager+RemoveFile.swift
//  Voice Changer
//
//  Created by Ethan Schatzline on 3/18/17.
//  Copyright © 2017 ES Interactive. All rights reserved.
//

import Foundation

extension FileManager {
    class func removeFileAtURLIfNeeded(url: URL) {
        let path = url.path
        if FileManager.default.fileExists(atPath: path) {
            do {
                try FileManager.default.removeItem(atPath: path)
            } catch {
                print("ERROR REMOVING: \(error)")
            }
        }
    }
}
