import AEXML
import Foundation
import PathKit

extension XCScheme {
    public final class Management: Writable, Equatable {
        // MARK: - Attributes

        public var userState: SchemeUserState
        public var autocreateState: AutocreateState

        // MARK: - Init

        public init(schemes: [XCScheme], targets: [PBXNativeTarget] = []) {
            self.userState = SchemeUserState(schemes: schemes, targets: targets)
            self.autocreateState = AutocreateState(schemes: schemes)
        }

        init(path: Path) throws {
            guard let document = try? AEXMLDocument(
                xml: try Management.plistPath(from: path).read()) else {
                let basePath = Path(path.string.replacingOccurrences(
                    of: XCUserData.schemesPath.string, with: ""))
                let sharedData = try XCSharedData(path: basePath)
                let userSchemes = try XCUserData.schemes(from: path)
                let sharedSchemes = sharedData.schemes

                let pbxProj = try PBXProj.from(path: basePath)
                autocreateState = AutocreateState(schemes: userSchemes)
                userState = SchemeUserState(
                    schemes: userSchemes + sharedSchemes,
                    targets: pbxProj.nativeTargets
                )
                return
            }
            userState = try SchemeUserState(element: document[SchemeUserState.isa])
            autocreateState = try AutocreateState(element: document["SuppressBuildableAutocreation"])
        }

        // MARK: - XML

        func xmlElement() -> AEXMLElement {
            let element = AEXMLElement(name: "Root")
            element.addChild(userState.xmlElement())
            element.addChild(autocreateState.xmlElement())
            return element
        }

        // MARK: - Writable

        public func write(path: Path, override: Bool) throws {
            let writePath = Management.plistPath(from: path)
            let xmlString = xmlElement().xml
            try writePath.write(xmlString)
        }

        // MARK: - Equatable

        public static func ==(lhs: Management, rhs: Management) -> Bool {
            return lhs.userState == rhs.userState &&
                lhs.autocreateState == rhs.autocreateState
        }
    }
}

extension XCScheme.Management {
    private static func plistPath(from path: Path) -> Path {
        let managementName = XCScheme.Management.isa.lowercased()
        let xcschemeName = XCScheme.isa.lowercased()
        return path + "\(xcschemeName + managementName).plist"
    }
}
