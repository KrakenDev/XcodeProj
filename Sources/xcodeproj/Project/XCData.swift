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
    var writables: [Writable] { get }

    func write(to path: Path, override: Bool) throws

    static func schemes(from path: Path) throws -> [XCScheme]
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
    var writables: [Writable] {
        return []
    }

    /// Writes all project schemes to the given path.
    ///
    /// - Parameter path: path to `.xcodeproj` file.
    /// - Parameter override: if project should be overridden. Default is true.
    ///   If true will remove all existing schemes before writing.
    ///   If false will throw error if scheme already exists at the given path.
    func write(to path: Path, override: Bool = true) throws {
        let schemePath = path + schemesPath
        let breakpointPath = path + breakpointsPath
        try [schemePath, breakpointPath].forEach { writePath in
            if override && writePath.exists {
                try writePath.delete()
            }
        }

        try schemePath.mkpath()
        try breakpointPath.mkpath()

        // Write schemes
        for scheme in schemes {
            try scheme.write(
                path: schemePath + scheme.pathName,
                override: override
            )
        }

        // Write any custom object we can't infer from here
        for writable in writables {
            try writable.write(path: path, override: override)
        }

        // Write breakpoints
        try breakpoints?.write(
            path: breakpointPath,
            override: override
        )
    }

    static func schemes(from path: Path) throws -> [XCScheme] {
        return try path.glob("*.xcscheme").compactMap(XCScheme.init)
    }
}
