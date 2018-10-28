//
//  Dictionary+Extension.swift
//  Walkytalky
//
//  Created by thekan on 28/10/2018.
//  Copyright © 2018 sutie. All rights reserved.
//

import Foundation
import RxSwift

extension Dictionary where Key: Hashable, Value: Any {
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
}
