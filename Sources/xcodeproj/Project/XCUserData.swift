import AEXML
import Foundation
import PathKit

public final class XCUserData: Equatable {
    // MARK: - Attributes

    /// User data schemes.
    public var schemes: [XCScheme]

    /// User state for schemes
    public var schemeManagement: XCScheme.Management?

    /// User data breakpoints.
    public var breakpoints: XCBreakpointList?

    /// Workspace settings (represents the WorksapceSettings.xcsettings file).
    public var workspaceSettings: WorkspaceSettings?

    // MARK: - Init

    /// Initializes the user data with its properties.
    ///
    /// - Parameters:
    ///   - schemes: User data schemes.
    ///   - schemeManagement: User data scheme management (represents the order that each scheme shows up in Xcode as well as their local shared state for the current user.
    ///   - breakpoints: User data breakpoints.
    ///   - workspaceSettings: Workspace settings (represents the WorkspaceSettings.xcsettings file).
    public init(schemes: [XCScheme],
                breakpoints: XCBreakpointList? = nil,
                workspaceSettings: WorkspaceSettings? = nil) {
        self.schemes = schemes
        self.schemeManagement = XCScheme.Management(schemes: schemes)
        self.breakpoints = breakpoints
        self.workspaceSettings = workspaceSettings
    }

    /// Initializes the XCUserData reading the content from the disk.
    ///
    /// - Parameter path: the .xcodeproj path
    public init(path: Path) throws {
        let pbxProj = try PBXProj.from(path: path)
        let dataPath = path + XCUserData.dataPath
        let schemesPath = path + XCUserData.schemesPath
        let debuggerPath = path + XCUserData.debuggerPath

        try? dataPath.mkpath()
        try? schemesPath.mkpath()
        try? debuggerPath.mkpath()

        schemes = try schemesPath.glob("*.xcscheme").compactMap(XCScheme.init)
        schemeManagement = try? XCScheme.Management(path: schemesPath)
        breakpoints = try? XCBreakpointList(path: path + XCUserData.breakpointsPath)
        workspaceSettings = try? WorkspaceSettings.at(
            path: path + XCUserData.workspaceSettingsPath
        )
    }

    // MARK: - Equatable

    public static func == (lhs: XCUserData, rhs: XCUserData) -> Bool {
        return lhs.schemes == rhs.schemes &&
            lhs.breakpoints == rhs.breakpoints &&
            lhs.workspaceSettings == rhs.workspaceSettings
    }
}

extension XCUserData: XCData {
    public static var dataPath: Path {
        let user: String
        let processInfo = ProcessInfo.processInfo
        if #available(OSX 10.12, *) {
            user = processInfo.userName
        } else {
            user = processInfo.environment["USER"] ?? processInfo.hostName
        }
        return Path(isa.lowercased()) + "\(user).xcuserdatad"
    }
}
