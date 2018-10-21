//
//  Observable+Extension.swift
//  Walkytalky
//
//  Created by 안덕환 on 22/10/2018.
//  Copyright © 2018 sutie. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public protocol OptionalType {
    associatedtype Wrapped
    var value: Wrapped? { get }
}

extension Optional: OptionalType {
    public var value: Wrapped? {
        return self
    }
}

extension ObservableType where E: OptionalType {
    public func filterOptional() -> Observable<E.Wrapped> {
        return self.flatMap { element -> Observable<E.Wrapped> in
            if let value = element.value {
                return Observable<E.Wrapped>.just(value)
            } else {
                return Observable<E.Wrapped>.empty()
            }
        }
    }
}
