module frontend

// Simple clang format like for brainfuck

pub fn format_code_from_ast(ast []&BrainfuckASTNode) string
{
	mut s := ''
	for node in ast {
		match node.get_type() {
			.increment {
				s += '+'
			}
			.decrement {
				s += '-'
			}
			.pointer_left {
				s += '<'
			}
			.pointer_right {
				s += '>'
			}
			.output {
				s += '.'
			}
			.input {
				s += ','
			}
			.jump_past {
				s += '['
			}
			.jump_back {
				s += ']'
			}
			else {
				// ignore
			}
		}
	}

	return s
}
