//
//  File.swift
//  
//
//  Created by kyle on 3/5/24.
//


protocol TextRepresentable {}
protocol NumberRepresentable {}
protocol BoolRepresentable {}
extension String: TextRepresentable {}
extension Int: NumberRepresentable {}
extension Bool: BoolRepresentable {}
