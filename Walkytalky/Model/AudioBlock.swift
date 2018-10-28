//
//  AudioBlock.swift
//  Walkytalky
//
//  Created by thekan on 28/10/2018.
//  Copyright © 2018 sutie. All rights reserved.
//

import Foundation

struct AudioBlock {
    
    enum CodingKeys: String, CodingKey {
        case format = "format"
        case audioData = "audioData:"
    }
    
    var format: [String: Any]
    var audioData: Data
}

extension AudioBlock: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(<#T##value: Bool##Bool#>, forKey: <#T##AudioBlock.CodingKeys#>)
        try container.encode(audioData, forKey: .audioData)
    }
}

