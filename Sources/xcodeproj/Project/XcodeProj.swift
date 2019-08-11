import Foundation
import PathKit

/// Model that represents a .xcodeproj project.
public final class XcodeProj: Equatable {
    // MARK: - Properties

    /// Project workspace
    public var workspace: XCWorkspace

    /// .pbxproj representatino
    public var pbxproj: PBXProj

    /// Shared data.
    public var sharedData: XCSharedData?

    /// User data.
    public var userData: XCUserData?

    // MARK: - Init

    public init(path: Path) throws {
        var pbxproj: PBXProj!
        var workspace: XCWorkspace!
        var sharedData: XCSharedData?
        var userData: XCUserData?

        if !path.exists { throw XCodeProjError.notFound(path: path) }
        pbxproj = try PBXProj.from(path: path)

        let xcworkspacePaths = path.glob("*.xcworkspace")
        workspace = xcworkspacePaths.isEmpty ? XCWorkspace() :
            try XCWorkspace(path: xcworkspacePaths.first!)

        sharedData = try? XCSharedData(path: path)
        userData = try? XCUserData(path: path)

        self.pbxproj = pbxproj
        self.workspace = workspace
        self.sharedData = sharedData
        self.userData = userData
    }

    public convenience init(pathString: String) throws {
        try self.init(path: Path(pathString))
    }

    /// Initializes the XCodeProj
    ///
    /// - Parameters:
    ///   - workspace: project internal workspace.
    ///   - pbxproj: project .pbxproj.
    ///   - sharedData: project shared data.
    ///   - userData: project user data.
    public init(workspace: XCWorkspace, pbxproj: PBXProj, sharedData: XCSharedData? = nil, userData: XCUserData? = nil) {
        self.workspace = workspace
        self.pbxproj = pbxproj
        self.sharedData = sharedData
        self.userData = userData
    }

    // MARK: - Equatable

    public static func == (lhs: XcodeProj, rhs: XcodeProj) -> Bool {
        return lhs.workspace == rhs.workspace &&
            lhs.pbxproj == rhs.pbxproj &&
            lhs.sharedData == rhs.sharedData &&
            lhs.userData == rhs.userData
    }
}

// MARK: - <Writable>

extension XcodeProj: Writable {
    /// Writes project to the given path.
    ///
    /// - Parameter path: path to `.xcodeproj` file.
    /// - Parameter override: if project should be overridden. Default is true.
    ///   If false will throw error if project already exists at the given path.
    public func write(path: Path, override: Bool = true) throws {
        try write(path: path, override: override, outputSettings: PBXOutputSettings())
    }

    /// Writes project to the given path.
    ///
    /// - Parameter path: path to `.xcodeproj` file.
    /// - Parameter override: if project should be overridden. Default is true.
    /// - Parameter outputSettings: Controls the writing of various files.
    ///   If false will throw error if project already exists at the given path.
    public func write(path: Path, override: Bool = true, outputSettings: PBXOutputSettings) throws {
        try path.mkpath()
        try writeWorkspace(path: path, override: override)
        try writePBXProj(path: path, override: override, outputSettings: outputSettings)
        try sharedData?.writeSchemes(path: path, override: override)
        try sharedData?.writeBreakPoints(path: path, override: override)
        try userData?.writeSchemes(path: path, override: override)
        try userData?.writeBreakPoints(path: path, override: override)
    }

    /// Returns workspace file path relative to the given path.
    ///
    /// - Parameter path: `.xcodeproj` file path
    /// - Returns: worspace file path relative to the given path.
    public static func workspacePath(_ path: Path) -> Path {
        return path + "project.xcworkspace"
    }

    /// Writes workspace to the given path.
    ///
    /// - Parameter path: path to `.xcodeproj` file.
    /// - Parameter override: if workspace should be overridden. Default is true.
    ///   If false will throw error if workspace already exists at the given path.
    public func writeWorkspace(path: Path, override: Bool = true) throws {
        try workspace.write(path: XcodeProj.workspacePath(path), override: override)
    }

    /// Returns project file path relative to the given path.
    ///
    /// - Parameter path: `.xcodeproj` file path
    /// - Returns: project file path relative to the given path.
    public static func pbxprojPath(_ path: Path) -> Path {
        return path + "project.pbxproj"
    }

    /// Writes project to the given path.
    ///
    /// - Parameter path: path to `.xcodeproj` file.
    /// - Parameter override: if project should be overridden. Default is true.
    /// - Parameter outputSettings: Controls the writing of various files.
    ///   If false will throw error if project already exists at the given path.
    public func writePBXProj(path: Path, override: Bool = true, outputSettings: PBXOutputSettings) throws {
        try pbxproj.write(path: XcodeProj.pbxprojPath(path), override: override, outputSettings: outputSettings)
    }
}
