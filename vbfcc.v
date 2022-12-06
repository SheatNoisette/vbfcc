module main

import os
import frontend
import middle

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
	mut parsed := frontend.parse(mut lex)
	intermediate_code := middle.gen_il(parsed)
	$if debug {
		println('(PARSED) { ${parsed} }')
		println('(FORMAT) { ${frontend.format_code_from_ast(parsed)} }')
		println('(IL) { ${intermediate_code} }')
		println('(FORMAT IL) { ${middle.string_il(intermediate_code)} }')
	}
}
