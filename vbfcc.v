module main

import os
import frontend
import middle
import interpreter

fn main() {
	if os.args.len != 2 {
		println('usage: <bf file>')
		exit(1)
	}

	// Load the file
	file := os.read_file(os.args[1]) or {
		println('error: could not read file')
		exit(1)
	}

	mut lex := frontend.lex_string(file)
	$if debug {
		println('(LEX) { ${lex} }')
	}
	mut parsed := frontend.parse(mut lex) or {
		println('error: could not parse file - ${err}')
		exit(1)
	}
	intermediate_code := middle.gen_il(parsed)
	$if debug {
		println('(PARSED) { ${parsed} }')
		println('(FORMAT) { \n${frontend.format_code_from_ast(parsed)}\n }')
		println('(IL) { ${intermediate_code} }')
		println('(FORMAT IL) { \n${middle.string_il(intermediate_code)}\n}')
	}
	state := interpreter.run(intermediate_code, interpreter.ILInterpreterOptions{
		memory_size: 128
		print_direct: true
	}) or {
		println('error: could not run file - ${err}')
		exit(1)
	}

	state.print()
	$if debug {
		println('(STATE) { ${state} }')
	}
}
