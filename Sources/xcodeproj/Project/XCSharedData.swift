import Foundation
import PathKit

public final class XCSharedData: Equatable, XCData {
    // MARK: - Attributes

    /// Shared data schemes.
    public var schemes: [XCScheme]

    /// Shared data breakpoints.
    public var breakpoints: XCBreakpointList?

    /// Workspace settings (represents the WorkspaceSettings.xcsettings file).
    public var workspaceSettings: WorkspaceSettings?

    // MARK: - Init

    /// Initializes the shared data with its properties.
    ///
    /// - Parameters:
    ///   - schemes: Shared data schemes.
    ///   - breakpoints: Shared data breakpoints.
    ///   - workspaceSettings: Workspace settings (represents the WorksapceSettings.xcsettings file).
    public init(schemes: [XCScheme],
                breakpoints: XCBreakpointList? = nil,
                workspaceSettings: WorkspaceSettings? = nil) {
        self.schemes = schemes
        self.breakpoints = breakpoints
        self.workspaceSettings = workspaceSettings
    }

    /// Initializes the XCSharedData reading the content from the disk.
    ///
    /// - Parameter path: path where the .xcodeproj is.
    public init(path: Path) throws {
        let dataPath = path + XCSharedData.dataPath
        let schemesPath = path + XCSharedData.schemesPath

        if !dataPath.exists {
            throw XCSharedDataError.notFound(path: dataPath)
        }

        schemes = XCSharedData.schemes(from: schemesPath)
        breakpoints = try? XCBreakpointList(path: path + XCSharedData.breakpointsPath)
        workspaceSettings = try? WorkspaceSettings.at(
            path: path + XCSharedData.workspaceSettingsPath
        )
    }

    // MARK: - Equatable

    public static func == (lhs: XCSharedData, rhs: XCSharedData) -> Bool {
        return lhs.schemes == rhs.schemes &&
            lhs.breakpoints == rhs.breakpoints &&
            lhs.workspaceSettings == rhs.workspaceSettings
    }
}
