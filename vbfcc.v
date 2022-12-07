module main

import os
import frontend
import middle
import interpreter
import generators

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
	mut intermediate_code := middle.gen_il(parsed)
	middle.optimize_il(mut intermediate_code)
	$if debug {
		println('(PARSED) { ${parsed} }')
		println('(FORMAT) { \n${frontend.format_code_from_ast(parsed)}\n }')
		println('(IL) { ${intermediate_code} }')
		println('(FORMAT IL) { \n${middle.string_il(intermediate_code)}\n}')
	}

	/*
	state := interpreter.run(intermediate_code, interpreter.ILInterpreterOptions{
		memory_size: 128
		print_direct: true
		dynamic_memory: true
	}) or {
		println('error: could not run file - ${err}')
		exit(1)
	}
	println('memory: ${state.memory}')
	*/

	// Call the code generator
	generators.generator_call_backend('cgen', generators.CodeGenInterfaceOptions{
		output_file: 'out.c'
		custom_arguments: {}
		il: intermediate_code
		ast: parsed
	}) or {
		println('error: could not generate code - ${err}')
		exit(1)
	}
}
