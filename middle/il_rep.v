module middle

import frontend

// Generate the intermediate code for a bf program

enum BFILTokenType {
	add
	sub
	move_left
	move_right
	jump_if_zero
	jump_if_not_zero
	label
}

struct BFILToken{
	type_token BFILTokenType
	value int
}

pub fn string_il(bf []BFILToken) string {
	mut s := 'main:\n'
	for token in bf {
		match token.type_token {
			.add {
				s += '\tadd $' + token.value.str() + ';\n'
			}
			.sub {
				s += '\tsub $' + token.value.str() + ';\n'
			}
			.move_left {
				s += '\tmove_l $' + token.value.str() + ';\n'
			}
			.move_right {
				s += '\tmove_r $' + token.value.str() + ';\n'
			}
			.jump_if_zero {
				s += '\tjump_if_zero $' + token.value.str() + ';\n'
			}
			.jump_if_not_zero {
				s += '\tjump_if_not_zero $' + token.value.str() + ';\n'
			}
			else {
				s += "\t; Unknown token\n"
			}
		}
	}

	return s
}

// Translate a Ast into a list of BFILToken
pub fn gen_il(ast []&frontend.BrainfuckASTNode) []BFILToken {
	mut tokens := []BFILToken{}

	for node in ast {
		match node.get_type() {
			.increment {
				tokens << BFILToken{type_token: BFILTokenType.add, value: node.value}
			}
			.decrement {
				tokens << BFILToken{type_token: BFILTokenType.sub, value: node.value}
			}
			.pointer_left {
				tokens << BFILToken{type_token: BFILTokenType.move_left, value: node.value}
			}
			.pointer_right {
				tokens << BFILToken{type_token: BFILTokenType.move_right, value: node.value}
			}
			.jump_back {
				tokens << BFILToken{
					type_token: BFILTokenType.jump_if_not_zero
					value: 0
				}
			}
			.jump_past {
				tokens << BFILToken{
					type_token: BFILTokenType.jump_if_zero
					value: node.value
				}
			}
			else {
				// Ignore
			}
		}
	}

	return tokens
}
