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
        let latitude = 40.64
        let longitude = -73.78
        let azimuth = 45.0
        let distance = 10_000_000.0 // 10,000 km
        
        let result = geodesic.direct(
            latitude: latitude,
            longitude: longitude,
            azimuth: azimuth,
            distance: distance
        )
        
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
        let startLatitude = 40.64
        let startLongitude = -73.78
        
        // Singapore Changi Airport coordinates
        let endLatitude = 1.36
        let endLongitude = 103.99
        
        let result = geodesic.inverse(
            startLatitude: startLatitude,
            startLongitude: startLongitude,
            endLatitude: endLatitude,
            endLongitude: endLongitude
        )
        
        // Check that we got valid results
        #expect(result.distance > 0)
        #expect(result.startAzimuth >= -180 && result.startAzimuth <= 180)
        #expect(result.endAzimuth >= -180 && result.endAzimuth <= 180)
        
        // Expected approximate distance from the C library documentation
        #expect(abs(result.distance - 15.3e6) < 0.1e6) // ~15,300 km
    }
    
    @Test("Direct and inverse are consistent")
    func testDirectInverseConsistency() {
        let geodesic = Geodesic()
        
        let latitude = 40.64
        let longitude = -73.78
        let azimuth = 45.0
        let distance = 1_000_000.0 // 1000 km
        
        // Perform direct calculation
        let directResult = geodesic.direct(
            latitude: latitude,
            longitude: longitude,
            azimuth: azimuth,
            distance: distance
        )
        
        // Perform inverse calculation using the result
        let inverseResult = geodesic.inverse(
            startLatitude: latitude,
            startLongitude: longitude,
            endLatitude: directResult.latitude,
            endLongitude: directResult.longitude
        )
        
        // Check consistency
        #expect(abs(inverseResult.distance - distance) < 0.001) // within 1mm
        #expect(abs(inverseResult.startAzimuth - azimuth) < 1e-10) // very small angle difference
    }
    
    @Test("Negative distance")
    func testNegativeDistance() {
        let geodesic = Geodesic()
        
        let latitude = 0.0
        let longitude = 0.0
        let azimuth = 90.0
        let distance = -1_000_000.0 // -1000 km
        
        let result = geodesic.direct(
            latitude: latitude,
            longitude: longitude,
            azimuth: azimuth,
            distance: distance
        )
        
        // Should go in the opposite direction
        #expect(result.longitude < longitude)
    }
    
    @Test("Antipodal points")
    func testAntipodalPoints() {
        let geodesic = Geodesic()
        
        // North pole to South pole
        let result = geodesic.inverse(
            startLatitude: 90.0,
            startLongitude: 0.0,
            endLatitude: -90.0,
            endLongitude: 0.0
        )
        
        // For WGS-84 ellipsoid, the meridional distance from pole to pole
        // The distance should be close to half the meridional circumference
        // For WGS-84, this is approximately 20,003,931 meters
        let expectedDistance = 20_003_931.0
        #expect(abs(result.distance - expectedDistance) < 1.0) // within 1 meter
    }
}
