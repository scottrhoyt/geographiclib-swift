//
//  GeodesicTests.swift
//  GeographicLib
//
//  Created by Scott Hoyt on 6/1/25.
//

import Foundation
@testable import GeographicLib
import Testing

struct GeodesicTests {
    
    @Test("WGS-84 default initialization")
    func testWGS84DefaultInit() {
        let geodesic = Geodesic()
        #expect(geodesic.equatorialRadius == Ellipsoid.wgs84.equatorialRadius)
        #expect(geodesic.flattening == Ellipsoid.wgs84.flattening)
    }
    
    @Test("Custom ellipsoid initialization")
    func testCustomEllipsoidInit() {
        let equatorialRadius = 6378000.0
        let flattening = 1.0/300.0
        
        let geodesic = Geodesic(equatorialRadius: equatorialRadius, flattening: flattening)
        #expect(geodesic.equatorialRadius == equatorialRadius)
        #expect(geodesic.flattening == flattening)
    }
    
    @Test("Direct problem - JFK to 10000km NE")
    func testDirectProblem() {
        let geodesic = Geodesic()
        
        // JFK coordinates
        let lat1 = 40.64
        let lon1 = -73.78
        let azimuth = 45.0
        let distance = 10_000_000.0 // 10,000 km
        
        let result = geodesic.direct(latitude: lat1, longitude: lon1, azimuth: azimuth, distance: distance)
        
        // Check that we got valid results
        #expect(result.latitude >= -90 && result.latitude <= 90)
        #expect(result.longitude >= -180 && result.longitude <= 180)
        #expect(result.azimuth >= -180 && result.azimuth <= 180)
        
        // Expected approximate values from the C library
        #expect(abs(result.latitude - 32.62110046) < 0.000001)
        #expect(abs(result.longitude - 49.05248709) < 0.000001)
        #expect(abs(result.azimuth - 140.40598588) < 0.001)
    }
    
    @Test("Inverse problem - JFK to Singapore")
    func testInverseProblem() {
        let geodesic = Geodesic()
        
        // JFK coordinates
        let lat1 = 40.64
        let lon1 = -73.78
        
        // Singapore Changi Airport coordinates
        let lat2 = 1.36
        let lon2 = 103.99
        
        let result = geodesic.inverse(latitude1: lat1, longitude1: lon1, latitude2: lat2, longitude2: lon2)
        
        // Check that we got valid results
        #expect(result.distance > 0)
        #expect(result.azimuth1 >= -180 && result.azimuth1 <= 180)
        #expect(result.azimuth2 >= -180 && result.azimuth2 <= 180)
        
        // Expected approximate distance from the C library documentation
        #expect(abs(result.distance - 15.3e6) < 0.1e6) // ~15,300 km
    }
    
    @Test("Direct and inverse are consistent")
    func testDirectInverseConsistency() {
        let geodesic = Geodesic()
        
        let lat1 = 40.64
        let lon1 = -73.78
        let azimuth1 = 45.0
        let distance = 1_000_000.0 // 1000 km
        
        // Perform direct calculation
        let directResult = geodesic.direct(latitude: lat1, longitude: lon1, azimuth: azimuth1, distance: distance)
        
        // Perform inverse calculation using the result
        let inverseResult = geodesic.inverse(
            latitude1: lat1,
            longitude1: lon1,
            latitude2: directResult.latitude,
            longitude2: directResult.longitude
        )
        
        // Check consistency
        #expect(abs(inverseResult.distance - distance) < 0.001) // within 1mm
        #expect(abs(inverseResult.azimuth1 - azimuth1) < 1e-10) // very small angle difference
    }
    
    @Test("Negative distance")
    func testNegativeDistance() {
        let geodesic = Geodesic()
        
        let lat1 = 0.0
        let lon1 = 0.0
        let azimuth1 = 90.0
        let distance = -1_000_000.0 // -1000 km
        
        let result = geodesic.direct(latitude: lat1, longitude: lon1, azimuth: azimuth1, distance: distance)
        
        // Should go in the opposite direction
        #expect(result.longitude < lon1)
    }
    
    @Test("Antipodal points")
    func testAntipodalPoints() {
        let geodesic = Geodesic()
        
        // North pole to South pole
        let result = geodesic.inverse(latitude1: 90.0, longitude1: 0.0, latitude2: -90.0, longitude2: 0.0)
        
        // For WGS-84 ellipsoid, the meridional distance from pole to pole
        // The distance should be close to half the meridional circumference
        // For WGS-84, this is approximately 20,003,931 meters
        let expectedDistance = 20_003_931.0
        #expect(abs(result.distance - expectedDistance) < 1.0) // within 1 meter
    }
}
