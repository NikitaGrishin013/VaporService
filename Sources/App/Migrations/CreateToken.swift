//
//  CreateToken.swift
//  
//
//  Created by Nikita Grishin on 5/16/22.
//

import Vapor
import Fluent

struct CreateToken: Migration {
	func prepare(on database: Database) -> EventLoopFuture<Void> {
		return database.schema("tokens")
			.id()
			.field("token", .string, .required)
			.field("debug", .bool, .required)
			.unique(on: "token")
			.create()
	}
	
	func revert(on database: Database) -> EventLoopFuture<Void> {
		return database.schema("tokens").delete()
	}
}
