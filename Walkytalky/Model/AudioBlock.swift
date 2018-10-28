//
//  AudioBlock.swift
//  Walkytalky
//
//  Created by thekan on 28/10/2018.
//  Copyright © 2018 sutie. All rights reserved.
//

import Foundation

struct AudioBlock {
    
    enum Errors: Error {
        case convertJsonError
    }
    
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
        guard let formatJsonString = DictionaryConverter.toJsonString(from: format) else {
            throw Errors.convertJsonError
        }
        try container.encode(formatJsonString, forKey: .format)
        try container.encode(audioData, forKey: .audioData)
    }
}

extension AudioBlock: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.audioData = try container.decode(Data.self, forKey: .audioData)
        let formatJsonString = try container.decode(String.self, forKey: .format)
        self.format = DictionaryConverter.parseFrom(string: formatJsonString) ?? [:]
    }
}

