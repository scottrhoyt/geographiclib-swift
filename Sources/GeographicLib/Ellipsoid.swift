//
//  Ellipsoid.swift
//  GeographicLib
//
//  Created by Scott Hoyt on 6/1/25.
//

import Foundation

/// A reference ellipsoid for geodesic calculations.
///
/// An ellipsoid is a mathematical model that approximates the shape of the Earth.
/// It is defined by two parameters: the equatorial radius and the flattening.
///
/// The flattening *f* is defined as:
/// ```
/// f = (a - b) / a
/// ```
/// where *a* is the equatorial radius and *b* is the polar radius.
///
/// ## Common Ellipsoids
///
/// Several standard ellipsoids are provided as static properties:
/// - ``wgs84``: The WGS-84 ellipsoid used by GPS
/// - ``gRS80``: The GRS-80 ellipsoid
/// - ``sphere``: A perfect sphere approximation
///
/// ## Example Usage
///
/// ```swift
/// // Use the default WGS-84 ellipsoid
/// let geodesic = Geodesic(.wgs84)
///
/// // Create a custom ellipsoid
/// let customEllipsoid = Ellipsoid(
///     equatorialRadius: 6378000.0,
///     flattening: 1.0/300.0
/// )
/// let customGeodesic = Geodesic(customEllipsoid)
/// ```
public struct Ellipsoid: Hashable, Sendable {
    /// The equatorial radius in meters.
    ///
    /// This is the semi-major axis of the ellipsoid, representing the distance
    /// from the center to the equator.
    public let equatorialRadius: Double
    
    /// The flattening of the ellipsoid.
    ///
    /// The flattening is a measure of how much the ellipsoid deviates from a perfect sphere.
    /// It is defined as `(a - b) / a` where `a` is the equatorial radius and `b` is the polar radius.
    /// A value of 0 indicates a perfect sphere.
    public let flattening: Double
    
    /// The WGS-84 ellipsoid.
    ///
    /// This is the reference ellipsoid used by the Global Positioning System (GPS)
    /// and is the most commonly used ellipsoid for global applications.
    ///
    /// - Equatorial radius: 6,378,137.0 meters
    /// - Flattening: 1/298.257223563
    public static let wgs84 = Ellipsoid(equatorialRadius: 6378137.0, flattening: 1.0 / 298.257223563)
    
    /// The GRS-80 ellipsoid.
    ///
    /// The Geodetic Reference System 1980 ellipsoid is used by many national
    /// geodetic surveys and is very similar to WGS-84.
    ///
    /// - Equatorial radius: 6,378,137.0 meters
    /// - Flattening: 1/298.257222101
    public static let grs80 = Ellipsoid(equatorialRadius: 6378137.0, flattening: 1.0 / 298.257222101)
    
    /// A perfect sphere approximation.
    ///
    /// This represents Earth as a perfect sphere with no flattening.
    /// Useful for simplified calculations where ellipsoidal effects can be ignored.
    ///
    /// - Equatorial radius: 6,371,000.0 meters
    /// - Flattening: 0.0
    public static let sphere = Ellipsoid(equatorialRadius: 6371000.0, flattening: 0.0)
    
    /// Creates a new ellipsoid with the specified parameters.
    ///
    /// - Parameters:
    ///   - equatorialRadius: The equatorial radius in meters (must be positive)
    ///   - flattening: The flattening of the ellipsoid (typically between 0 and 1/150)
    ///
    /// - Note: For a sphere, use a flattening of 0.0
    public init(equatorialRadius: Double, flattening: Double) {
        self.equatorialRadius = equatorialRadius
        self.flattening = flattening
    }
}
