//
//  Triangle.swift
//  MarchingSquares
//
//  Created by Reid van Melle on 2020-10-12.
//

import Foundation

/// A simple struct representing 3 points
public struct Triangle: Hashable {

    public init(point1: Point, point2: Point, point3: Point) {
        self.point1 = point1
        self.point2 = point2
        self.point3 = point3
    }

    public let point1: Point  // top
    public let point2: Point  // bottom right
    public let point3: Point  // bottom left

    func mid12(_ altitude: Double) -> Point {
        return Point.interpolate(point1: point1, point2: point2, altitude: altitude)
    }

    func mid23(_ altitude: Double) -> Point {
        return Point.interpolate(point1: point2, point2: point3, altitude: altitude)
    }

    func mid31(_ altitude: Double) -> Point {
        return Point.interpolate(point1: point3, point2: point1, altitude: altitude)
    }
}
