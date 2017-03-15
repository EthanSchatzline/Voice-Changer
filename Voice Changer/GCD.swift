//
//  GCD.swift
//  Voice Changer
//
//  Created by Ethan Schatzline on 3/14/17.
//  Copyright © 2017 ES Interactive. All rights reserved.
//

import Foundation

func executeOnMainThread(_ closure: @escaping (() -> Void)) {
    DispatchQueue.main.async {
        closure()
    }
}
