import AEXML
import Foundation
import PathKit

extension XCScheme {
    public final class Management: Writable, Equatable {
        // MARK: - Attributes

        public var userState: UserState
        public var autocreateState: AutocreateState

        // MARK: - Init

        public init(schemes: [XCScheme]) {
            self.userState = UserState(schemes: schemes)
            self.autocreateState = AutocreateState(schemes: schemes)
        }

        init(path: Path) throws {
            let xcschemeName = XCScheme.isa.lowercased()
            let managementName = Management.isa.lowercased()
            let plistPath = path + "\(xcschemeName + managementName).plist"
            if let document = try? AEXMLDocument(xml: try plistPath.read()) {
                userState = try UserState(element: document["SchemeUserState"])
                autocreateState = try AutocreateState(element: document["SuppressBuildableAutocreation"])
            } else {
                let basePath = Path(path.string.replacingOccurrences(
                    of: XCUserData.schemesPath.string, with: ""))
                let sharedData = try XCSharedData(path: basePath)
                let userSchemes = XCUserData.schemes(from: path)
                let sharedSchemes = sharedData.schemes

                let pbxProj = try PBXProj.from(path: basePath)
                autocreateState = AutocreateState(schemes: userSchemes)
                userState = UserState(
                    schemes: sharedSchemes,
                    targets: pbxProj.nativeTargets
                )
            }
        }

        // MARK: - XML

        func xmlElement() -> AEXMLElement {
            let element = AEXMLElement(name: "Root")
            element.addChild(userState.xmlElement())
            element.addChild(autocreateState.xmlElement())
            return element
        }

        public func write(path: Path, override: Bool) throws {
            
        }

        // MARK: - Equatable

        public static func ==(lhs: Management, rhs: Management) -> Bool {
            return lhs.userState == rhs.userState &&
                lhs.autocreateState == rhs.autocreateState
        }
    }
}
