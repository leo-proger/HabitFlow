//
//  ColorHex.swift
//  habit-tracker-trpo
//
//  Created by Leo Proger on 3/17/2026.
//
import SwiftUI

extension Color {
	init(hex: String) {
		let hex = hex.trimmingCharacters(in: .alphanumerics.inverted)
		var int: UInt64 = 0
		Scanner(string: hex).scanHexInt64(&int)

		let r: UInt64
		let g: UInt64
		let b: UInt64
		switch hex.count {
		case 6: (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
		default: (r, g, b) = (1, 1, 0)
		}

		self.init(
			.sRGB,
			red: Double(r) / 255,
			green: Double(g) / 255,
			blue: Double(b) / 255
		)
	}
}
