//
//  Enums.swift
//  BankingApp
//
//  Created by jw on 03/10/2026.
//

enum LoginType: String {
    case normal = "Normal"
    case newUser = "NewUser"
    case firstTime = "FirstTime"
    case inactive = "Inactive"
    case suspended = "Suspended"
}

enum OtpType: String {
    case correctOtp = "CorrectOtp"
    case incorrectOtp = "IncorrectOtp"
}
