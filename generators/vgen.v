module generators

const (
	vgen_prelude  = $embed_file('generators/preludes/vgen_v.vfile')
	vgen_postlude = $embed_file('generators/postludes/vgen_v.vfile')
)

/*
** V code Generator
** Why? Because I can.
*/

struct VGenBackend {}

// Generate code for Brainfuck code
fn (cgen VGenBackend) generate_code(options CodeGenInterfaceOptions) ? {
	mut output := ''

	// Add prelude
	output += generators.vgen_prelude.to_string()
	mut indent := 1

	for tok in options.il {
		output += indent_str('\t', indent, match tok.type_token {
			.move_right {
				'ptr += ${tok.value}'
			}
			.move_left {
				'ptr -= ${tok.value}'
			}
			.add {
				'memory[ptr] += ${tok.value}'
			}
			.sub {
				'memory[ptr] -= ${tok.value}'
			}
			.exit {
				'exit(0)'
			}
			.jump_if_zero {
				indent++
				'for memory[ptr] != 0 {'
			}
			.jump_if_not_zero {
				indent--
				'}'
			}
			.input {
				'memory[ptr] = os.get_line()[0]'
			}
			.output {
				'print(memory[ptr].ascii_str())'
			}
		}) + '\n'
	}

	// Add postlude
	output += generators.vgen_postlude.to_string()

	// Write to file
	write_code_to_single_file_or_stdout(output, options.output_file, options.print_stdout) or {
		return error('Failed to write code to file')
	}
}
