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

    public var displayName: String {
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
        .other("Other")
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
        switch self {
        case .american:
            return "american"

        case .malaysian:
            return "malaysian"

        case .british:
            return "british"
        case .canadian:
            return "canadian"

        case .italian:
            return "italian"

        case .tunisian:
            return "tunisian"

        case .french:
            return "french"

        case .greek:
            return "greek"

        case .polish:
            return "polish"

        case .portuguese:
            return "portuguese"

        case .russian:
            return "russian"

        case .croatian:
            return "croatian"

        case .other(let other):
            return other
        }
    }
}
