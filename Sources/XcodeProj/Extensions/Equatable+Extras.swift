//
//  Equatable+Extras.swift
//  XcodeProj
//
//  Created by Kraken on 8/11/19.
//

import Foundation

extension Equatable {
    var isa: String {
        return String(describing: type(of: self))
    }
    static var isa: String {
        return String(describing: self)
    }
}
