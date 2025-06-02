//
//  File.swift
//  GeographicLib
//
//  Created by Scott Hoyt on 6/1/25.
//

import Foundation

public struct Ellipsoid: Hashable, Sendable {
    public let equatorialRadius: Double
    public let flattening: Double
    
    public static let wgs84 = Ellipsoid(equatorialRadius: 6378137.0, flattening: 1.0 / 298.257223563)
    public static let gRS80 = Ellipsoid(equatorialRadius: 6378137.0, flattening: 1.0 / 298.257222101)
    public static let sphere = Ellipsoid(equatorialRadius: 6371000.0, flattening: 0.0)
    
    public init(equatorialRadius: Double, flattening: Double) {
        self.equatorialRadius = equatorialRadius
        self.flattening = flattening
    }
}
