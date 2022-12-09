module generators

import middle
import frontend
import os

// Base options for the code generator
pub struct CodeGenInterfaceOptions {
pub:
	output_file      string // The output file
	custom_arguments map[string]string // Custom arguments for the backend
	optimize         bool // Whether to optimize the code (if the backend supports it)
	print_stdout     bool // Whether to print the output to stdout
	il               []middle.BFILToken // The intermediate representation
	ast              []&frontend.BrainfuckASTNode // The AST (if needed)
}

// The interface for the code generator
// Only "generate_code" is required for now
interface CodeGenInterface {
	generate_code(options CodeGenInterfaceOptions) ?
}

// Dispatches the call to the correct backend
pub fn generator_call_backend(backend_name string, options CodeGenInterfaceOptions) ? {
	match backend_name {
		'c', 'cgen' {
			mut cgen := CGenBackend{}
			return cgen.generate_code(options)
		}
		'v', 'vlang' {
			mut vgen := VGenBackend{}
			return vgen.generate_code(options)
		}
		else {
			return error('Unknown backend: ' + backend_name)
		}
	}
}

// Write code to a file
// If stdout is true, the code will be printed to stdout
fn write_code_to_single_file_or_stdout(code string, file string, stdout bool) ? {
	if stdout {
		println(code)
	} else {
		mut f := os.create(file) or { return error('Could not create file ${file}') }
		f.write_string(code) or { return error('Could not write to file ${file}') }
		f.close()
	}
}
