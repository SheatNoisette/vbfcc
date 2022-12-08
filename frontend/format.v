module frontend

/*
**Simple clang-format like for BrainFuck
*/

// Format brainfuck code
pub fn format_code_from_ast(ast []&BrainfuckASTNode) string {
	mut s := ''
	mut indentation := 0
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
				s += '.\n'
			}
			.input {
				s += ',\n'
			}
			.jump_past {
				s += ' '.repeat(indentation)
				s += '[\n'
				indentation++
			}
			.jump_back {
				indentation--
				s += '\n'
				s += ' '.repeat(indentation)
				s += ']'
			}
			else {
				// ignore
			}
		}
	}

	return s
}
