//
//  Token.swift
//  
//
//  Created by Nikita Grishin on 5/16/22.
//

import Fluent
import Vapor

final class Token: Model {
	// 1
	static let schema = "tokens"
	// 2
	@ID(key: .id)
	var id: UUID?
	// 3
	@Field(key: "token")
	var token: String
	@Field(key: "debug")
	var debug: Bool
	// 4
	init() { }
	
	init(token: String, debug: Bool) {
		self.token = token
		self.debug = debug
	}
}
