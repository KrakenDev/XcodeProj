import AEXML
import Foundation
import PathKit

extension XCScheme {
    public final class UserState: Equatable {
        // MARK: - Attributes

        public var isShared: Bool
        public var orderHint: Int

        // MARK: - Init

        public init(isShared: Bool = true,
                    orderHint: Int = 0) {
            self.isShared = isShared
            self.orderHint = orderHint
        }

        init(element: AEXMLElement) throws {
            isShared = element.attributes["useCustomWorkingDirectory"] == "YES"
            orderHint = element.attributes["buildConfiguration"] as? Int ?? 0
        }

        // MARK: - XML

        func xmlElement() -> AEXMLElement {
            let element = AEXMLElement(
                name: "SchemeUserState",
                value: nil,
                attributes: [
//                    "Generate.xcscheme_^#shared#^_" : [
                        "orderHint" : String(orderHint)
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
            return lhs.isShared == rhs.isShared &&
                lhs.orderHint == rhs.orderHint
        }
    }
}
