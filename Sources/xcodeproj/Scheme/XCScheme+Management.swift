import AEXML
import Foundation
import PathKit

extension XCScheme {
    public final class Management: Writable, Equatable {
        struct SchemeReference {
            let scheme: XCScheme
            let reference: BuildableReference
        }
        // MARK: - Attributes

        public let schemeUserState: SchemeUserState
        public let suppressBuildableAutocreation: SuppressBuildableAutocreation

        // MARK: - Init

        init(schemes: [XCScheme], targets: [PBXTarget]) throws {
            let allSchemes = userSchemes + sharedSchemes
            userSchemes.forEach { $0.isShown = false }
            sharedSchemes.forEach { $0.isShared = true }

            let pbx = try PBXProj.from(path: basePath)
            let allTargets = pbx.nativeTargets + pbx.aggregateTargets

            let schemeBlueprints = Set(allSchemes.map {
                $0.buildableReferences.map { $0.blueprintIdentifier }
            }.joined())
            let targetBlueprints = Set(allTargets.compactMap { target -> String? in
                let value = target.reference.value
                return !schemeBlueprints.contains(value) ? value : nil
            })

            schemeUserState = SchemeUserState(schemes: allSchemes)
            suppressBuildableAutocreation = SuppressBuildableAutocreation(
                targetNames: Array(targetBlueprints
                    .subtracting(schemeBlueprints))
            )
        }

        // MARK: - Writable

        public func write(path: Path, override: Bool) throws {
            let document: AEXMLDocument = .plist

            let elements: AEXMLElement = .dict
            elements.addChildren(schemeUserState.xmlElements())
            elements.addChildren(
                suppressBuildableAutocreation.xmlElements()
            )

            document.root.addChild(elements)

            let plist = document.xmlPlist
            try Management.plistPath(from: path).write(plist)
        }

        // MARK: - Equatable

        public static func ==(lhs: Management, rhs: Management) -> Bool {
            return lhs.schemeUserState == rhs.schemeUserState &&
                lhs.suppressBuildableAutocreation == rhs.suppressBuildableAutocreation
        }
    }
}

extension XCScheme.Management {
    private static func plistPath(from path: Path) -> Path {
        let managementName = XCScheme.Management.isa.lowercased()
        let xcschemeName = XCScheme.isa.lowercased()
        return path + XCUserData.schemesPath
            + Path("\(xcschemeName + managementName).plist")
    }
}

