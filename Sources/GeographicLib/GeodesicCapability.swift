//
//  GeodesicCapability.swift
//  GeographicLib
//
//  Created by Scott Hoyt on 6/1/25.
//

import Foundation
import CGeographicLib

/// Capabilities for geodesic line calculations.
///
/// These options control which quantities can be computed by a GeodesicLine object.
public struct GeodesicCapability: OptionSet, Sendable {
    public let rawValue: UInt32
    
    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
    
    /// Calculate latitude
    public static let latitude = GeodesicCapability(rawValue: GEOD_LATITUDE.rawValue)
    
    /// Calculate longitude
    public static let longitude = GeodesicCapability(rawValue: GEOD_LONGITUDE.rawValue)
    
    /// Calculate azimuth
    public static let azimuth = GeodesicCapability(rawValue: GEOD_AZIMUTH.rawValue)
    
    /// Calculate distance
    public static let distance = GeodesicCapability(rawValue: GEOD_DISTANCE.rawValue)
    
    /// Allow distance as input
    public static let distanceIn = GeodesicCapability(rawValue: GEOD_DISTANCE_IN.rawValue)
    
    /// Calculate reduced length
    public static let reducedLength = GeodesicCapability(rawValue: GEOD_REDUCEDLENGTH.rawValue)
    
    /// Calculate geodesic scale
    public static let geodesicScale = GeodesicCapability(rawValue: GEOD_GEODESICSCALE.rawValue)
    
    /// Calculate area
    public static let area = GeodesicCapability(rawValue: GEOD_AREA.rawValue)
    
    /// Calculate everything
    public static let all = GeodesicCapability(rawValue: GEOD_ALL.rawValue)
    
    /// Standard capabilities for direct problem
    public static let standard: GeodesicCapability = [.latitude, .longitude, .azimuth, .distanceIn]
}

/// Flags for geodesic calculations.
public struct GeodesicFlags: OptionSet, Sendable {
    public let rawValue: UInt32
    
    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
    
    /// No flags
    public static let none = GeodesicFlags(rawValue: GEOD_NOFLAGS.rawValue)
    
    /// Position given in terms of arc distance
    public static let arcMode = GeodesicFlags(rawValue: GEOD_ARCMODE.rawValue)
    
    /// Unroll the longitude
    public static let longUnroll = GeodesicFlags(rawValue: GEOD_LONG_UNROLL.rawValue)
}