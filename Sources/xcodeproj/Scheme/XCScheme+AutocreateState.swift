import AEXML
import Foundation
import PathKit

extension XCScheme {
    public final class AutocreateState: Writable, Equatable {
        public struct Element: Equatable, Codable {
            public let blueprintIdentifier: String
            public var primary: Bool

            func xmlElement() -> AEXMLElement {
                return AEXMLElement(
                    name: blueprintIdentifier,
                    attributes: [
                        CodingKeys.primary.stringValue :
                            primary ? "YES" : "NO"
                    ]
                )
            }
        }

        // MARK: - Attributes

        var elements: [Element]

        // MARK: - Init

        public init(schemes: [XCScheme]) {
            elements = schemes.map { scheme in
                return .init(
                    blueprintIdentifier: scheme.name,
                    primary: scheme.shouldAutocreate != true
                )
            }
        }

        init(element: AEXMLElement) throws {
            elements = []
        }

        // MARK: - XML

        func xmlElement() -> AEXMLElement {
            let elementXML = AEXMLElement(name: "SuppressBuildableAutocreation")
            for element in elements {
                elementXML.addChild(element.xmlElement())
            }
            return elementXML
        }

        // MARK: - Writable

        public func write(path: Path, override: Bool) throws {
        }

        // MARK: - Equatable

        public static func ==(lhs: AutocreateState, rhs: AutocreateState) -> Bool {
            return lhs.elements == rhs.elements
        }
    }
}
