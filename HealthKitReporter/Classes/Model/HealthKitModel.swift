//
//  Model.swift
//  HealthKitReporter
//
//  Created by Florian on 14.09.20.
//

import Foundation
import HealthKit

public protocol Sample: Codable {
    var identifier: String { get }
}

public struct Statistics: Sample {
    public let identifier: String
    public let startDate: String
    public let endDate: String
    public let harmonized: HKStatistics.Harmonized
    public let sources: [Source]?

    public init(statistics: HKStatistics) throws {
        self.identifier = statistics.quantityType.identifier
        self.startDate = statistics.startDate.formatted(
            with: Date.yyyyMMddTHHmmssZZZZZ
        )
        self.endDate = statistics.endDate.formatted(
            with: Date.yyyyMMddTHHmmssZZZZZ
        )
        self.sources = statistics.sources?.map { Source(source: $0 )}
        self.harmonized = try statistics.harmonize()
    }
}

public struct HeartbeatSerie: Codable {
    public let ibiArray: [Double]
    public let indexArray: [Int]
}

public struct ActivitySummary: Sample {
    public let identifier: String
    public let date: String?
    public let harmonized: HKActivitySummary.Harmonized

    public init(activitySummary: HKActivitySummary) throws {
        self.identifier = HealthKitType
            .activitySummary
            .rawValue?
            .identifier ?? "HKActivitySummaryType"
        self.date = activitySummary
            .dateComponents(for: Calendar.current)
            .date?
            .formatted(with: Date.yyyyMMddTHHmmssZZZZZ)
        self.harmonized = try activitySummary.harmonize()
    }
}

public struct Quantitiy: Sample {
    public let identifier: String
    public let startDate: String
    public let endDate: String
    public let device: Device?
    public let sourceRevision: SourceRevision
    public let harmonized: HKQuantitySample.Harmonized

    public init(quantitySample: HKQuantitySample) throws {
        self.identifier = quantitySample.quantityType.identifier
        self.startDate = quantitySample.startDate.formatted(
            with: Date.yyyyMMddTHHmmssZZZZZ
        )
        self.endDate = quantitySample.endDate.formatted(
            with: Date.yyyyMMddTHHmmssZZZZZ
        )
        self.device = Device(device: quantitySample.device)
        self.sourceRevision = SourceRevision(sourceRevision: quantitySample.sourceRevision)
        self.harmonized = try quantitySample.harmonize()
    }
}
public struct Category: Sample {
    public let identifier: String
    public let startDate: String
    public let endDate: String
    public let device: Device?
    public let sourceRevision: SourceRevision
    public let harmonized: HKCategorySample.Harmonized

    public init(categorySample: HKCategorySample) throws {
        self.identifier = categorySample.categoryType.identifier
        self.startDate = categorySample.startDate.formatted(
            with: Date.yyyyMMddTHHmmssZZZZZ
        )
        self.endDate = categorySample.endDate.formatted(
            with: Date.yyyyMMddTHHmmssZZZZZ
        )
        self.device = Device(device: categorySample.device)
        self.sourceRevision = SourceRevision(sourceRevision: categorySample.sourceRevision)
        self.harmonized = try categorySample.harmonize()
    }

    func asOriginal() throws -> HKCategorySample {
        guard let type = HKObjectType.categoryType(
            forIdentifier: HKCategoryTypeIdentifier(rawValue: identifier)
        ) else {
            throw HealthKitError.invalidType(
                "Category type identifier: \(identifier) could not be foramtted"
            )
        }
        guard
            let start = startDate.asDate(format: Date.yyyyMMddTHHmmssZZZZZ),
            let end = endDate.asDate(format: Date.yyyyMMddTHHmmssZZZZZ)
        else {
            throw HealthKitError.invalidValue(
                "Category start: \(startDate) and end: \(endDate) could not be formatted"
            )
        }
        return HKCategorySample(
            type: type,
            value: harmonized.value,
            start: start,
            end: end,
            device: device?.asOriginal(),
            metadata: harmonized.metadata
        )
    }

}
@available(iOS 14.0, *)
public struct Electrocardiogram: Sample {
    public let identifier: String
    public let startDate: String
    public let endDate: String
    public let device: Device?
    public let sourceRevision: SourceRevision
    public let numberOfMeasurements: Int
    public let harmonized: HKElectrocardiogram.Harmonized

    public init(electrocardiogram: HKElectrocardiogram) throws {
        self.identifier = HealthKitType
            .electrocardiogramType
            .rawValue?
            .identifier ?? "HKElectrocardiogram"
        self.startDate = electrocardiogram.startDate.formatted(
            with: Date.yyyyMMddTHHmmssZZZZZ
        )
        self.endDate = electrocardiogram.endDate.formatted(
            with: Date.yyyyMMddTHHmmssZZZZZ
        )
        self.device = Device(device: electrocardiogram.device)
        self.numberOfMeasurements = electrocardiogram.numberOfVoltageMeasurements
        self.sourceRevision = SourceRevision(sourceRevision: electrocardiogram.sourceRevision)
        self.harmonized = try electrocardiogram.harmonize()
    }
}
public struct Characteristics: Codable {
    public let biologicalSex: String
    public let birthday: String?
    public let bloodType: String
    public let skinType: String

    public init(
        biologicalSex: HKBiologicalSexObject,
        birthday: DateComponents,
        bloodType: HKBloodTypeObject,
        skinType: HKFitzpatrickSkinTypeObject
    ) {
        self.biologicalSex = biologicalSex.biologicalSex.string
        self.birthday = birthday.date?.formatted(with: Date.yyyyMMdd)
        self.bloodType = bloodType.bloodType.string
        self.skinType = skinType.skinType.string
    }
}
public struct Source: Codable {
    public let name: String
    public let bundleIdentifier: String

    public init(source: HKSource) {
        self.name = source.name
        self.bundleIdentifier = source.bundleIdentifier
    }
}
public struct Device: Codable {
    public let name: String?
    public let manufacturer: String?
    public let model: String?
    public let hardwareVersion: String?
    public let firmwareVersion: String?
    public let softwareVersion: String?
    public let localIdentifier: String?
    public let udiDeviceIdentifier: String?

    public init(device: HKDevice?) {
        self.name = device?.name
        self.manufacturer = device?.manufacturer
        self.model = device?.model
        self.hardwareVersion = device?.hardwareVersion
        self.firmwareVersion = device?.firmwareVersion
        self.softwareVersion = device?.softwareVersion
        self.localIdentifier = device?.localIdentifier
        self.udiDeviceIdentifier = device?.udiDeviceIdentifier
    }

    func asOriginal() -> HKDevice {
        return HKDevice(
            name: name,
            manufacturer: manufacturer,
            model: model,
            hardwareVersion: hardwareVersion,
            firmwareVersion: firmwareVersion,
            softwareVersion: softwareVersion,
            localIdentifier: localIdentifier,
            udiDeviceIdentifier: udiDeviceIdentifier
        )
    }
}
public struct SourceRevision: Codable {
    public let source: Source
    public let version: String?
    public let productType: String?
    public let systemVersion: String

    public init(sourceRevision: HKSourceRevision) {
        self.source = Source(source: sourceRevision.source)
        self.version = sourceRevision.version
        self.productType = sourceRevision.productType
        self.systemVersion = sourceRevision.systemVersion
    }
}
public struct Correlation: Sample {
    public let identifier: String
    public let harmonized: HKCorrelation.Harmonized

    public init(correlation: HKCorrelation) throws {
        self.identifier = correlation.correlationType.identifier
        self.harmonized = try correlation.harmonize()
    }
}
public struct Workout: Sample {
    public let identifier: String
    public let startDate: String
    public let endDate: String
    public let workoutName: String
    public let device: Device?
    public let sourceRevision: SourceRevision
    public let duration: Double
    public let workoutEvents: [WorkoutEvent]
    public let harmonized: HKWorkout.Harmonized

    public init(workout: HKWorkout) throws {
        self.identifier = workout.sampleType.identifier
        self.startDate = workout.startDate.formatted(
            with: Date.yyyyMMddTHHmmssZZZZZ
        )
        self.endDate = workout.endDate.formatted(
            with: Date.yyyyMMddTHHmmssZZZZZ
        )
        self.device = Device(device: workout.device)
        self.sourceRevision = SourceRevision(sourceRevision: workout.sourceRevision)
        self.workoutName = String(describing: workout.workoutActivityType)
        self.duration = workout.duration
        var workoutEvents = [WorkoutEvent]()
        if let events = workout.workoutEvents {
            for element in events {
                do {
                    let workoutEvent = try WorkoutEvent(workoutEvent: element)
                    workoutEvents.append(workoutEvent)
                } catch {
                    continue
                }
            }
        }
        self.workoutEvents = workoutEvents
        self.harmonized = try workout.harmonize()
    }

    func asOriginal() throws -> HKWorkout {
        guard let activityType = HKWorkoutActivityType(rawValue: UInt(harmonized.value)) else {
            throw HealthKitError.invalidType(
                "Workout type: \(harmonized.value) could not be foramtted"
            )
        }
        guard
            let start = startDate.asDate(format: Date.yyyyMMddTHHmmssZZZZZ),
            let end = endDate.asDate(format: Date.yyyyMMddTHHmmssZZZZZ)
        else {
            throw HealthKitError.invalidValue(
                "Category start: \(startDate) and end: \(endDate) could not be formatted"
            )
        }
        return HKWorkout(
            activityType: activityType,
            start: start,
            end: end,
            workoutEvents: try workoutEvents.map({ try $0.asOriginal() }),
            totalEnergyBurned: harmonized.totalEnergyBurned != nil
                ? HKQuantity(
                    unit: HKUnit.init(from: harmonized.totalEnergyBurnedUnit),
                    doubleValue: harmonized.totalEnergyBurned!
                )
                : nil,
            totalDistance: harmonized.totalDistance != nil
                ? HKQuantity(
                    unit: HKUnit.init(from: harmonized.totalDistanceUnit),
                    doubleValue: harmonized.totalDistance!
                )
                : nil,
            totalSwimmingStrokeCount: harmonized.totalSwimmingStrokeCount != nil
                ? HKQuantity(
                    unit: HKUnit.init(from: harmonized.totalSwimmingStrokeCountUnit),
                    doubleValue: harmonized.totalSwimmingStrokeCount!
                )
                : nil,
            device: device?.asOriginal(),
            metadata: harmonized.metadata
        )
    }
}
public struct WorkoutEvent: Codable {
    public let type: String
    public let startDate: String
    public let endDate: String
    public let duration: Double
    public let harmonized: HKWorkoutEvent.Harmonized

    public init(workoutEvent: HKWorkoutEvent) throws {
        self.type = String(describing: workoutEvent.type)
        self.startDate = workoutEvent
            .dateInterval
            .start
            .formatted(with: Date.yyyyMMddTHHmmssZZZZZ)
        self.endDate = workoutEvent
            .dateInterval
            .end
            .formatted(with: Date.yyyyMMddTHHmmssZZZZZ)
        self.duration = workoutEvent.dateInterval.duration
        self.harmonized = try workoutEvent.harmonize()
    }

    func asOriginal() throws -> HKWorkoutEvent {
        guard let type = HKWorkoutEventType(rawValue: harmonized.value) else {
            throw HealthKitError.invalidType(
                "WorkoutEvent type: \(harmonized.value) could not be foramtted"
            )
        }
        guard
            let start = startDate.asDate(format: Date.yyyyMMddTHHmmssZZZZZ),
            let end = endDate.asDate(format: Date.yyyyMMddTHHmmssZZZZZ)
        else {
            throw HealthKitError.invalidValue(
                "WorkoutEvent start: \(startDate) and end: \(endDate) could not be formatted"
            )
        }
        return HKWorkoutEvent(
            type: type,
            dateInterval: DateInterval(start: start, end: end),
            metadata: harmonized.metadata
        )
    }
}