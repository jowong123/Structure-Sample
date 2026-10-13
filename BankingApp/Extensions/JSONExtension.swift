//
//  JSONExtension.swift
//  BankingApp
//
//  Created by jw on 03/10/2026.
//

import Foundation
import SwiftyJSON

extension JSON {
    // MARK: - Properties
    // MARK: Internal

    var decimal: Decimal? {
        return number?.decimalValue
    }

    var decimalValue: Decimal {
        return numberValue.decimalValue
    }

    // MARK: - Static Methods

    static func generateJSON(fileName: String) -> JSON? {
        if let path = Bundle.main.path(forResource: fileName, ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                return try JSON(data: data)
            } catch {
                print(error)
            }
        }
        return nil
    }
}
