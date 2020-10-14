//
//  Isolines.swift
//  MarchingSquares
//
//  Created by Reid van Melle on 2020-10-12.
//

import Foundation

/// Computes all contours as a series of line segments. The line segments may form
/// many non-overlapping isolines.
public func computeContourLineSegments(triangles: [Triangle], contour: Double) -> [LineSegment] {
    var segments: [LineSegment] = []
    for triangle in triangles {
        switch (triangle.point1.altitude <= contour, triangle.point2.altitude <= contour, triangle.point3.altitude <= contour) {
        // No segments: s111, s000
        case (true, true, true), (false, false, false):
            break
        // Down left to right: s001, s110
        case (false, false, true), (true, true, false):
            segments.append(LineSegment(point1: triangle.mid31(contour), point2: triangle.mid23(contour)))
        // Up left to right: s010, s101
        case (false, true, false), (true, false, true):
            segments.append(LineSegment(point1: triangle.mid23(contour), point2: triangle.mid12(contour)))
        // Horizontal: s011, s100
        case (false, true, true), (true, false, false):
            segments.append(LineSegment(point1: triangle.mid31(contour), point2: triangle.mid12(contour)))
        }
    }

    return segments
}

/// Extract a single contour from a set of line segments. Since the set of line segments may
/// form many non-overlapping contours, we return the remainder as well
func extractContour(lineSegments: [LineSegment]) -> (contour: [Point], remainder: [LineSegment]) {
    guard !lineSegments.isEmpty else {
        return (contour: [], remainder: [])
    }

    var allSegments: [LineSegment] = []
    for lineSegment in lineSegments.dropFirst() {
        allSegments.append(lineSegment)
    }
    var sequence: [Point] = lineSegments.first!.points
    var foundMatch = true
    while !allSegments.isEmpty && foundMatch {
        foundMatch = false
        allSegments = Array(allSegments.drop(while: { (segment) -> Bool in
            if segment.first == sequence.first! {
                sequence = segment.points.reversed() + sequence
                foundMatch = true
                return true
            } else if segment.last == sequence.last! {
                sequence = sequence + segment.points.reversed()
                foundMatch = true
                return true
            } else if segment.first == sequence.last! {
                sequence = sequence + segment.points
                foundMatch = true
                return true
            } else if segment.last == sequence.first! {
                sequence = segment.points + sequence
                foundMatch = true
                return true
            } else {
                return false
            }
        }))
    }
    return (contour: sequence, remainder: allSegments)
}

/// Computes all of the isoline contours for the elevation contour `contour`
/// Each set of points returned is a contiguous connected line
public func computeIsolineContours(triangles: [Triangle], contour: Double) -> [[Point]] {
    // Compute all of the line segments
    let lineSegments = computeContourLineSegments(triangles: triangles, contour: contour)

    // Extract the contours until all of the segments have been exhausted
    var contours: [[Point]] = []
    var extractionResult = extractContour(lineSegments: lineSegments)
    if !extractionResult.contour.isEmpty {
        contours.append(extractionResult.contour)
    }
    while !extractionResult.remainder.isEmpty {
        extractionResult = extractContour(lineSegments: extractionResult.remainder)
        contours.append(extractionResult.contour)
    }

    return contours
}
