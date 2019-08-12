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
                return AEXMLElement(name: key, attributes: [
                    CodingKeys.orderHint.stringValue : String(orderHint)
                ])
            }
        }

        // MARK: - Attributes

        public let elements: [Element]

        // MARK: - Init

        public init(schemes: [XCScheme], targets: [PBXNativeTarget]) {
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
            } + targets.map { target in
                var key = "\(target.name)"
                key += ".\(XCScheme.isa.lowercased())"
                orderHint += 1

                return Element(
                    key: key,
                    isShared: false,
                    orderHint: orderHint
                )
            }
        }

        init(element: AEXMLElement) throws {
            elements = []
        }

        // MARK: - XML

        func xmlElement() -> AEXMLElement {
            let xml = AEXMLElement(name: SchemeUserState.isa)
            for element in elements {
                xml.addChild(element.xmlElement())
            }
            return xml
        }

        // MARK: - Equatable

        public static func ==(lhs: SchemeUserState, rhs: SchemeUserState) -> Bool {
            return lhs.elements == rhs.elements
        }
    }
}
