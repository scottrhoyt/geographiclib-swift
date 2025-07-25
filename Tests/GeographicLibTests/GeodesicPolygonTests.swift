//
//  GeodesicPolygonTests.swift
//  GeographicLib
//
//  Created by Scott Hoyt on 6/1/25.
//

import Foundation
@testable import GeographicLib
import Testing

struct GeodesicPolygonTests {
    
    @Test("Basic polygon initialization")
    func testPolygonInitialization() {
        var polygon = GeodesicPolygon()
        #expect(polygon.pointCount == 0)
        
        polygon.addPoint(latitude: 0, longitude: 0)
        #expect(polygon.pointCount == 1)
        #expect(polygon.currentLatitude == 0)
        #expect(polygon.currentLongitude == 0)
    }
    
    @Test("Triangle area calculation")
    func testTriangleArea() {
        var polygon = GeodesicPolygon()
        
        // Create a triangle at the equator
        polygon.addPoint(latitude: 0, longitude: 0)
        polygon.addPoint(latitude: 0, longitude: 90)
        polygon.addPoint(latitude: 90, longitude: 0)
        
        let result = polygon.compute()
        
        #expect(result.pointCount == 3)
        #expect(result.area != nil)
        
        // Area should be approximately 1/8 of Earth's surface
        let expectedArea = Double.pi * 6378137.0 * 6378137.0 / 2.0 // Half of sphere area
        #expect(abs(result.area! - expectedArea) / expectedArea < 0.01) // Within 1%
    }
    
    @Test("Polyline length calculation")
    func testPolylineLength() {
        var polyline = GeodesicPolygon(polyline: true)
        
        // Create a path along the equator
        polyline.addPoint(latitude: 0, longitude: 0)
        polyline.addPoint(latitude: 0, longitude: 90)
        
        let result = polyline.compute()
        
        #expect(result.pointCount == 2)
        #expect(result.area == nil) // No area for polyline
        
        // Length should be 1/4 of equatorial circumference
        let expectedLength = Double.pi * 6378137.0 / 2.0
        #expect(abs(result.perimeter - expectedLength) < 1.0) // Within 1 meter
    }
    
    @Test("Add edge to polygon")
    func testAddEdge() {
        var polygon = GeodesicPolygon()
        
        polygon.addPoint(latitude: 0, longitude: 0)
        polygon.addEdge(azimuth: 90, distance: 1_000_000) // 1000 km east
        
        #expect(polygon.pointCount == 2)
        #expect(polygon.currentLatitude < 0.1) // Should be close to equator
        #expect(polygon.currentLongitude > 8.0) // Should have moved east
    }
    
    @Test("Clear polygon")
    func testClearPolygon() {
        var polygon = GeodesicPolygon()
        
        polygon.addPoint(latitude: 0, longitude: 0)
        polygon.addPoint(latitude: 1, longitude: 1)
        #expect(polygon.pointCount == 2)
        
        polygon.clear()
        #expect(polygon.pointCount == 0)
    }
    
    @Test("Test point without adding")
    func testTestPoint() {
        var polygon = GeodesicPolygon()
        
        polygon.addPoint(latitude: 0, longitude: 0)
        polygon.addPoint(latitude: 0, longitude: 1)
        polygon.addPoint(latitude: 1, longitude: 1)
        
        let beforeTest = polygon.compute()
        
        // Test adding a fourth point
        let testResult = polygon.testPoint(latitude: 1, longitude: 0)
        
        // Original polygon should be unchanged
        let afterTest = polygon.compute()
        #expect(afterTest.pointCount == beforeTest.pointCount)
        #expect(abs(afterTest.area! - beforeTest.area!) < 1e-10)
        
        // Test result should show 4 points
        #expect(testResult.pointCount == 4)
        #expect(testResult.area! > beforeTest.area!)
    }
    
    @Test("Antarctica area from coordinates")
    func testAntarcticaArea() {
        let antarctica = [
            (-72.9, -74.0),
            (-71.9, -102.0),
            (-74.9, -102.0),
            (-74.3, -131.0),
            (-77.5, -163.0),
            (-77.4, 163.0),
            (-71.7, 172.0),
            (-65.9, 140.0),
            (-65.7, 113.0),
            (-66.6, 88.0),
            (-66.9, 59.0),
            (-69.8, 25.0),
            (-70.0, -4.0),
            (-71.0, -14.0),
            (-77.3, -33.0),
            (-77.9, -46.0),
            (-74.7, -61.0)
        ]
        
        let geodesic = Geodesic()
        let (area, perimeter) = geodesic.polygonArea(coordinates: antarctica)
        
        // Expected values from GeographicLib implementation
        let expectedArea = 13376856682207.4 // square meters
        let expectedPerimeter = 14710425.406974 // meters
        
        #expect(abs(area - expectedArea) / expectedArea < 1e-10)
        #expect(abs(perimeter - expectedPerimeter) / expectedPerimeter < 1e-6)
    }
    
    @Test("Polygon with custom ellipsoid")
    func testPolygonCustomEllipsoid() {
        let sphericalGeodesic = Geodesic(.sphere)
        var polygon = GeodesicPolygon(geodesic: sphericalGeodesic)
        
        // Create a triangle on a sphere
        polygon.addPoint(latitude: 0, longitude: 0)
        polygon.addPoint(latitude: 0, longitude: 90)
        polygon.addPoint(latitude: 90, longitude: 0)
        
        let result = polygon.compute()
        
        // On a perfect sphere, this should be exactly 1/8 of surface area
        let expectedArea = Double.pi * 6371000.0 * 6371000.0 / 2.0
        #expect(abs(result.area! - expectedArea) / expectedArea < 1e-12)
    }
    
    @Test("Clockwise vs counter-clockwise")
    func testClockwiseOrientation() {
        var polygon = GeodesicPolygon()
        
        // Counter-clockwise square
        polygon.addPoint(latitude: 0, longitude: 0)
        polygon.addPoint(latitude: 0, longitude: 1)
        polygon.addPoint(latitude: 1, longitude: 1)
        polygon.addPoint(latitude: 1, longitude: 0)
        
        let ccwResult = polygon.compute(reverse: false, sign: true)
        let cwResult = polygon.compute(reverse: true, sign: true)
        
        // Areas should have opposite signs
        #expect(ccwResult.area! > 0)
        #expect(cwResult.area! < 0)
        #expect(abs(ccwResult.area! + cwResult.area!) < 1e-10)
    }
}
