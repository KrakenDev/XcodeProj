//
//  XCData.swift
//  XcodeProj
//
//  Created by Kraken on 8/11/19.
//

import Foundation
import PathKit

public protocol XCData: class, Equatable {
    static var dataPath: Path { get }
    static var schemesPath: Path { get }
    static var debuggerPath: Path { get }
    static var breakpointsPath: Path { get }
    static var workspaceSettingsPath: Path { get }

    var schemes: [XCScheme] { get set }
    var breakpoints: XCBreakpointList? { get }

    func writeSchemes(path: Path, override: Bool) throws
    func writeBreakPoints(path: Path, override: Bool) throws
}

public extension XCData {
    static var dataPath: Path {
        return Path(isa.lowercased())
    }
    static var schemesPath: Path {
        return dataPath + "xcschemes"
    }
    static var debuggerPath: Path {
        return dataPath + "xcdebugger"
    }
    static var breakpointsPath: Path {
        return debuggerPath + "Breakpoints_v2.xcbkptlist"
    }
    static var workspaceSettingsPath: Path {
        return dataPath + "WorkspaceSettings.xcsettings"
    }

    var dataPath: Path {
        return type(of: self).dataPath
    }
    var schemesPath: Path {
        return type(of: self).schemesPath
    }
    var debuggerPath: Path {
        return type(of: self).debuggerPath
    }
    var breakpointsPath: Path {
        return type(of: self).breakpointsPath
    }
    var workspaceSettingsPath: Path {
        return type(of: self).workspaceSettingsPath
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
                path: path + schemesPath + scheme.name +
                    "." + scheme.isa.lowercased(),
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
