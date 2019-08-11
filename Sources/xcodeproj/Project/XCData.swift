//
//  XCData.swift
//  XcodeProj
//
//  Created by Kraken on 8/11/19.
//

import Foundation
import PathKit

public protocol XCData: class {
    var dataPath: Path { get }
    var schemesPath: Path { get }
    var debuggerPath: Path { get }
    var breakpointsPath: Path { get }

    var breakpoints: XCBreakpointList? { get }
    var schemes: [XCScheme] { get set }

    func writeSchemes(path: Path, override: Bool) throws
    func writeBreakPoints(path: Path, override: Bool) throws
}

public extension XCData {
    var dataPath: Path {
        return Path(String(describing: Self.self).lowercased())
    }
    var schemesPath: Path {
        return dataPath + "xcschemes"
    }
    var debuggerPath: Path {
        return dataPath + "xcdebugger"
    }
    var breakpointsPath: Path {
        return debuggerPath + "Breakpoints_v2.xcbkptlist"
    }

    /// Writes all project schemes to the given path.
    ///
    /// - Parameter path: path to `.xcodeproj` file.
    /// - Parameter override: if project should be overridden. Default is true.
    ///   If true will remove all existing schemes before writing.
    ///   If false will throw error if scheme already exists at the given path.
    func writeSchemes(path: Path, override: Bool = true) throws {
        if override, schemesPath.exists {
            try schemesPath.delete()
        }
        try schemesPath.mkpath()
        for scheme in schemes {
            try scheme.write(
                path: path + schemesPath + scheme.name + "." +
                    String(describing: XCScheme.self).lowercased(),
                override: override
            )
        }
    }

    /// Writes all project breakpoints to the given path.
    ///
    /// - Parameter path: path to `.xcodeproj` file.
    /// - Parameter override: if project should be overridden. Default is true.
    ///   If true will remove all existing debugger data before writing.
    ///   If false will throw error if breakpoints file exists at the given path.
    func writeBreakPoints(path: Path, override: Bool = true) throws {
        let debugPath = path + debuggerPath
        if override, debugPath.exists {
            try debugPath.delete()
        }
        try debugPath.mkpath()
        try breakpoints?.write(path: path + breakpointsPath, override: override)
    }
}
