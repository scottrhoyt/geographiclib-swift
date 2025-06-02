# Swift implementation of the geodesic routines in GeographicLib

This is a Swift library to solve geodesic problems on an ellipsoid model of
the earth.

This is a Swift wrapper around the C implementation of the geodesic routines
from [GeographicLib](https://geographiclib.sourceforge.io).

Licensed under the MIT/X11 License; see
[LICENSE.txt](https://geographiclib.sourceforge.io/LICENSE.txt).

The algorithms are documented in

* C. F. F. Karney,
  [Algorithms for geodesics](https://doi.org/10.1007/s00190-012-0578-z),
  J. Geodesy **87**(1), 43–55 (2013);
  [Addenda](https://geographiclib.sourceforge.io/geod-addenda.html).

## Other links:

* Library documentation: (coming soon)
* GeographicLib: https://geographiclib.sourceforge.io
* C implementation: https://github.com/geographiclib/geographiclib-c

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/scottrhoyt/geographiclib-swift.git", from: "0.1.0")
]
```

## Usage

### Basic Usage

```swift
import GeographicLib

// Create a geodesic calculator with WGS-84 ellipsoid (default)
let geodesic = Geodesic()

// Solve the direct problem: given a starting point, azimuth, and distance
let direct = geodesic.direct(
    latitude: 40.64,      // JFK Airport
    longitude: -73.78,
    azimuth: 45.0,        // northeast
    distance: 10_000_000  // 10,000 km
)
print("Destination: \(direct.latitude)°, \(direct.longitude)°")

// Solve the inverse problem: given two points, find distance and azimuths
let inverse = geodesic.inverse(
    latitude1: 40.64,     // JFK Airport
    longitude1: -73.78,
    latitude2: 1.36,      // Singapore Changi Airport
    longitude2: 103.99
)
print("Distance: \(inverse.distance) meters")
print("Initial azimuth: \(inverse.azimuth1)°")
```

### Using Different Ellipsoids

```swift
// Use GRS-80 ellipsoid
let grs80 = Geodesic(.grs80)

// Use a custom ellipsoid
let customEllipsoid = Ellipsoid(equatorialRadius: 6378000.0, flattening: 1.0/300.0)
let customGeodesic = Geodesic(customEllipsoid)

// Use a sphere for simplified calculations
let sphere = Geodesic(.sphere)
```

### Geodesic Lines

For efficient calculations of multiple points along a geodesic:

```swift
// Create a geodesic line
let line = geodesic.inverseLine(
    latitude1: 40.64, longitude1: -73.78,  // JFK
    latitude2: 1.36, longitude2: 103.99     // Singapore
)

// Calculate waypoints
for i in 0...10 {
    let fraction = Double(i) / 10.0
    let position = line.position(distance: line.distance * fraction)
    print("Waypoint \(i): \(position.latitude)°, \(position.longitude)°")
}
```

### Polygon Areas

Calculate areas and perimeters of geodesic polygons:

```swift
// Simple polygon area calculation
let antarctica = [
    (-72.9, -74), (-71.9, -102), (-74.9, -102), (-74.3, -131),
    (-77.5, -163), (-77.4, 163), (-71.7, 172), (-65.9, 140),
    (-65.7, 113), (-66.6, 88), (-66.9, 59), (-69.8, 25),
    (-70.0, -4), (-71.0, -14), (-77.3, -33), (-77.9, -46), (-74.7, -61)
]

let (area, perimeter) = geodesic.polygonArea(
    latitudes: antarctica.map { $0.0 },
    longitudes: antarctica.map { $0.1 }
)
print("Antarctica area: \(area) m²")
print("Antarctica perimeter: \(perimeter) m")

// Using the Polygon type for more control
var polygon = Polygon()
polygon.addPoint(latitude: 0, longitude: 0)
polygon.addPoint(latitude: 0, longitude: 90)
polygon.addPoint(latitude: 90, longitude: 0)

let result = polygon.compute()
print("Triangle area: \(result.area!) m²")
```

## Features

- **Direct geodesic problem**: Given a starting point, azimuth, and distance, find the destination point
- **Inverse geodesic problem**: Given two points, find the distance and azimuths between them
- **Geodesic lines**: Efficiently compute multiple points along a geodesic
- **Polygon areas**: Calculate areas and perimeters of geodesic polygons
- **Multiple ellipsoids**: Support for WGS-84, GRS-80, custom ellipsoids, and spheres
- **High precision**: Accurate to round-off for distances up to 180°
- **Thread-safe**: All types are immutable and `Sendable`

## Requirements

- Swift 5.5 or later
- Platforms: macOS, iOS, tvOS, watchOS, Linux, Windows
