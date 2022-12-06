module middle

import frontend

// Generate the intermediate code for a bf program

pub enum BFILTokenType {
	add
	sub
	move_left
	move_right
	output
	input
	jump_if_zero
	jump_if_not_zero
	label
	exit
}

pub struct BFILToken {
pub:
	type_token BFILTokenType
	value      int
	value_str  string
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
				s += '\tjump_if_zero @' + token.value_str.str() + ';\n'
			}
			.jump_if_not_zero {
				s += '\tjump_if_not_zero @' + token.value_str.str() + ';\n'
			}
			.label {
				s += token.value_str + ':\n'
			}
			.output {
				s += '\toutput;\n'
			}
			.input {
				s += '\tinput;\n'
			}
			.exit {
				s += '\texit;\n'
			}
		}
	}

	return s
}

// Translate a Ast into a list of BFILToken
pub fn gen_il(ast []&frontend.BrainfuckASTNode) []BFILToken {
	mut tokens := []BFILToken{}
	mut label_counter := 0

	for node in ast {
		match node.get_type() {
			.increment {
				tokens << BFILToken{
					type_token: BFILTokenType.add
					value: node.value
				}
			}
			.decrement {
				tokens << BFILToken{
					type_token: BFILTokenType.sub
					value: node.value
				}
			}
			.pointer_left {
				tokens << BFILToken{
					type_token: BFILTokenType.move_left
					value: node.value
				}
			}
			.pointer_right {
				tokens << BFILToken{
					type_token: BFILTokenType.move_right
					value: node.value
				}
			}
			.jump_back {
				tokens << BFILToken{
					type_token: BFILTokenType.label
					value_str: 'label_' + node.value.str()
				}
				tokens << BFILToken{
					type_token: BFILTokenType.jump_if_not_zero
					value: node.start_loop.value
					value_str: 'label_' + node.start_loop.value.str()
				}
				label_counter++
			}
			.jump_past {
				tokens << BFILToken{
					type_token: BFILTokenType.label
					value_str: 'label_' + node.value.str()
				}
				tokens << BFILToken{
					type_token: BFILTokenType.jump_if_zero
					value: node.end_loop.value
					value_str: 'label_' + node.end_loop.value.str()
				}
				label_counter++
			}
			.output {
				tokens << BFILToken{
					type_token: BFILTokenType.output
				}
			}
			.input {
				tokens << BFILToken{
					type_token: BFILTokenType.input
				}
			}
			else {
				// Ignore
			}
		}
	}

	tokens << BFILToken{
		type_token: BFILTokenType.exit
	}

	return tokens
}
