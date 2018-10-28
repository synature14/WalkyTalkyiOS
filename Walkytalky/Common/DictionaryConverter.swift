//
//  DictionaryConverter.swift
//  Walkytalky
//
//  Created by thekan on 28/10/2018.
//  Copyright © 2018 sutie. All rights reserved.
//

import Foundation
import RxSwift

class DictionaryConverter {
    static func parseFrom(data: Data) -> Observable<[String: Any]> {
        do {
            let dictionary = try JSONSerialization.jsonObject(
                with: data,
                options: .allowFragments) as? [String: Any] ?? [:]
            return .just(dictionary)
        } catch let error {
            return .error(error)
        }
    }
    
    static func parseFrom(data: Data) -> [String: Any]? {
        guard let dictionary = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            return nil
        }
        return dictionary
    }
    
    static func parseFrom(string: String) -> [String: Any]? {
        guard
            let jsonData = try? JSONSerialization.data(withJSONObject: string, options: .prettyPrinted),
            let dictionary = try? JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [String: Any] else {
                return nil
        }
        return dictionary
    }
    
    static func toJsonString(from dictionary: [String: Any]) -> String? {
        guard
            JSONSerialization.isValidJSONObject(dictionary),
            let jsonData = try? JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted),
            let json = String(data: jsonData, encoding: .utf8) else {
                return nil
        }
        return json
    }
}
