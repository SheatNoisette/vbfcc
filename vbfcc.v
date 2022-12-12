module main

import os
import cli { Command, Flag }
import frontend
import middle
import interpreter
import generators
import v.vmod

/*
** Entry point for the vbfcc compiler and interpreter
*/

const (
	vbfcc_version     = '-${@MOD} (V ${@VHASH})'
	vbfcc_output_file = 'out'
)

// Get the version string
fn get_version() string {
	vm := vmod.decode(@VMOD_FILE) or { panic(err) }
	output := '${vm.version}${vbfcc_version}'
	return output
}

// Build the intermediate code for use in the interpreter or code generator
fn build_ir(file_path string, optimize_il bool, debug bool) ![]middle.BFILToken {
	// Load the file
	file := os.read_file(file_path) or {
		println('error: could not read file: ${err}')
		exit(1)
	}

	// Run the lexer
	mut lex := frontend.lex_string(file)

	// If requested, print the lexer output
	if debug {
		eprintln('(lexer) Generated tokens:')
		eprintln(lex.str())
		eprintln('(lexer) -- End of tokens --')
	}

	// Generate a cleaned up AST
	mut parsed := frontend.parse(mut lex) or {
		eprintln('error: could not parse file - ${err}')
		exit(1)
	}

	if debug {
		eprintln('(parser) Generated AST:')
		for node in parsed {
			eprintln(node)
		}
		eprintln('(parser) -- End of AST-- ')
	}

	// Generate the intermediate code
	mut intermediate_code := middle.gen_il(parsed)

	if debug {
		eprintln('(il) Generated IL:')
		for token in intermediate_code {
			eprintln(token)
		}
		eprintln('(il) -- End of IL --')
	}

	// If requested, optimize the intermediate code
	if optimize_il {
		middle.optimize_il(mut intermediate_code)

		if debug {
			eprintln('(il) Optimized IL:')
			for token in intermediate_code {
				eprintln(token)
			}
			eprintln('(il) -- End of IL --')
		}
	}

	return intermediate_code
}

// Run the interpreter
fn run_interpreter(cmd Command) ! {
	file_path := cmd.args[0]

	memory_size := cmd.flags.get_int('memorysize') or {
		eprintln('error: invalid memory size (${err})')
		exit(1)
	}
	dynamic_memory := cmd.flags.get_bool('dynamicmem') or {
		eprintln('error: invalid dynamic memory flag (${err})')
		exit(1)
	}
	debug_mode := cmd.flags.get_bool('debug') or {
		eprintln('error: invalid debug flag (${err})')
		exit(1)
	}
	optimize_il := cmd.flags.get_bool('optimize') or {
		eprintln('error: invalid optimize flag (${err})')
		exit(1)
	}

	// Build the intermediate code
	intermediate_code := build_ir(file_path, optimize_il, debug_mode) or {
		eprintln('error: could not build intermediate code:')
		eprintln(err)
		exit(1)
	}

	// Run the code
	state := interpreter.run(intermediate_code, interpreter.ILInterpreterOptions{
		memory_size: memory_size
		print_direct: true
		dynamic_memory: dynamic_memory
	}) or {
		eprintln('error: could not run file - ${err}')
		exit(1)
	}

	// Print the state if debug mode is enabled
	if debug_mode {
		eprintln('memory pointer: ${state.pointer}')
		eprintln('memory: ${state.memory}')
	}
}

// Compile the file to a target backend
fn compile_file(cmd Command) ! {
	// Get file path
	file_path := cmd.args[0]

	optimize := cmd.flags.get_bool('optimize') or {
		eprintln('error: invalid optimize flag (${err})')
		exit(1)
	}

	backend := cmd.flags.get_string('backend') or {
		eprintln('error: invalid backend flag (${err})')
		exit(1)
	}

	stdout := cmd.flags.get_bool('stdout') or {
		eprintln('error: invalid stdout flag (${err})')
		exit(1)
	}

	debug := cmd.flags.get_bool('debug') or {
		println('error: invalid debug flag (${err})')
		exit(1)
	}

	// Memory size
	memory_size := cmd.flags.get_int('memorysize') or {
		eprintln('error: invalid memory size (${err})')
		exit(1)
	}

	// Export the functio
	export := cmd.flags.get_bool('export') or {
		eprintln('error: invalid export flag (${err})')
		exit(1)
	}

	custom_arguments := cmd.flags.get_string('custom') or {
		eprintln('error: invalid custom arguments (${err})')
		exit(1)
	}

	// Get the output file
	output_file := match cmd.args.len {
		1 {
			vbfcc_output_file
		}
		2 {
			cmd.args[1]
		}
		else {
			eprintln('error: too many arguments (got ${cmd.flags.len})')
			exit(1)
		}
	}

	// Sanity check of commands
	if output_file != vbfcc_output_file && stdout {
		eprintln('error: cannot output to both file and stdout')
		exit(1)
	}

	// Build the intermediate code
	intermediate_code := build_ir(file_path, optimize, debug) or {
		eprintln('error: could not build intermediate code:')
		eprintln(err)
		exit(1)
	}

	// Call the code generator
	generators.generator_call_backend(backend, generators.CodeGenInterfaceOptions{
		output_file: output_file
		custom_arguments: custom_arguments.split(' ')
		print_stdout: stdout
		optimize: optimize
		il: intermediate_code
		memory_size: memory_size
		generate_function: export
	}) or {
		eprintln('error: could not generate code - ${err}')
		exit(1)
	}
}

// Main CLI entry point
fn main() {
	mut cmd := Command{
		name: 'vbfcc'
		description: 'Brainfuck compiler and interpreter'
		version: get_version()
	}

	// Interpreter command
	mut interpreter := Command{
		name: 'run'
		description: 'Run a Brainfuck file from the integrated interpreter'
		usage: '<file>'
		required_args: 1
		execute: run_interpreter
	}
	interpreter.add_flag(Flag{
		flag: .bool
		name: 'optimize'
		abbrev: 'opt'
		default_value: ['false']
		description: 'Optimize the intermediate code before running'
	})
	interpreter.add_flag(Flag{
		flag: .bool
		name: 'debug'
		abbrev: 'd'
		default_value: ['false']
		description: 'Print debug information'
	})
	interpreter.add_flag(Flag{
		flag: .bool
		name: 'dynamicmem'
		abbrev: 'dm'
		default_value: ['true']
		description: 'Use dynamic memory allocation instead of a fixed size memory array'
	})
	interpreter.add_flag(Flag{
		flag: .int
		name: 'memorysize'
		abbrev: 'ms'
		default_value: ['255']
		description: 'The size of the memory array'
	})

	// Compile command
	mut compile := Command{
		name: 'build'
		description: 'Compile a Brainfuck file to a target language'
		usage: '<bf file> [output file]'
		required_args: 1
		execute: compile_file
	}
	compile.add_flag(Flag{
		flag: .bool
		name: 'optimize'
		abbrev: 'opt'
		default_value: ['false']
		description: 'Optimize the intermediate code before running'
	})
	compile.add_flag(Flag{
		flag: .string
		name: 'backend'
		abbrev: 'b'
		default_value: ['cgen']
		description: 'The target backend'
	})
	compile.add_flag(Flag{
		flag: .bool
		name: 'stdout'
		default_value: ['false']
		description: 'Print the output to stdout instead of a file'
	})
	compile.add_flag(Flag{
		flag: .bool
		name: 'debug'
		abbrev: 'd'
		default_value: ['false']
		description: 'Debug output'
	})
	compile.add_flag(Flag{
		flag: .string
		name: 'custom'
		abbrev: 'c'
		default_value: ['']
		description: 'Custom arguments for the backend (format: -flag value, ...)'
	})
	compile.add_flag(Flag{
		flag: .int
		name: 'memorysize'
		abbrev: 'm'
		default_value: ['256']
		description: 'The size of the memory array'
	})
	compile.add_flag(Flag{
		flag: .bool
		name: 'export'
		abbrev: 'e'
		default_value: ['false']
		description: 'Export the code in a function instead of a main function'
	})

	cmd.add_command(interpreter)
	cmd.add_command(compile)
	cmd.setup()
	cmd.parse(os.args)
}
