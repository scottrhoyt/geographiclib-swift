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
/// - Direct problem: Given a starting point, azimuth, and distance, find the endpoint
/// - Inverse problem: Given two points, find the azimuth and distance between them
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
        /// Latitude of the destination point in degrees
        public let latitude: Double
        
        /// Longitude of the destination point in degrees
        public let longitude: Double
        
        /// Forward azimuth at the destination point in degrees
        public let azimuth: Double
    }
    
    /// Solve the direct geodesic problem.
    ///
    /// Given a starting point, initial azimuth, and distance, calculate the destination point and final azimuth.
    ///
    /// - Parameters:
    ///   - latitude: Starting latitude in degrees [-90, 90]
    ///   - longitude: Starting longitude in degrees [-180, 180]
    ///   - azimuth: Initial azimuth in degrees [-180, 180]
    ///   - distance: Distance in meters (can be negative)
    /// - Returns: The destination point and final azimuth
    func direct(latitude: Double, longitude: Double, azimuth: Double, distance: Double) -> DirectResult {
        var latitude2: Double = 0
        var longitude2: Double = 0
        var azimuth2: Double = 0
        
        withUnsafePointer(to: geod) { geodPtr in
            geod_direct(geodPtr, latitude, longitude, azimuth, distance, &latitude2, &longitude2, &azimuth2)
        }
        
        return DirectResult(latitude: latitude2, longitude: longitude2, azimuth: azimuth2)
    }
}

// MARK: - Inverse Problem

public extension Geodesic {
    /// Result of an inverse geodesic calculation
    struct InverseResult {
        /// Distance between the two points in meters
        public let distance: Double
        
        /// Forward azimuth at the first point in degrees
        public let azimuth1: Double
        
        /// Forward azimuth at the second point in degrees
        public let azimuth2: Double
    }
    
    /// Solve the inverse geodesic problem.
    ///
    /// Given two points, calculate the distance and azimuths between them.
    ///
    /// - Parameters:
    ///   - latitude1: First point latitude in degrees [-90, 90]
    ///   - longitude1: First point longitude in degrees [-180, 180]
    ///   - latitude2: Second point latitude in degrees [-90, 90]
    ///   - longitude2: Second point longitude in degrees [-180, 180]
    /// - Returns: The distance and azimuths between the points
    func inverse(latitude1: Double, longitude1: Double, latitude2: Double, longitude2: Double) -> InverseResult {
        var distance: Double = 0
        var azimuth1: Double = 0
        var azimuth2: Double = 0
        
        withUnsafePointer(to: geod) { geodPtr in
            geod_inverse(geodPtr, latitude1, longitude1, latitude2, longitude2, &distance, &azimuth1, &azimuth2)
        }
        
        return InverseResult(distance: distance, azimuth1: azimuth1, azimuth2: azimuth2)
    }
}
