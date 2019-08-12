import AEXML
import Foundation
import PathKit

extension XCScheme {
    public final class SuppressBuildableAutocreation: Equatable {
        public struct Element: Equatable, Codable {
            public let key: String
            public let primary: Bool = true

            func xmlElement() -> AEXMLElement {
                let element: AEXMLElement = .dict
                element.addChild(.key(with: CodingKeys.primary.stringValue))
                element.addChild(primary ? .true : .false)
                return element
            }
        }

        // MARK: - Attributes

        let elements: [Element]

        // MARK: - Init

        public init(targetNames: [String]) {
            elements = targetNames.sorted(by: <).map(Element.init)
        }

        init(element: AEXMLElement) throws {
            // TODO
            elements = []
        }

        // MARK: - XML

        func xmlElements() -> [AEXMLElement] {
            let elementXML: AEXMLElement = .dict

            for element in elements {
                elementXML.addChild(.key(with: element.key))
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
