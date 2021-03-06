//
//  Extensions+HKWorkout.swift
//  HealthKitReporter
//
//  Created by Victor on 25.09.20.
//

import Foundation
import HealthKit

extension HKWorkout: Harmonizable {
    typealias Harmonized = Workout.Harmonized

    func harmonize() throws -> Harmonized {
        let totalEnergyBurnedUnit = HKUnit.largeCalorie()
        guard
            let totalEnergyBurned = self.totalEnergyBurned?.doubleValue(for: totalEnergyBurnedUnit)
        else {
            throw HealthKitError.invalidValue("Invalid totalEnergyBurned value for HKWorkout")
        }
        let totalDistanceUnit = HKUnit.meter()
        guard
            let totalDistance = self.totalDistance?.doubleValue(for: totalDistanceUnit)
        else {
            throw HealthKitError.invalidValue("Invalid totalDistance value for HKWorkout")
        }
        let countUnit = HKUnit.count()
        guard
            let totalSwimmingStrokeCount = self.totalSwimmingStrokeCount?.doubleValue(for: countUnit)
        else {
            throw HealthKitError.invalidValue("Invalid totalDistance value for HKWorkout")
        }
        guard
            let totalFlightsClimbed = self.totalFlightsClimbed?.doubleValue(for: countUnit)
        else {
            throw HealthKitError.invalidValue("Invalid totalDistance value for HKWorkout")
        }
        return Harmonized(
            value: Int(self.workoutActivityType.rawValue),
            totalEnergyBurned: totalEnergyBurned,
            totalEnergyBurnedUnit: totalEnergyBurnedUnit.unitString,
            totalDistance: totalDistance,
            totalDistanceUnit: totalDistanceUnit.unitString,
            totalSwimmingStrokeCount: totalSwimmingStrokeCount,
            totalSwimmingStrokeCountUnit: countUnit.unitString,
            totalFlightsClimbed: totalFlightsClimbed,
            totalFlightsClimbedUnit: countUnit.unitString,
            metadata: self.metadata?.compactMapValues { String(describing: $0 )}
        )
    }
}
