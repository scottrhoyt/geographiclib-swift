//
//  Geodesic.swift
//  GeographicLib
//
//  Created by Scott Hoyt on 6/1/25.
//

import Foundation
import CGeographicLib

/// A geodesic (shortest path) on an ellipsoid of revolution.
///
/// This struct provides methods for solving various geodesic problems:
/// - **Direct problem**: Given a starting point, azimuth, and distance, find the end point
/// - **Inverse problem**: Given two points, find the azimuth and distance between them
///
/// The default ellipsoid is WGS-84, but custom ellipsoids can be specified.
public struct Geodesic: Sendable {
    internal var geod: geod_geodesic
    
    // MARK: - Initialization
    
    /// Initialize with an ``Ellipsoid``, WGS-84 by default
    public init(_ ellipsoid: Ellipsoid = .wgs84) {
        self.init(equatorialRadius: ellipsoid.equatorialRadius, flattening: ellipsoid.flattening)
    }
    
    /// Initialize with custom ellipsoid parameters
    /// - Parameters:
    ///   - equatorialRadius: The equatorial radius in meters
    ///   - flattening: The flattening of the ellipsoid
    public init(equatorialRadius: Double, flattening: Double) {
        self.geod = geod_geodesic()
        geod_init(&self.geod, equatorialRadius, flattening)
    }
    
    // MARK: - Properties
    
    /// The equatorial radius of the ellipsoid in meters
    public var equatorialRadius: Double {
        return geod.a
    }
    
    /// The flattening of the ellipsoid
    public var flattening: Double {
        return geod.f
    }
}

// MARK: - Direct Problem

public extension Geodesic {
    /// Result of a direct geodesic calculation
    struct DirectResult {
        /// Latitude of the end point in degrees
        public let latitude: Double
        
        /// Longitude of the end point in degrees
        public let longitude: Double
        
        /// Forward azimuth at the end point in degrees
        public let azimuth: Double
    }
    
    /// Solve the direct geodesic problem.
    ///
    /// Given a starting point, initial azimuth, and distance, calculate the end point and final azimuth.
    ///
    /// - Parameters:
    ///   - latitude: Starting latitude in degrees [-90, 90]
    ///   - longitude: Starting longitude in degrees [-180, 180]
    ///   - azimuth: Initial azimuth in degrees [-180, 180]
    ///   - distance: Distance in meters (can be negative)
    /// - Returns: A ``DirectResult`` containing the end point data.
    func direct(latitude: Double, longitude: Double, azimuth: Double, distance: Double) -> DirectResult {
        var endLatitude: Double = 0
        var endLongitude: Double = 0
        var endAzimuth: Double = 0
        
        withUnsafePointer(to: geod) { geodPtr in
            geod_direct(
                geodPtr,
                latitude,
                longitude,
                azimuth,
                distance,
                &endLatitude,
                &endLongitude,
                &endAzimuth
            )
        }
        
        return DirectResult(
            latitude: endLatitude,
            longitude: endLongitude,
            azimuth: endAzimuth
        )
    }
}

// MARK: - Inverse Problem

public extension Geodesic {
    /// Result of an inverse geodesic calculation
    struct InverseResult {
        /// Distance between the two points in meters
        public let distance: Double
        
        /// Forward azimuth at the start point in degrees, [-180, 180]
        public let startAzimuth: Double
        
        /// Forward azimuth at the end point in degrees, [-180, 180]
        public let endAzimuth: Double
    }
    
    /// Solve the inverse geodesic problem.
    ///
    /// Given two points, calculate the distance and azimuths between them.
    ///
    /// - Parameters:
    ///   - startLatitude: First point latitude in degrees [-90, 90]
    ///   - startLongitude: First point longitude in degrees [-180, 180]
    ///   - endLatitude: Second point latitude in degrees [-90, 90]
    ///   - endLongitude: Second point longitude in degrees [-180, 180]
    /// - Returns: An ``InverseResult`` containing information about the geodesic
    func inverse(startLatitude: Double, startLongitude: Double, endLatitude: Double, endLongitude: Double) -> InverseResult {
        var distance: Double = 0
        var startAzimuth: Double = 0
        var endAzimuth: Double = 0
        
        withUnsafePointer(to: geod) { geodPtr in
            geod_inverse(geodPtr, startLatitude, startLongitude, endLatitude, endLongitude, &distance, &startAzimuth, &endAzimuth)
        }
        
        return InverseResult(distance: distance, startAzimuth: startAzimuth, endAzimuth: endAzimuth)
    }
}
