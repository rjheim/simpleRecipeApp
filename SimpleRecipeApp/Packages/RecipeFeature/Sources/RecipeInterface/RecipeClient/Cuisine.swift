//
//  Cuisine.swift
//  RecipeFeature
//
//  Created by RJ Heim on 6/2/25.
//

import Foundation

public enum Cuisine: Equatable, Hashable, Sendable {
    case american
    case malaysian
    case british
    case canadian
    case italian
    case tunisian
    case french
    case greek
    case polish
    case portuguese
    case russian
    case croatian
    case other(String)

    var displayName: String {
        switch self {
        case .other(let name):
            return String(NSString(string: name).capitalized)

        default:
            return String(NSString(string: self.rawValue).capitalized)
        }
    }
}

extension Cuisine: CaseIterable {
    public static let allCases: [Cuisine] = [
        .american,
        .british,
        .canadian,
        .croatian,
        .french,
        .greek,
        .italian,
        .malaysian,
        .polish,
        .portuguese,
        .russian,
        .tunisian,
        .other("Something else!")
    ]
}

extension Cuisine: RawRepresentable {
    public typealias RawValue = String

    public init?(rawValue: RawValue) {
        switch rawValue.lowercased() {
        case "american":
            self = .american

        case "malaysian":
            self = .malaysian

        case "british":
            self = .british

        case "canadian":
            self = .canadian

        case "italian":
            self = .italian

        case "tunisian":
            self = .tunisian

        case "french":
            self = .french

        case "greek":
            self = .greek

        case "polish":
            self = .polish

        case "portuguese":
            self = .portuguese

        case "russian":
            self = .russian

        case "croatian":
            self = .croatian

        default:
            self = .other(rawValue)
        }
    }

    public var rawValue: String {
        return self.displayName
    }
}
