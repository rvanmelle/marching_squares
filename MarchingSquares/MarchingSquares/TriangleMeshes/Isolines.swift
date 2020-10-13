//
//  Isolines.swift
//  MarchingSquares
//
//  Created by Reid van Melle on 2020-10-12.
//

import Foundation

enum OldTriangleConfig {
    case s111  // no segment
    case s000  // no segment
    case s001  // down left to right
    case s010  // up left to right
    case s011  // horizontal line
    case s100  // horizontal line
    case s101  // up left to right
    case s110  // down left to right
}

enum TriangleConfig {
    case noSegment
    case downLeftToRight
    case upLeftToRight
    case horizontal
}


public func computeContours(triangles: [Triangle], contour: Double) -> [LineSegment] {
    var configs: [Triangle: TriangleConfig] = [:]
    var segments: [LineSegment] = []
    for triangle in triangles {
        switch (triangle.point1.altitude <= contour, triangle.point2.altitude <= contour, triangle.point3.altitude <= contour) {
        case (true, true, true), (false, false, false):
            configs[triangle] = .noSegment
        case (false, false, true), (true, true, false):
            segments.append(LineSegment(point1: triangle.mid31(contour), point2: triangle.mid23(contour)))
            configs[triangle] = .downLeftToRight
        case (false, true, false), (true, false, true):
            segments.append(LineSegment(point1: triangle.mid23(contour), point2: triangle.mid12(contour)))
            configs[triangle] = .upLeftToRight
        case (false, true, true), (true, false, false):
            segments.append(LineSegment(point1: triangle.mid31(contour), point2: triangle.mid12(contour)))
            configs[triangle] = .horizontal
        }
    }
    return segments
}
