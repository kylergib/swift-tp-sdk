//
//  File.swift
//  
//
//  Created by kyle on 3/5/24.
//


public protocol TextRepresentable {}
public protocol NumberRepresentable {}
public protocol BoolRepresentable {}
extension String: TextRepresentable {}
extension Int: NumberRepresentable {}
extension Bool: BoolRepresentable {}
