import AEXML
import Foundation
import PathKit

extension XCScheme {
    public final class Management: Writable, Equatable {
        // MARK: - Attributes

        public var userState: UserState
        public var autocreation: BuildableAutocreation

        // MARK: - Init

        public init(schemes: [XCScheme]) {
            self.userState = UserState(schemes: schemes)
            self.autocreation = BuildableAutocreation(schemes: schemes)
        }

        init(path: Path) throws {
            let xcschemeName = XCScheme.isa.lowercased()
            let managementName = Management.isa.lowercased()
            let plistPath = path + "\(xcschemeName + managementName).plist"
            let document = try AEXMLDocument(xml: try plistPath.read())

            userState = try UserState(element: document["SchemeUserState"])
            autocreation = try BuildableAutocreation(element: document["SuppressBuildableAutocreation"])
        }

        // MARK: - XML

        func xmlElement() -> AEXMLElement {
            let element = AEXMLElement(name: "Root")
            element.addChild(userState.xmlElement())
            element.addChild(autocreation.xmlElement())
            return element
        }

        public func write(path: Path, override: Bool) throws {
            
        }

        // MARK: - Equatable

        public static func ==(lhs: Management, rhs: Management) -> Bool {
            return lhs.userState == rhs.userState &&
                lhs.autocreation == rhs.autocreation
        }
    }
}
