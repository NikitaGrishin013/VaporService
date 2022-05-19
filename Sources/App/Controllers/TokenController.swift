//
//  TokenController.swift
//  
//
//  Created by Nikita Grishin on 5/16/22.
//

import APNS
import Fluent
import Vapor

struct TokenController {
	func create(req: Request) throws -> EventLoopFuture<HTTPStatus> {
		// 1
		try req.content.decode(Token.self)
		// 2
			.create(on: req.db)
		// 3
			.transform(to: .noContent)
	}
	
	func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
		// 1
		let token = req.parameters.get("token")!
		// 2
		return Token.query(on: req.db)
		// 3
			.filter(\.$token == token)
		// 4
			.first()
			.unwrap(or: Abort(.notFound))
		// 5
			.flatMap { $0.delete(on: req.db) }
		// 6
			.transform(to: .noContent)
	}
	
	func notify(req: Request) throws -> EventLoopFuture<HTTPStatus> {
		let alert = APNSwiftAlert(title: "Hello!", body: "How are you today?")
		
		// 1
		return Token.query(on: req.db)
			.all()
		// 2
			.flatMap { tokens in
				// 3
				tokens.map { token in
					req.apns.send(alert, to: token.token)
					// 4
						.flatMapError {
							// Unless APNs said it was a bad device token, just ignore the error.
							guard case let APNSwiftError.ResponseError.badRequest(response) = $0,
								  response == .badDeviceToken else {
								return req.db.eventLoop.future()
							}
							
							return token.delete(on: req.db)
						}
				}
				// 5
				.flatten(on: req.eventLoop)
				// 6
				.transform(to: .noContent)
			}
	}
}

extension TokenController: RouteCollection {
	func boot(routes: RoutesBuilder) throws {
		let tokens = routes.grouped("token")
		tokens.post(use: create)
		tokens.delete(":token", use: delete)
		tokens.post("notify", use: notify)
	}
}
