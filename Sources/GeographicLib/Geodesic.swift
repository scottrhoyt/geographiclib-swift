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
    private var geod: geod_geodesic
    
    // MARK: - Constants
    
    /// WGS-84 equatorial radius in meters
    public static let wgs84EquatorialRadius: Double = 6378137.0
    
    /// WGS-84 flattening
    public static let wgs84Flattening: Double = 1.0/298.257223563
    
    // MARK: - Initialization
    
    /// Initialize with WGS-84 ellipsoid parameters
    public init() {
        self.init(equatorialRadius: Self.wgs84EquatorialRadius, flattening: Self.wgs84Flattening)
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
        public let latitude2: Double
        
        /// Longitude of the destination point in degrees
        public let longitude2: Double
        
        /// Forward azimuth at the destination point in degrees
        public let azimuth2: Double
    }
    
    /// Solve the direct geodesic problem.
    ///
    /// Given a starting point, initial azimuth, and distance, calculate the destination point and final azimuth.
    ///
    /// - Parameters:
    ///   - latitude1: Starting latitude in degrees [-90, 90]
    ///   - longitude1: Starting longitude in degrees [-180, 180]
    ///   - azimuth1: Initial azimuth in degrees [-180, 180]
    ///   - distance: Distance in meters (can be negative)
    /// - Returns: The destination point and final azimuth
    func direct(latitude1: Double, longitude1: Double, azimuth1: Double, distance: Double) -> DirectResult {
        var lat2: Double = 0
        var lon2: Double = 0
        var azi2: Double = 0
        
        withUnsafePointer(to: geod) { geodPtr in
            geod_direct(geodPtr, latitude1, longitude1, azimuth1, distance, &lat2, &lon2, &azi2)
        }
        
        return DirectResult(latitude2: lat2, longitude2: lon2, azimuth2: azi2)
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
        var s12: Double = 0
        var azi1: Double = 0
        var azi2: Double = 0
        
        withUnsafePointer(to: geod) { geodPtr in
            geod_inverse(geodPtr, latitude1, longitude1, latitude2, longitude2, &s12, &azi1, &azi2)
        }
        
        return InverseResult(distance: s12, azimuth1: azi1, azimuth2: azi2)
    }
}

// MARK: - Common Ellipsoids

public extension Geodesic {
    /// WGS-84 ellipsoid (default)
    static let wgs84 = Geodesic()
    
    /// GRS-80 ellipsoid
    static let grs80 = Geodesic(equatorialRadius: 6378137.0, flattening: 1.0/298.257222101)
    
    /// Unit sphere
    static let sphere = Geodesic(equatorialRadius: 6371000.0, flattening: 0.0)
}
