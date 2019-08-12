import AEXML
import Foundation
import PathKit

extension XCScheme {
    public final class SuppressBuildableAutocreation: Equatable {
        public struct Element: Equatable, Codable {
            public let blueprintIdentifier: String
            public var primary: Bool

            func xmlElement() -> AEXMLElement {
                let element: AEXMLElement = .dict
                element.addChild(.key(with: CodingKeys.primary.stringValue))
                element.addChild(primary ? .true : .false)
                return element
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

        func xmlElements() -> [AEXMLElement] {
            let elementXML: AEXMLElement = .dict

            for element in elements {
                elementXML.addChild(.key(with: element.blueprintIdentifier))
                elementXML.addChild(element.xmlElement())
            }
            return [.key(with: SuppressBuildableAutocreation.isa), elementXML]
        }

        // MARK: - Equatable

        public static func ==(lhs: SuppressBuildableAutocreation, rhs: SuppressBuildableAutocreation) -> Bool {
            return lhs.elements == rhs.elements
        }
    }
}
