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
    public var latitude1: Double {
        return line.lat1
    }
    
    /// Starting longitude in degrees
    public var longitude1: Double {
        return line.lon1
    }
    
    /// Starting azimuth in degrees
    public var azimuth1: Double {
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
    ///   - latitude1: Starting latitude in degrees [-90, 90]
    ///   - longitude1: Starting longitude in degrees [-180, 180]
    ///   - azimuth1: Starting azimuth in degrees [-180, 180]
    ///   - capabilities: Capabilities for calculations (default: standard)
    public init(geodesic: Geodesic, latitude1: Double, longitude1: Double, azimuth1: Double, 
                capabilities: GeodesicCapability = .standard) {
        self.line = geod_geodesicline()
        withUnsafePointer(to: geodesic.geod) { geodPtr in
            geod_lineinit(&self.line, geodPtr, latitude1, longitude1, azimuth1, capabilities.rawValue)
        }
    }
    
    // MARK: - Position Methods
    
    /// Result of a position calculation along a geodesic line
    public struct PositionResult {
        /// Latitude of the point in degrees
        public let latitude2: Double
        
        /// Longitude of the point in degrees
        public let longitude2: Double
        
        /// Forward azimuth at the point in degrees
        public let azimuth2: Double
    }
    
    /// Compute a position along the geodesic line.
    ///
    /// - Parameter distance: Distance from the starting point in meters
    /// - Returns: The position and azimuth at the given distance
    public func position(distance: Double) -> PositionResult {
        var lat2: Double = 0
        var lon2: Double = 0
        var azi2: Double = 0
        
        withUnsafePointer(to: line) { linePtr in
            geod_position(linePtr, distance, &lat2, &lon2, &azi2)
        }
        
        return PositionResult(latitude2: lat2, longitude2: lon2, azimuth2: azi2)
    }
    
    /// General position result with additional computed values
    public struct GeneralPositionResult {
        /// Latitude of the point in degrees
        public let latitude2: Double
        
        /// Longitude of the point in degrees
        public let longitude2: Double
        
        /// Forward azimuth at the point in degrees
        public let azimuth2: Double
        
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
        var lat2: Double = 0
        var lon2: Double = 0
        var azi2: Double = 0
        var s12: Double = 0
        var m12: Double = 0
        var M12: Double = 0
        var M21: Double = 0
        var S12: Double = 0
        
        let a12 = withUnsafePointer(to: line) { linePtr in
            geod_genposition(linePtr, flags.rawValue, distanceOrArc,
                           &lat2, &lon2, &azi2, &s12, &m12, &M12, &M21, &S12)
        }
        
        return GeneralPositionResult(
            latitude2: lat2,
            longitude2: lon2,
            azimuth2: azi2,
            arc: a12,
            distance: capabilities.contains(.distance) ? s12 : nil,
            reducedLength: capabilities.contains(.reducedLength) ? m12 : nil,
            scale12: capabilities.contains(.geodesicScale) ? M12 : nil,
            scale21: capabilities.contains(.geodesicScale) ? M21 : nil,
            area: capabilities.contains(.area) ? S12 : nil
        )
    }
}

// MARK: - Geodesic Extensions for Creating Lines

public extension Geodesic {
    /// Create a geodesic line for efficient position calculations.
    ///
    /// - Parameters:
    ///   - latitude1: Starting latitude in degrees [-90, 90]
    ///   - longitude1: Starting longitude in degrees [-180, 180]
    ///   - azimuth1: Starting azimuth in degrees [-180, 180]
    ///   - capabilities: Capabilities for calculations
    /// - Returns: A geodesic line object
    func line(latitude1: Double, longitude1: Double, azimuth1: Double,
              capabilities: GeodesicCapability = .standard) -> GeodesicLine {
        return GeodesicLine(geodesic: self, latitude1: latitude1, longitude1: longitude1,
                          azimuth1: azimuth1, capabilities: capabilities)
    }
    
    /// Create a geodesic line from a direct problem.
    ///
    /// - Parameters:
    ///   - latitude1: Starting latitude in degrees [-90, 90]
    ///   - longitude1: Starting longitude in degrees [-180, 180]
    ///   - azimuth1: Starting azimuth in degrees [-180, 180]
    ///   - distance: Distance to reference point in meters
    ///   - capabilities: Capabilities for calculations
    /// - Returns: A geodesic line with the reference point set
    func directLine(latitude1: Double, longitude1: Double, azimuth1: Double, distance: Double,
                    capabilities: GeodesicCapability = .standard) -> GeodesicLine {
        var line = geod_geodesicline()
        withUnsafePointer(to: geod) { geodPtr in
            geod_directline(&line, geodPtr, latitude1, longitude1, azimuth1, distance, capabilities.rawValue)
        }
        
        var result = GeodesicLine(geodesic: self, latitude1: latitude1, longitude1: longitude1,
                                azimuth1: azimuth1, capabilities: capabilities)
        result.line = line
        return result
    }
    
    /// Create a geodesic line from an inverse problem.
    ///
    /// - Parameters:
    ///   - latitude1: First point latitude in degrees [-90, 90]
    ///   - longitude1: First point longitude in degrees [-180, 180]
    ///   - latitude2: Second point latitude in degrees [-90, 90]
    ///   - longitude2: Second point longitude in degrees [-180, 180]
    ///   - capabilities: Capabilities for calculations
    /// - Returns: A geodesic line connecting the two points
    func inverseLine(latitude1: Double, longitude1: Double, latitude2: Double, longitude2: Double,
                     capabilities: GeodesicCapability = .standard) -> GeodesicLine {
        var line = geod_geodesicline()
        withUnsafePointer(to: geod) { geodPtr in
            geod_inverseline(&line, geodPtr, latitude1, longitude1, latitude2, longitude2, capabilities.rawValue)
        }
        
        var result = GeodesicLine(geodesic: self, latitude1: latitude1, longitude1: longitude1,
                                azimuth1: 0, capabilities: capabilities)
        result.line = line
        return result
    }
}

