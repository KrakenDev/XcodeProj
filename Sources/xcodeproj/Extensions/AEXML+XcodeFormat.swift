import AEXML
import Foundation

extension AEXMLDocument {
    var xmlPlist: String {
        return Plist.header + Plist.doctype + xmlSpaces
            .components(separatedBy: "\n")
            .dropFirst().joined(separator: "\n")
    }
    var xmlXcodeFormat: String {
        var xml = "<?xml version=\"\(options.documentHeader.version)\" encoding=\"\(options.documentHeader.encoding.uppercased())\"?>\n"
        xml += root._xmlXcodeFormat + "\n"
        return xml
    }
    static var plist: AEXMLDocument {
        return AEXMLDocument(root: .init(
            name: Plist.plist,
            attributes: ["version" : "1.0"]
        ))
    }
}

extension AEXMLElement {
    static var dict: AEXMLElement {
        return .init(name: Plist.dict)
    }
    static var `true`: AEXMLElement {
        return .init(name: Plist.true)
    }
    static var `false`: AEXMLElement {
        return .init(name: Plist.false)
    }
    static func key(with value: String?) -> AEXMLElement {
        return AEXMLElement(name: Plist.key, value: value)
    }
    static func integer(with value: Int) -> AEXMLElement {
        return AEXMLElement(name: Plist.integer, value: String(value))
    }
}

struct Plist: Codable {
    private let key: String
    private let plist: String
    private let dict: String
    private let integer: String
    private let string: String
    private let `true`: String
    private let `false`: String

    static var header: String {
        return "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
    }
    static var doctype: String {
        return "<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n"
    }
    static var key: String {
        return CodingKeys.key.stringValue
    }
    static var plist: String {
        return CodingKeys.plist.stringValue
    }
    static var dict: String {
        return CodingKeys.dict.stringValue
    }
    static var integer: String {
        return CodingKeys.integer.stringValue
    }
    static var string: String {
        return CodingKeys.string.stringValue
    }
    static var `true`: String {
        return CodingKeys.true.stringValue + "/"
    }
    static var `false`: String {
        return CodingKeys.false.stringValue + "/"
    }
}

let attributesOrder: [String: [String]] = [
    "BuildAction": [
        "parallelizeBuildables",
        "buildImplicitDependencies",
    ],
    "BuildActionEntry": [
        "buildForTesting",
        "buildForRunning",
        "buildForProfiling",
        "buildForArchiving",
        "buildForAnalyzing",
    ],
    "BuildableReference": [
        "BuildableIdentifier",
        "BlueprintIdentifier",
        "BuildableName",
        "BlueprintName",
        "ReferencedContainer",
    ],
    "TestAction": [
        "buildConfiguration",
        "selectedDebuggerIdentifier",
        "selectedLauncherIdentifier",
        "language",
        "region",
        "codeCoverageEnabled",
        "shouldUseLaunchSchemeArgsEnv",
    ],
    "LaunchAction": [
        "buildConfiguration",
        "selectedDebuggerIdentifier",
        "selectedLauncherIdentifier",
        "language",
        "region",
        "debugAsWhichUser",
        "launchStyle",
        "useCustomWorkingDirectory",
        "customWorkingDirectory",
        "ignoresPersistentStateOnLaunch",
        "debugDocumentVersioning",
        "debugServiceExtension",
        "enableGPUFrameCaptureMode",
        "enableGPUValidationMode",
        "allowLocationSimulation",
    ],
    "ProfileAction": [
        "buildConfiguration",
        "shouldUseLaunchSchemeArgsEnv",
        "savedToolIdentifier",
        "useCustomWorkingDirectory",
        "customWorkingDirectory",
        "ignoresPersistentStateOnLaunch",
        "debugDocumentVersioning",
        "enableTestabilityWhenProfilingTests",
    ],
    "ActionContent": [
        "title",
        "scriptText",
        "message",
        "conveyanceType",
    ],
    "EnvironmentVariable": [
        "key",
        "value",
        "isEnabled",
    ],
    "TestableReference": [
        "skipped",
        "parallelizable",
        "testExecutionOrdering",
    ],
    "BreakpointContent": [
        "shouldBeEnabled",
        "ignoreCount",
        "continueAfterRunningActions",
        "breakpointStackSelectionBehavior",
        "scope",
        "stopOnStyle",
        "symbolName",
        "moduleName",
    ],
]

extension AEXMLElement {
    fileprivate var _xmlXcodeFormat: String {
        var xml = String()

        // open element
        xml += indent(withDepth: parentsCount - 1)
        xml += "<\(name)"

        func print(key: String, value: String) {
            xml += "\n"
            xml += indent(withDepth: parentsCount)
            xml += "\(key) = \"\(value.xmlEscaped)\""
        }

        if !attributes.isEmpty {
            // insert known attributes in the specified order.
            var attributes = self.attributes
            for key in attributesOrder[self.name] ?? [] {
                if let value = attributes.removeValue(forKey: key) {
                    print(key: key, value: value)
                }
            }

            // Print any remaining attributes.
            for (key, value) in attributes.sorted(by: { $0.key < $1.key }) {
                print(key: key, value: value)
            }
        }

        if value == nil, children.isEmpty {
            // close element
            xml += ">\n"
        } else {
            if !children.isEmpty {
                // add children
                xml += ">\n"
                for child in children {
                    xml += "\(child._xmlXcodeFormat)\n"
                }
            } else {
                // insert string value and close element
                xml += ">\n"
                xml += indent(withDepth: parentsCount - 1)
                xml += ">\n\(string.xmlEscaped)"
            }
        }

        xml += indent(withDepth: parentsCount - 1)
        xml += "</\(name)>"

        return xml
    }

    private var parentsCount: Int {
        var count = 0
        var element = self

        while let parent = element.parent {
            count += 1
            element = parent
        }

        return count
    }

    private func indent(withDepth depth: Int) -> String {
        var count = depth
        var indent = String()

        while count > 0 {
            indent += "   "
            count -= 1
        }

        return indent
    }
}
