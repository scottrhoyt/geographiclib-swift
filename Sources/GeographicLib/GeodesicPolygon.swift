//
//  GeodesicPolygon.swift
//  GeographicLib
//
//  Created by Scott Hoyt on 6/1/25.
//

import Foundation
import CGeographicLib

/// A geodesic polygon for computing perimeter and area.
///
/// This struct accumulates vertices and edges to compute the perimeter and area
/// of a geodesic polygon on an ellipsoid.
public struct GeodesicPolygon: Sendable {
    private var polygon: geod_polygon
    private let geodesic: Geodesic
    private let isPolyline: Bool
    
    // MARK: - Properties
    
    /// The number of points added so far
    public var pointCount: Int {
        return Int(polygon.num)
    }
    
    /// Current latitude in degrees
    public var currentLatitude: Double {
        return polygon.lat
    }
    
    /// Current longitude in degrees
    public var currentLongitude: Double {
        return polygon.lon
    }
    
    // MARK: - Initialization
    
    /// Initialize a polygon or polyline.
    ///
    /// - Parameters:
    ///   - geodesic: The geodesic object defining the ellipsoid (default: WGS-84)
    ///   - polyline: If true, creates a polyline (no area calculation); if false, creates a polygon
    public init(geodesic: Geodesic = Geodesic(.wgs84), polyline: Bool = false) {
        self.geodesic = geodesic
        self.isPolyline = polyline
        self.polygon = geod_polygon()
        geod_polygon_init(&self.polygon, polyline ? 1 : 0)
    }
    
    // MARK: - Mutation Methods
    
    /// Add a point to the polygon.
    ///
    /// - Parameters:
    ///   - latitude: Latitude in degrees [-90, 90]
    ///   - longitude: Longitude in degrees [-180, 180]
    public mutating func addPoint(latitude: Double, longitude: Double) {
        withUnsafePointer(to: geodesic.geod) { geodPtr in
            geod_polygon_addpoint(geodPtr, &polygon, latitude, longitude)
        }
    }
    
    /// Add an edge to the polygon.
    ///
    /// - Parameters:
    ///   - azimuth: Azimuth at current point in degrees
    ///   - distance: Distance to next point in meters
    public mutating func addEdge(azimuth: Double, distance: Double) {
        withUnsafePointer(to: geodesic.geod) { geodPtr in
            geod_polygon_addedge(geodPtr, &polygon, azimuth, distance)
        }
    }
    
    /// Clear the polygon, allowing a new polygon to be started.
    public mutating func clear() {
        geod_polygon_clear(&polygon)
    }
    
    // MARK: - Computation Methods
    
    /// Result of polygon computation
    public struct ComputeResult {
        /// Area of the polygon in square meters (nil for polylines)
        public let area: Double?
        
        /// Perimeter of the polygon or length of the polyline in meters
        public let perimeter: Double
        
        /// Number of points in the polygon
        public let pointCount: Int
    }
    
    /// Compute the area and perimeter of the polygon.
    ///
    /// - Parameters:
    ///   - reverse: If true, clockwise traversal counts as positive area
    ///   - sign: If true, return signed area; if false, return area of the rest of earth for wrong direction
    /// - Returns: The area (if polygon) and perimeter
    public func compute(reverse: Bool = false, sign: Bool = true) -> ComputeResult {
        var area: Double = 0
        var perimeter: Double = 0
        
        let count = withUnsafePointer(to: geodesic.geod) { geodPtr in
            withUnsafePointer(to: polygon) { polyPtr in
                if isPolyline {
                    return geod_polygon_compute(geodPtr, polyPtr, reverse ? 1 : 0, sign ? 1 : 0,
                                              nil, &perimeter)
                } else {
                    return geod_polygon_compute(geodPtr, polyPtr, reverse ? 1 : 0, sign ? 1 : 0,
                                              &area, &perimeter)
                }
            }
        }
        
        return ComputeResult(
            area: isPolyline ? nil : area,
            perimeter: perimeter,
            pointCount: Int(count)
        )
    }
    
    /// Test a point without adding it to the polygon.
    ///
    /// - Parameters:
    ///   - latitude: Test point latitude in degrees [-90, 90]
    ///   - longitude: Test point longitude in degrees [-180, 180]
    ///   - reverse: If true, clockwise traversal counts as positive area
    ///   - sign: If true, return signed area
    /// - Returns: The area and perimeter if the test point were added
    public func testPoint(latitude: Double, longitude: Double, reverse: Bool = false, sign: Bool = true) -> ComputeResult {
        var area: Double = 0
        var perimeter: Double = 0
        
        let count = withUnsafePointer(to: geodesic.geod) { geodPtr in
            withUnsafePointer(to: polygon) { polyPtr in
                if isPolyline {
                    return geod_polygon_testpoint(geodPtr, polyPtr, latitude, longitude,
                                                reverse ? 1 : 0, sign ? 1 : 0,
                                                nil, &perimeter)
                } else {
                    return geod_polygon_testpoint(geodPtr, polyPtr, latitude, longitude,
                                                reverse ? 1 : 0, sign ? 1 : 0,
                                                &area, &perimeter)
                }
            }
        }
        
        return ComputeResult(
            area: isPolyline ? nil : area,
            perimeter: perimeter,
            pointCount: Int(count)
        )
    }
    
    /// Test an edge without adding it to the polygon.
    ///
    /// - Parameters:
    ///   - azimuth: Azimuth at current point in degrees
    ///   - distance: Distance to test point in meters
    ///   - reverse: If true, clockwise traversal counts as positive area
    ///   - sign: If true, return signed area
    /// - Returns: The area and perimeter if the test edge were added
    public func testEdge(azimuth: Double, distance: Double, reverse: Bool = false, sign: Bool = true) -> ComputeResult {
        var area: Double = 0
        var perimeter: Double = 0
        
        let count = withUnsafePointer(to: geodesic.geod) { geodPtr in
            withUnsafePointer(to: polygon) { polyPtr in
                if isPolyline {
                    return geod_polygon_testedge(geodPtr, polyPtr, azimuth, distance,
                                               reverse ? 1 : 0, sign ? 1 : 0,
                                               nil, &perimeter)
                } else {
                    return geod_polygon_testedge(geodPtr, polyPtr, azimuth, distance,
                                               reverse ? 1 : 0, sign ? 1 : 0,
                                               &area, &perimeter)
                }
            }
        }
        
        return ComputeResult(
            area: isPolyline ? nil : area,
            perimeter: perimeter,
            pointCount: Int(count)
        )
    }
}

// MARK: - Geodesic Extensions for Polygon Area

public extension Geodesic {
    /// Compute the area and perimeter of a polygon defined by arrays of coordinates.
    ///
    /// - Parameters:
    ///   - latitudes: Array of latitudes in degrees [-90, 90]
    ///   - longitudes: Array of longitudes in degrees [-180, 180]
    /// - Returns: A tuple containing the area in square meters and perimeter in meters
    /// - Precondition: latitudes and longitudes must have the same count
    func polygonArea(latitudes: [Double], longitudes: [Double]) -> (area: Double, perimeter: Double) {
        precondition(latitudes.count == longitudes.count, "Latitude and longitude arrays must have the same count")
        
        var area: Double = 0
        var perimeter: Double = 0
        
        withUnsafePointer(to: geod) { geodPtr in
            latitudes.withUnsafeBufferPointer { latPtr in
                longitudes.withUnsafeBufferPointer { lonPtr in
                    var mutableLats = Array(latPtr)
                    var mutableLons = Array(lonPtr)
                    
                    geod_polygonarea(geodPtr, &mutableLats, &mutableLons, Int32(latitudes.count), &area, &perimeter)
                }
            }
        }
        
        return (area: area, perimeter: perimeter)
    }
}
