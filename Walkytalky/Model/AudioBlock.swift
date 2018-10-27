//
//  AudioBlock.swift
//  Walkytalky
//
//  Created by thekan on 28/10/2018.
//  Copyright © 2018 sutie. All rights reserved.
//

import Foundation

class AudioBlock: Codable {
    var format: [String: String]
    var audioData: Data
    
    required init?(coder aDecoder: NSCoder) {
        self.format = aDecoder.decodeObject(forKey: "format") as? 
    }
}
