import AEXML
import Foundation
import PathKit

extension XCScheme {
    public final class BuildableAutocreation: Equatable {
        // MARK: - Attributes

        public var shouldSuppress: Bool

        // MARK: - Init

        public init(shouldSuppress: Bool = false) {
            self.shouldSuppress = shouldSuppress
        }

        init(element: AEXMLElement) throws {
            shouldSuppress = element.attributes["SuppressBuildableAutocreation"].map { $0 == "YES" } ?? false
        }

        // MARK: - XML

        func xmlElement() -> AEXMLElement {
            let element = AEXMLElement(
                name: "SuppressBuildableAutocreation",
                value: nil,
                attributes: [
//                    "AEXML::AEXML": [
                        "primary" : "YES"
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

        public static func ==(lhs: BuildableAutocreation, rhs: BuildableAutocreation) -> Bool {
            return lhs.shouldSuppress == rhs.shouldSuppress
        }
    }
}
