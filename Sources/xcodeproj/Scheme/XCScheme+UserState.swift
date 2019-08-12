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

        public init(targets: [PBXTarget]) {
            elements = targets.map { target in
                var key = "\(target.name)"
                key += ".\(XCScheme.isa.lowercased())_^#shared#^_"

                let type = target.productType
                let orderHint = (type == .application) ? 1 :
                    type == .commandLineTool ? 2 :
                    type == .framework ? 3 : 4

                return Element(
                    key: key,
                    isShared: true,
                    orderHint: orderHint
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
