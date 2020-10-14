//
//  LineSegment.swift
//  MarchingSquares
//
//  Created by Reid van Melle on 2020-10-12.
//

import Foundation

public struct LineSegment: Hashable {

    public init(point1: Point, point2: Point) {
        self.point1 = point1
        self.point2 = point2
    }

    public let point1: Point
    public let point2: Point

    var points: [Point] {
        return [point1, point2]
    }

    var first: Point {
        point1
    }
    var last: Point {
        point2
    }
}
