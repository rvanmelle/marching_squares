//
//  Contour.swift
//  MarchingSquares
//
//  Created by Reid van Melle on 2020-10-12.
//

import Foundation

public struct Contour: Hashable {
    public let points: [Point]
    public let altitude: Double

    public init(points: [Point], altitude: Double) {
        self.points = points
        self.altitude = altitude
    }
}
