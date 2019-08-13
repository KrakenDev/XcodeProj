import AEXML
import Foundation
import PathKit

extension XCScheme {
    public final class SchemeUserState: Equatable {
        public struct Element: Equatable, Codable {
            public var key: String
            public var isShown: Bool
            public var isShared: Bool
            public var orderHint: Int

            func xmlElement() -> AEXMLElement {
                let element: AEXMLElement = .dict
                element.addChild(.key(with: CodingKeys.isShown.stringValue))
                element.addChild(isShown ? .true : .false)
                element.addChild(.key(with: CodingKeys.orderHint.stringValue))
                element.addChild(.integer(with: orderHint))
                return element
            }
        }

        // MARK: - Attributes

        public let elements: [Element]

        // MARK: - Init

        public init(schemes: [XCScheme]) {
            elements = schemes.map { scheme in
                var key = scheme.name
                key += ".\(scheme.isa.lowercased())"
                key += scheme.isShared ? "_^#shared#^_" : ""

                let productTypes = PBXProductType.extensionMap[scheme
                    .buildableReferences.first { reference in
                        return reference.blueprintName == scheme.name
                    }?.buildableName ?? ""] ?? []

                scheme.orderHint =
                    productTypes.contains(.application) ? 1 :
                    productTypes.contains(.framework) ? 2 :
                    productTypes.contains(.commandLineTool) ? 3 : 4

                return Element(
                    key: key,
                    isShown: scheme.isShown,
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
