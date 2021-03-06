//
//  SourceRevision.swift
//  HealthKitReporter
//
//  Created by Victor on 25.09.20.
//

import Foundation
import HealthKit

public struct SourceRevision: Codable {
    public struct OperatingSystem: Codable {
        public let majorVersion: Int
        public let minorVersion: Int
        public let patchVersion: Int

        var original: OperatingSystemVersion {
            return OperatingSystemVersion(
                majorVersion: majorVersion,
                minorVersion: minorVersion,
                patchVersion: patchVersion
            )
        }

        init(version: OperatingSystemVersion) {
            self.majorVersion = version.majorVersion
            self.minorVersion = version.minorVersion
            self.patchVersion = version.patchVersion
        }

        public init(
            majorVersion: Int,
            minorVersion: Int,
            patchVersion: Int
        ) {
            self.majorVersion = majorVersion
            self.minorVersion = minorVersion
            self.patchVersion = patchVersion
        }
    }

    public let source: Source
    public let version: String?
    public let productType: String?
    public let systemVersion: String
    public let operatingSystem: OperatingSystem

    init(sourceRevision: HKSourceRevision) {
        self.source = Source(source: sourceRevision.source)
        self.version = sourceRevision.version
        self.productType = sourceRevision.productType
        self.systemVersion = sourceRevision.systemVersion
        self.operatingSystem = OperatingSystem(
            version: sourceRevision.operatingSystemVersion
        )
    }

    public init(
        source: Source,
        version: String?,
        productType: String?,
        systemVersion: String,
        operatingSystem: OperatingSystem
    ) {
        self.source = source
        self.version = version
        self.productType = productType
        self.systemVersion = systemVersion
        self.operatingSystem = operatingSystem
    }
}
// MARK: - Original
extension SourceRevision: Original {
    func asOriginal() throws -> HKSourceRevision {
        return HKSourceRevision(
            source: try source.asOriginal(),
            version: version,
            productType: productType,
            operatingSystemVersion: operatingSystem.original
        )
    }
}
// MARK: - Payload
extension SourceRevision.OperatingSystem: Payload {
    public static func make(
        from dictionary: [String: Any]
    ) throws -> SourceRevision.OperatingSystem {
        guard
            let majorVersion = (dictionary["majorVersion"] as? String)?.integer,
            let minorVersion = (dictionary["minorVersion"] as? String)?.integer,
            let patchVersion = (dictionary["patchVersion"] as? String)?.integer
        else {
            throw HealthKitError.invalidValue("Invalid dictionary: \(dictionary)")
        }
        return SourceRevision.OperatingSystem(
            majorVersion: majorVersion,
            minorVersion: minorVersion,
            patchVersion: patchVersion
        )
    }
}
// MARK: - Payload
extension SourceRevision: Payload {
    public static func make(
        from dictionary: [String: Any]
    ) throws -> SourceRevision {
        guard
            let systemVersion = dictionary["systemVersion"] as? String
        else {
            throw HealthKitError.invalidValue("Invalid dictionary: \(dictionary)")
        }
        let source = try Source.make(from: dictionary)
        let version = dictionary["version"] as? String
        let productType = dictionary["productType"] as? String
        let operatingSystem = try OperatingSystem.make(from: dictionary)
        return SourceRevision(
            source: source,
            version: version,
            productType: productType,
            systemVersion: systemVersion,
            operatingSystem: operatingSystem
        )
    }
}
