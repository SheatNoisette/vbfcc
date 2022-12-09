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

	for tok in options.il {
		output += match tok.type_token {
			.move_right {
				'\tptr += ${tok.value}'
			}
			.move_left {
				'\tptr -= ${tok.value}'
			}
			.add {
				'\tmemory[ptr] += ${tok.value}'
			}
			.sub {
				'\tmemory[ptr] -= ${tok.value}'
			}
			.exit {
				''
			}
			.jump_if_zero {
				// 'label_${tok.id}:\n\tif (memory[ptr] == 0) goto label_${tok.value};'
				'\tfor memory[ptr] != 0 {'
			}
			.jump_if_not_zero {
				// '\tif (memory[ptr] != 0) goto label_${tok.value};\nlabel_${tok.id}:'
				'}'
			}
			.input {
				'\tmemory[ptr] = os.get_line()[0]'
			}
			.output {
				'\tprint(memory[ptr].ascii_str())'
			}
		} + '\n'
	}

	// Add postlude
	output += generators.vgen_postlude.to_string()

	// Write to file
	write_code_to_single_file_or_stdout(output, options.output_file, options.print_stdout) or {
		return error('Failed to write code to file')
	}
}
