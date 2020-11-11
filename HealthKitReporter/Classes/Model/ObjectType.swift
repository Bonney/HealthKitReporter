//
//  ObjectType.swift
//  HealthKitReporter
//
//  Created by Florian on 05.10.20.
//

import Foundation
import HealthKit

public protocol ObjectType {
    associatedtype SampleType where SampleType: HKObjectType
    /**
     Represents type as an original **HKObjectType**
     */
    var original: SampleType? { get }
    /**
     Extracts an original identifier
     */
    var identifier: String? { get }
}

public extension ObjectType {
    /**
     Makes an **ObjectType** based on it's identifier.
     - Parameter identifier: **String** identifier of the **ObjectType**
     */
    static func make(from identifier: String) throws -> Self where Self: CaseIterable {
        let first = Self.allCases.first { identifier == $0.identifier }
        guard let result = first else {
            throw HealthKitError.invalidIdentifier("Invalid identifier: \(identifier)")
        }
        return result
    }
}
