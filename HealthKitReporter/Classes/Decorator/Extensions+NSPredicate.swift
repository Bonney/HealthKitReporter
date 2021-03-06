//
//  Extensions+NSPredicate.swift
//  HealthKitReporter
//
//  Created by Victor on 14.09.20.
//

import Foundation
import HealthKit

public extension NSPredicate {
    static var allSamples: NSPredicate {
        return HKQuery.predicateForSamples(
            withStart: .distantPast,
            end: .distantFuture,
            options: []
        )
    }
    static func samplesPredicate(
        startDate: Date,
        endDate: Date,
        options: HKQueryOptions = [.strictStartDate, .strictEndDate]
    ) -> NSPredicate {
        return HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: options
        )
    }
}
