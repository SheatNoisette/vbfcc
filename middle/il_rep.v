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
	exit
}

pub struct BFILToken {
pub:
	type_token BFILTokenType
	id         int
	value      int
	value_str  string
}

pub fn string_il(bf []BFILToken) string {
	mut s := 'main:\n'
	mut line := 0
	for token in bf {
		match token.type_token {
			.add {
				s += '\tadd $' + token.value.str() + '\t\t; ID: ${token.id}\n'
			}
			.sub {
				s += '\tsub $' + token.value.str() + '\t\t; ID: ${token.id}\n'
			}
			.move_left {
				s += '\tmove.l $' + token.value.str() + '\t\t; ID: ${token.id}\n'
			}
			.move_right {
				s += '\tmove.r $' + token.value.str() + '\t\t; ID: ${token.id}\n'
			}
			.jump_if_zero {
				s += 'label_${token.id}:\n\tjz  @label_' + token.value_str.str() +
					'\t; ID: ${token.id}\n'
			}
			.jump_if_not_zero {
				s += '\tjnz @label_' + token.value_str.str() + '\t; ID: ${token.id}\n'
				s += 'label_${token.id}:\n'
			}
			.output {
				s += '\toutput ;\tID: ${token.id}\n'
			}
			.input {
				s += '\tinput ;\tID: ${token.id}\n'
			}
			.exit {
				s += '\texit \t\t; ID: ${token.id}\n'
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
				tokens << BFILToken{
					type_token: BFILTokenType.add
					id: node.id
					value: node.value
				}
			}
			.decrement {
				tokens << BFILToken{
					type_token: BFILTokenType.sub
					id: node.id
					value: node.value
				}
			}
			.pointer_left {
				tokens << BFILToken{
					type_token: BFILTokenType.move_left
					id: node.id
					value: node.value
				}
			}
			.pointer_right {
				tokens << BFILToken{
					type_token: BFILTokenType.move_right
					id: node.id
					value: node.value
				}
			}
			// ]
			.jump_back {
				tokens << BFILToken{
					type_token: BFILTokenType.jump_if_not_zero
					id: node.id
					value: node.start_loop.id
					value_str: node.start_loop.id.str()
				}
			}
			// [
			.jump_past {
				tokens << BFILToken{
					type_token: BFILTokenType.jump_if_zero
					id: node.id
					value: node.end_loop.id
					value_str: node.end_loop.id.str()
				}
			}
			.output {
				tokens << BFILToken{
					type_token: BFILTokenType.output
					id: node.id
				}
			}
			.input {
				tokens << BFILToken{
					type_token: BFILTokenType.input
					id: node.id
				}
			}
			else {
				// Ignore
			}
		}
	}

	tokens << BFILToken{
		type_token: BFILTokenType.exit
		id: tokens.len
	}

	return tokens
}