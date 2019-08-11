import AEXML
import Foundation
import PathKit

extension XCScheme {
    public final class Management {
        // MARK: - Attributes

        public var userState: UserState
        public var autocreation: BuildableAutocreation

        // MARK: - Init

        public init(userState: UserState,
                    autocreation: BuildableAutocreation) {
            self.userState = userState
            self.autocreation = autocreation
        }

        init(element: AEXMLElement) throws {
            userState = element.attributes["buildConfiguration"] as! UserState
            autocreation = element.attributes["shouldUseLaunchSchemeArgsEnv"] as! BuildableAutocreation
        }

        // MARK: - XML

        func xmlElement() -> AEXMLElement {
            let element = AEXMLElement(
                name: "ProfileAction",
                value: nil,
                attributes: [
                    "userState": "",
                    "autocreation": ""
                ])
//            if let userState = userState {
//                element.addChild(EnvironmentVariable.xmlElement(from: userState))
//            }
//
//            if let autocreation = autocreation {
//                let macro = element.addChild(name: "MacroExpansion")
//                macro.addChild(autocreation.xmlElement())
//            }

            return element
        }

        // MARK: - Equatable

        public static func ==(lhs: Management, rhs: Management) -> Bool {
            return lhs.userState == rhs.userState &&
                lhs.autocreation == rhs.autocreation
        }
    }
}
