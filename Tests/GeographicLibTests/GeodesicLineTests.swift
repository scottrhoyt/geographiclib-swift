//
//  GeodesicLineTests.swift
//  GeographicLib
//
//  Created by Scott Hoyt on 6/1/25.
//

import Foundation
@testable import GeographicLib
import Testing

struct GeodesicLineTests {
    
    @Test("Basic line initialization")
    func testLineInitialization() {
        let geodesic = Geodesic()
        let line = geodesic.line(latitude: 40.64, longitude: -73.78, azimuth: 45.0)
        
        #expect(line.latitude == 40.64)
        #expect(line.longitude == -73.78)
        #expect(line.azimuth == 45.0)
        #expect(line.capabilities.contains(.latitude))
        #expect(line.capabilities.contains(.longitude))
        #expect(line.capabilities.contains(.azimuth))
        #expect(line.capabilities.contains(.distanceIn))
    }
    
    @Test("Line position calculation")
    func testLinePosition() {
        let geodesic = Geodesic()
        let line = geodesic.line(latitude: 40.64, longitude: -73.78, azimuth: 45.0)
        
        // Calculate position at 1000 km
        let position = line.position(distance: 1_000_000.0)
        
        // Should match direct calculation
        let direct = geodesic.direct(latitude: 40.64, longitude: -73.78, azimuth: 45.0, distance: 1_000_000.0)
        
        #expect(abs(position.latitude - direct.latitude) < 1e-12)
        #expect(abs(position.longitude - direct.longitude) < 1e-12)
        #expect(abs(position.azimuth - direct.azimuth) < 1e-12)
    }
    
    @Test("Direct line initialization")
    func testDirectLine() {
        let geodesic = Geodesic()
        let line = geodesic.directLine(latitude: 40.64, longitude: -73.78, azimuth: 45.0, distance: 1_000_000.0)
        
        #expect(line.latitude == 40.64)
        #expect(line.longitude == -73.78)
        #expect(line.azimuth == 45.0)
        #expect(abs(line.distance - 1_000_000.0) < 0.001)
    }
    
    @Test("Inverse line initialization")
    func testInverseLine() {
        let geodesic = Geodesic()
        
        // JFK to Singapore
        let startLatitude = 40.64
        let startLongitude = -73.78
        let endLatitude = 1.36
        let endLongitude = 103.99
        
        let line = geodesic.inverseLine(
            startLatitude: startLatitude,
            startLongitude: startLongitude,
            endLatitude: endLatitude,
            endLongitude: endLongitude
        )
        
        #expect(line.latitude == startLatitude)
        #expect(line.longitude == startLongitude)
        
        // The line should connect the two points
        let inverseResult = geodesic.inverse(
            startLatitude: startLatitude,
            startLongitude: startLongitude,
            endLatitude: endLatitude,
            endLongitude: endLongitude
        )
        #expect(abs(line.distance - inverseResult.distance) < 0.001)
        #expect(abs(line.azimuth - inverseResult.startAzimuth) < 1e-10)
    }
    
    @Test("Waypoints along geodesic")
    func testWaypoints() {
        let geodesic = Geodesic()
        
        // Create line from JFK to Singapore
        let line = geodesic.inverseLine(
            startLatitude: 40.64,
            startLongitude: -73.78,
            endLatitude: 1.36,
            endLongitude: 103.99
        )
        
        // Generate 11 waypoints (0%, 10%, ..., 100%)
        var waypoints: [GeodesicLine.PositionResult] = []
        for i in 0...10 {
            let fraction = Double(i) / 10.0
            let position = line.position(distance: line.distance * fraction)
            waypoints.append(position)
        }
        
        // First waypoint should be at start
        #expect(abs(waypoints[0].latitude - 40.64) < 1e-12)
        #expect(abs(waypoints[0].longitude - (-73.78)) < 1e-12)
        
        // Last waypoint should be at end
        #expect(abs(waypoints[10].latitude - 1.36) < 1e-6)
        #expect(abs(waypoints[10].longitude - 103.99) < 1e-6)
        
        // Waypoints should be in sequence
        for i in 1..<waypoints.count {
            let prev = waypoints[i-1]
            let curr = waypoints[i]
            
            // Calculate distance between consecutive waypoints
            let segmentResult = geodesic.inverse(
                startLatitude: prev.latitude,
                startLongitude: prev.longitude,
                endLatitude: curr.latitude,
                endLongitude: curr.longitude
            )
            
            // Should be approximately 10% of total distance
            let expectedSegmentDistance = line.distance * 0.1
            #expect(abs(segmentResult.distance - expectedSegmentDistance) < 1.0)
        }
    }
    
    @Test("General position with capabilities")
    func testGeneralPosition() {
        let geodesic = Geodesic()
        
        // Create line with all capabilities
        let line = geodesic.line(
            latitude: 0.0, longitude: 0.0, azimuth: 90.0,
            capabilities: .all
        )
        
        let result = line.generalPosition(distanceOrArc: 1_000_000.0)
        
        #expect(result.distance != nil)
        #expect(result.reducedLength != nil)
        #expect(result.scale12 != nil)
        #expect(result.scale21 != nil)
        #expect(result.area != nil)
    }
    
    @Test("Arc mode position")
    func testArcModePosition() {
        let geodesic = Geodesic()
        
        let line = geodesic.line(
            latitude: 0.0, longitude: 0.0, azimuth: 90.0,
            capabilities: .all
        )
        
        // Position by arc length (1 degree)
        let result = line.generalPosition(flags: .arcMode, distanceOrArc: 1.0)
        
        #expect(abs(result.arc - 1.0) < 1e-12)
        #expect(result.longitude > 0.0) // Should move east
    }
}
