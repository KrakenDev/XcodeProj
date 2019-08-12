import AEXML
import Foundation
import PathKit

extension XCScheme {
    public final class SchemeUserState: Equatable {
        public struct Element: Equatable, Codable {
            public var key: String
            public var isShared: Bool
            public var orderHint: Int

            func xmlElement() -> AEXMLElement {
                let element: AEXMLElement = .dict
                element.addChild(.key(with: CodingKeys.orderHint.stringValue))
                element.addChild(.integer(with: orderHint))
                return element
            }
        }

        // MARK: - Attributes

        public let elements: [Element]

        // MARK: - Init

        public init(schemes: [XCScheme]) {
            var orderHint = 0
            elements = schemes.map { scheme in
                var key = "\(scheme.name)"
                key += ".\(scheme.isa.lowercased())"
                key += scheme.isShared ? "_^#shared#^_" : ""

                orderHint += 1
                scheme.orderHint = scheme.orderHint < 0 ?
                    orderHint : scheme.orderHint

                return Element(
                    key: key,
                    isShared: scheme.isShared,
                    orderHint: scheme.orderHint
                )
            }.sorted { $0.key < $1.key }
        }

        init(element: AEXMLElement) throws {
            elements = []
        }

        // MARK: - XML

        func xmlElements() -> [AEXMLElement] {
            let elementXML: AEXMLElement = .dict

            for element in elements {
                elementXML.addChild(.key(with: element.key))
                elementXML.addChild(element.xmlElement())
            }
            return [.key(with: SchemeUserState.isa), elementXML]
        }

        // MARK: - Equatable

        public static func ==(lhs: SchemeUserState, rhs: SchemeUserState) -> Bool {
            return lhs.elements == rhs.elements
        }
    }
}
