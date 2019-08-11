import Foundation
import PathKit

public final class XCUserData: Equatable, XCData {
    // MARK: - Attributes

    /// User data schemes.
    public var schemes: [XCScheme]

    /// User state for schemes
    public var schemeManagement: XCScheme.Management

    /// User data breakpoints.
    public var breakpoints: XCBreakpointList?

    /// Workspace settings (represents the WorksapceSettings.xcsettings file).
    public var workspaceSettings: WorkspaceSettings?

    // MARK: - Init

    /// Initializes the user data with its properties.
    ///
    /// - Parameters:
    ///   - schemes: User data schemes.
    ///   - breakpoints: User data breakpoints.
    ///   - workspaceSettings: Workspace settings (represents the WorksapceSettings.xcsettings file).
    public init(schemes: [XCScheme],
                schemeManagement: XCScheme.Management,
                breakpoints: XCBreakpointList? = nil,
                workspaceSettings: WorkspaceSettings? = nil) {
        self.schemes = schemes
        self.schemeManagement = schemeManagement
        self.breakpoints = breakpoints
        self.workspaceSettings = workspaceSettings
    }

    /// Initializes the XCUserData reading the content from the disk.
    ///
    /// - Parameter path: path where the .xcuserdata is.
    public init(path: Path) throws {
        if !path.exists {
            throw XCUserDataError.notFound(path: path)
        }
        schemes = path.glob("xcschemes/*.xcscheme")
            .compactMap { try? XCScheme(path: $0) }
        schemeManagement = XCScheme.Management(userState: .init(isShared: true, orderHint: 0), autocreation: .init(shouldSuppress: true))
        breakpoints = try? XCBreakpointList(path: path + "xcdebugger/Breakpoints_v2.xcbkptlist")

        let workspaceSettingsPath = path + "WorkspaceSettings.xcsettings"
        if workspaceSettingsPath.exists {
            workspaceSettings = try WorkspaceSettings.at(path: workspaceSettingsPath)
        } else {
            workspaceSettings = nil
        }
    }

    // MARK: - Equatable

    public static func == (lhs: XCUserData, rhs: XCUserData) -> Bool {
        return lhs.schemes == rhs.schemes &&
            lhs.breakpoints == rhs.breakpoints &&
            lhs.workspaceSettings == rhs.workspaceSettings
    }
}
