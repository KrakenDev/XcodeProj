import AEXML
import Foundation
import PathKit

extension XCScheme {
    public final class UserState: Equatable {
        public struct Element: Equatable {
            public var key: String
            public var isShared: Bool
            public var orderHint: Int
        }

        // MARK: - Attributes

        public let elements: [Element]

        // MARK: - Init

        public init(schemes: [XCScheme]) {
            elements = schemes.map { scheme in
                var key = "\(scheme.name)"
                key += ".\(scheme.isa.lowercased())"
                key += scheme.isShared ? "_^#shared#^_" : ""

                return Element(
                    key: key,
                    isShared: scheme.isShared,
                    orderHint: scheme.orderHint
                )
            }
        }

        init(element: AEXMLElement) throws {
            elements = []
        }

        // MARK: - XML

        func xmlElement() -> AEXMLElement {
            let element = AEXMLElement(
                name: "SchemeUserState",
                value: nil,
                attributes: [
//                    "Generate.xcscheme_^#shared#^_" : [
                        "orderHint" : ""
//                    ]
                ])
            let actions = element.addChild(name: "PreActions")
            let preActions = try! element["PreActions"]["ExecutionAction"].all?.map(ExecutionAction.init) ?? []
            preActions.forEach { preAction in
                actions.addChild(preAction.xmlElement())
            }
            return element
        }

        // MARK: - Equatable

        public static func ==(lhs: UserState, rhs: UserState) -> Bool {
            return lhs.elements == rhs.elements
        }
    }
}
