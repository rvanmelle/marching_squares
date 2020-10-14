//
//  Point.swift
//  MarchingSquares
//
//  Created by Reid van Melle on 2020-10-12.
//

import Foundation

/// This is a simple 2-D point with an altitude
public struct Point: Hashable {

    public let x: Double
    public let y: Double
    public let altitude: Double

    public init(x: Double, y: Double, altitude: Double) {
        self.x = x
        self.y = y
        self.altitude = altitude
    }

    static func interpolate(point1: Point, point2: Point, altitude: Double) -> Point {
        assert((altitude > point1.altitude && altitude < point2.altitude) || (altitude < point1.altitude && altitude > point2.altitude))
        if (altitude > point1.altitude) {
            let ratio = (altitude - point1.altitude) / (point2.altitude - point1.altitude)
            let dx = (point2.x - point1.x) * ratio
            let dy = (point2.y - point1.y) * ratio
            return Point(x: point1.x + dx, y: point1.y + dy, altitude: altitude)
        } else {
            let ratio = (altitude - point2.altitude) / (point1.altitude - point2.altitude)
            let dx = (point1.x - point2.x) * ratio
            let dy = (point1.y - point2.y) * ratio
            return Point(x: point2.x + dx, y: point2.y + dy, altitude: altitude)
        }
    }
}
