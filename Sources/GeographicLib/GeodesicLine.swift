//
//  GeodesicLine.swift
//  GeographicLib
//
//  Created by Scott Hoyt on 6/1/25.
//

import Foundation
import CGeographicLib

/// A geodesic line representing a path on an ellipsoid.
///
/// This struct represents a geodesic starting at a given point with a given azimuth.
/// It allows for efficient computation of points along the geodesic.
public struct GeodesicLine: Sendable {
    internal var line: geod_geodesicline
    
    // MARK: - Properties
    
    /// Starting latitude in degrees
    public var latitude: Double {
        return line.lat1
    }
    
    /// Starting longitude in degrees
    public var longitude: Double {
        return line.lon1
    }
    
    /// Starting azimuth in degrees
    public var azimuth: Double {
        return line.azi1
    }
    
    /// Distance to reference point in meters (if initialized with a reference point)
    public var distance: Double {
        return line.s13
    }
    
    /// Arc length to reference point in degrees (if initialized with a reference point)
    public var arc: Double {
        return line.a13
    }
    
    /// The capabilities of this geodesic line
    public var capabilities: GeodesicCapability {
        return GeodesicCapability(rawValue: line.caps)
    }
    
    // MARK: - Initialization
    
    /// Initialize a geodesic line.
    ///
    /// - Parameters:
    ///   - geodesic: The geodesic object defining the ellipsoid
    ///   - latitude: Starting latitude in degrees [-90, 90]
    ///   - longitude: Starting longitude in degrees [-180, 180]
    ///   - azimuth: Starting azimuth in degrees [-180, 180]
    ///   - capabilities: Capabilities for calculations (default: standard)
    public init(geodesic: Geodesic, latitude: Double, longitude: Double, azimuth: Double,
                capabilities: GeodesicCapability = .standard) {
        self.line = geod_geodesicline()
        withUnsafePointer(to: geodesic.geod) { geodPtr in
            geod_lineinit(&self.line, geodPtr, latitude, longitude, azimuth, capabilities.rawValue)
        }
    }
    
    // MARK: - Position Methods
    
    /// Result of a position calculation along a geodesic line
    public struct PositionResult {
        /// Latitude of the point in degrees
        public let latitude: Double
        
        /// Longitude of the point in degrees
        public let longitude: Double
        
        /// Forward azimuth at the point in degrees
        public let azimuth: Double
    }
    
    /// Compute a position along the geodesic line.
    ///
    /// - Parameter distance: Distance from the starting point in meters
    /// - Returns: A ``PositionResult`` withm the position and azimuth at the given distance
    public func position(distance: Double) -> PositionResult {
        var latitude: Double = 0
        var longitude: Double = 0
        var azimuth: Double = 0
        
        withUnsafePointer(to: line) { linePtr in
            geod_position(linePtr, distance, &latitude, &longitude, &azimuth)
        }
        
        return PositionResult(latitude: latitude, longitude: longitude, azimuth: azimuth)
    }
    
    /// General position result with additional computed values
    public struct GeneralPositionResult {
        /// Latitude of the point in degrees
        public let latitude: Double
        
        /// Longitude of the point in degrees
        public let longitude: Double
        
        /// Forward azimuth at the point in degrees
        public let azimuth: Double
        
        /// Arc length from point 1 to point 2 in degrees
        public let arc: Double
        
        /// Distance from point 1 to point 2 in meters (if requested)
        public let distance: Double?
        
        /// Reduced length in meters (if requested)
        public let reducedLength: Double?
        
        /// Geodesic scale of point 2 relative to point 1 (if requested)
        public let scale12: Double?
        
        /// Geodesic scale of point 1 relative to point 2 (if requested)
        public let scale21: Double?
        
        /// Area under the geodesic in square meters (if requested)
        public let area: Double?
    }
    
    /// Compute a general position along the geodesic line.
    ///
    /// - Parameters:
    ///   - flags: Flags controlling the calculation
    ///   - distanceOrArc: Distance in meters or arc in degrees depending on flags
    /// - Returns: The position and requested values
    public func generalPosition(flags: GeodesicFlags = .none, distanceOrArc: Double) -> GeneralPositionResult {
        var latitude: Double = 0
        var longitude2: Double = 0
        var azimuth: Double = 0
        var distance: Double = 0
        var reducedLength: Double = 0
        var scale12: Double = 0
        var scale21: Double = 0
        var area: Double = 0
        
        let arc = withUnsafePointer(to: line) { linePtr in
            geod_genposition(linePtr, flags.rawValue, distanceOrArc,
                           &latitude, &longitude2, &azimuth, &distance, &reducedLength, &scale12, &scale21, &area)
        }
        
        return GeneralPositionResult(
            latitude: latitude,
            longitude: longitude2,
            azimuth: azimuth,
            arc: arc,
            distance: capabilities.contains(.distance) ? distance : nil,
            reducedLength: capabilities.contains(.reducedLength) ? reducedLength : nil,
            scale12: capabilities.contains(.geodesicScale) ? scale12 : nil,
            scale21: capabilities.contains(.geodesicScale) ? scale21 : nil,
            area: capabilities.contains(.area) ? area : nil
        )
    }
}

// MARK: - Geodesic Extensions for Creating Lines

public extension Geodesic {
    /// Create a geodesic line for efficient position calculations.
    ///
    /// - Parameters:
    ///   - latitude: Starting latitude in degrees [-90, 90]
    ///   - longitude: Starting longitude in degrees [-180, 180]
    ///   - azimuth: Starting azimuth in degrees [-180, 180]
    ///   - capabilities: Capabilities for calculations
    /// - Returns: A geodesic line object
    func line(latitude: Double, longitude: Double, azimuth: Double,
              capabilities: GeodesicCapability = .standard) -> GeodesicLine {
        return GeodesicLine(geodesic: self, latitude: latitude, longitude: longitude,
                          azimuth: azimuth, capabilities: capabilities)
    }
    
    /// Create a geodesic line from a direct problem.
    ///
    /// - Parameters:
    ///   - latitude: Starting latitude in degrees [-90, 90]
    ///   - longitude: Starting longitude in degrees [-180, 180]
    ///   - azimuth: Starting azimuth in degrees [-180, 180]
    ///   - distance: Distance to reference point in meters
    ///   - capabilities: Capabilities for calculations
    /// - Returns: A geodesic line with the reference point set
    func directLine(latitude: Double, longitude: Double, azimuth: Double, distance: Double,
                    capabilities: GeodesicCapability = .standard) -> GeodesicLine {
        var line = geod_geodesicline()
        withUnsafePointer(to: geod) { geodPtr in
            geod_directline(&line, geodPtr, latitude, longitude, azimuth, distance, capabilities.rawValue)
        }
        
        var result = GeodesicLine(geodesic: self, latitude: latitude, longitude: longitude,
                                azimuth: azimuth, capabilities: capabilities)
        result.line = line
        return result
    }
    
    /// Create a geodesic line from an inverse problem.
    ///
    /// - Parameters:
    ///   - startLatitude: First point latitude in degrees [-90, 90]
    ///   - startLongitude: First point longitude in degrees [-180, 180]
    ///   - endLatitude: Second point latitude in degrees [-90, 90]
    ///   - endLongitude: Second point longitude in degrees [-180, 180]
    ///   - capabilities: Capabilities for calculations
    /// - Returns: A geodesic line connecting the two points
    func inverseLine(
        startLatitude: Double,
        startLongitude: Double,
        endLatitude: Double,
        endLongitude: Double,
        capabilities: GeodesicCapability = .standard
    ) -> GeodesicLine {
        var line = geod_geodesicline()
        withUnsafePointer(to: geod) { geodPtr in
            geod_inverseline(&line, geodPtr, startLatitude, startLongitude, endLatitude, endLongitude, capabilities.rawValue)
        }
        
        var result = GeodesicLine(geodesic: self, latitude: startLatitude, longitude: startLongitude,
                                azimuth: 0, capabilities: capabilities)
        result.line = line
        return result
    }
}

