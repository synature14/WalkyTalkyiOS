//
//  Dictionary+Extension.swift
//  Walkytalky
//
//  Created by thekan on 28/10/2018.
//  Copyright © 2018 sutie. All rights reserved.
//

import Foundation
import RxSwift

extension Dictionary {
    func toJsonString() -> Observable<String> {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            let json = String(data: jsonData, encoding: .utf8) ?? ""
            return .just(json)
        } catch let error {
            return .error(error)
        }
    }
    
    func toJsonString() -> String? {
        guard
            let jsonData = try? JSONSerialization.data(withJSONObject: self, options: .prettyPrinted),
            let json = String(data: jsonData, encoding: .utf8) else {
                return nil
        }
        return json
    }
    
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
}
